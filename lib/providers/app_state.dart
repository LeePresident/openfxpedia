import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/config.dart';
import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../services/cache_service.dart';
import '../services/conversion_service.dart';
import '../services/currency_catalog.dart';
import '../services/favorites_service.dart';

enum LoadingState { idle, loading, error }

class AppState extends ChangeNotifier {
  final ConversionService _conversionService;
  final CurrencyCatalogService _catalogService;
  final FavoritesService _favoritesService;
  final CacheService _cacheService;
  final Iterable<Locale> Function() _systemLocales;

  List<Currency> _currencies = [];
  List<Currency> get currencies => _currencies;

  Currency? _baseCurrency;
  Currency? _targetCurrency;
  Currency? get baseCurrency => _baseCurrency;
  Currency? get targetCurrency => _targetCurrency;

  double _inputAmount = 1.0;
  double get inputAmount => _inputAmount;

  double? _convertedAmount;
  double? get convertedAmount => _convertedAmount;

  ExchangeRate? _lastRate;
  ExchangeRate? get lastRate => _lastRate;

  bool _rateFromCache = false;
  bool get rateFromCache => _rateFromCache;

  LoadingState _loadingState = LoadingState.idle;
  LoadingState get loadingState => _loadingState;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _errorCode;
  String? get errorCode => _errorCode;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  Locale? _locale;
  Locale? get locale => _locale;

  AppState({
    required ConversionService conversionService,
    required CurrencyCatalogService catalogService,
    required FavoritesService favoritesService,
    required CacheService cacheService,
    Iterable<Locale> Function()? systemLocales,
  })  : _conversionService = conversionService,
        _catalogService = catalogService,
        _favoritesService = favoritesService,
        _cacheService = cacheService,
        _systemLocales = systemLocales ??
            (() => WidgetsBinding.instance.platformDispatcher.locales);

  List<Currency> get favoriteCurrencies {
    return _favoritesService.favorites
        .map((code) => _currencies.firstWhere(
              (c) => c.isoCode.toLowerCase() == code,
              orElse: () => Currency(isoCode: code.toUpperCase(), name: code),
            ))
        .toList();
  }

  Future<void> initialize() async {
    _setLoading();
    try {
      await _loadLocale();
      _loadThemeMode();
      _currencies = await _catalogService.getCurrencies(
        locale: _effectiveLocale,
      );
      _favoritesService.load();
      _setIdle();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void setBaseCurrency(Currency currency) {
    _baseCurrency = currency;
    notifyListeners();
    convert();
  }

  void setTargetCurrency(Currency currency) {
    _targetCurrency = currency;
    notifyListeners();
    convert();
  }

  void setCurrencyPair({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) {
    _baseCurrency = baseCurrency;
    _targetCurrency = targetCurrency;
    notifyListeners();
    convert();
  }

  void setInputAmount(double amount) {
    _inputAmount = amount;
    notifyListeners();
    convert();
  }

  void setSelectedTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _cacheService.putString(
        AppConfig.themeModeKey, _serializeThemeMode(mode));
  }

  Future<void> setLocale(Locale? locale) async {
    // Normalize locale to a simple code for storage: 'en', 'zh_Hans', 'zh_Hant'
    String? code;
    if (locale == null) {
      code = null;
    } else if (locale.languageCode == 'zh' && locale.scriptCode != null) {
      code = 'zh_${locale.scriptCode}';
    } else {
      code = locale.languageCode;
    }

    if ((_locale?.languageCode == locale?.languageCode) &&
        (_locale?.scriptCode == locale?.scriptCode)) {
      return;
    }

    _locale = locale;
    notifyListeners();
    await _cacheService.setLocaleCode(code);

    if (_currencies.isNotEmpty) {
      // Remember previously selected currencies by ISO code so we can
      // re-resolve them after reloading the catalog in the new locale.
      final oldBaseIso = _baseCurrency?.isoCode;
      final oldTargetIso = _targetCurrency?.isoCode;

      _currencies = await _catalogService.getCurrencies(
        locale: _effectiveLocale,
      );

      if (_currencies.isNotEmpty) {
        if (oldBaseIso != null) {
          _baseCurrency = _currencies.firstWhere(
              (c) => c.isoCode.toLowerCase() == oldBaseIso.toLowerCase(),
              orElse: () => _baseCurrency ?? _currencies.first);
        }

        if (oldTargetIso != null) {
          _targetCurrency = _currencies.firstWhere(
              (c) => c.isoCode.toLowerCase() == oldTargetIso.toLowerCase(),
              orElse: () =>
                  _targetCurrency ??
                  (_currencies.length > 1
                      ? _currencies.firstWhere(
                          (c) =>
                              c.isoCode.toLowerCase() !=
                              oldBaseIso?.toLowerCase(),
                          orElse: () => _currencies.first)
                      : _currencies.first));
        }
      }

      notifyListeners();
    }
  }

  Locale? get _effectiveLocale => _locale ?? _resolveSystemLocale();

  Future<void> _loadLocale() async {
    final code = _cacheService.getLocaleCode();
    if (code == null) {
      _locale = _resolveSystemLocale();
      return;
    }

    if (code.startsWith('zh_')) {
      final parts = code.split('_');
      if (parts.length >= 2) {
        _locale = Locale.fromSubtags(languageCode: 'zh', scriptCode: parts[1]);
        return;
      }
    }

    _locale = Locale(code);
  }

  Locale? _resolveSystemLocale() {
    for (final locale in _systemLocales()) {
      final chineseLocale = _resolveChineseLocale(locale);
      if (chineseLocale != null) return chineseLocale;

      final exactMatch =
          _matchSupportedLocale(locale, allowLanguageOnly: false);
      if (exactMatch != null) return exactMatch;

      final languageMatch =
          _matchSupportedLocale(locale, allowLanguageOnly: true);
      if (languageMatch != null) return languageMatch;
    }
    return null;
  }

  Locale? _resolveChineseLocale(Locale locale) {
    if (locale.languageCode != 'zh') return null;

    final preferredScript = _preferredChineseScript(locale);
    if (preferredScript == null) return null;

    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode != 'zh') continue;
      if (supported.scriptCode == preferredScript) return supported;
    }

    return null;
  }

  String? _preferredChineseScript(Locale locale) {
    final scriptCode = locale.scriptCode;
    if (scriptCode == 'Hans' || scriptCode == 'Hant') {
      return scriptCode;
    }

    switch (locale.countryCode?.toUpperCase()) {
      case 'HK':
      case 'MO':
      case 'TW':
        return 'Hant';
      case 'CN':
      case 'SG':
      case 'MY':
        return 'Hans';
    }

    return null;
  }

  Locale? _matchSupportedLocale(
    Locale locale, {
    required bool allowLanguageOnly,
  }) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (locale.languageCode != supported.languageCode) continue;

      final scriptsMatch = locale.scriptCode == supported.scriptCode;
      final countriesMatch = supported.countryCode == null ||
          locale.countryCode == null ||
          locale.countryCode == supported.countryCode;

      if (scriptsMatch && countriesMatch) return supported;
      if (allowLanguageOnly &&
          supported.scriptCode == null &&
          supported.countryCode == null) {
        return supported;
      }
    }
    return null;
  }

  void swapCurrencies() {
    final tmp = _baseCurrency;
    _baseCurrency = _targetCurrency;
    _targetCurrency = tmp;
    notifyListeners();
    convert();
  }

  Future<void> convert() async {
    if (_baseCurrency == null || _targetCurrency == null) return;
    if (_inputAmount <= 0) {
      _convertedAmount = 0;
      notifyListeners();
      return;
    }

    try {
      final result = await _conversionService.convert(
        _inputAmount,
        _baseCurrency!.isoCode,
        _targetCurrency!.isoCode,
      );
      _convertedAmount = result.amount;
      _lastRate = result.rate;
      _rateFromCache = result.fromCache;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> refreshRates() async {
    if (_baseCurrency == null) return;
    _setLoading();
    try {
      await _conversionService.refreshRates(_baseCurrency!.isoCode);
      _setIdle();
      await convert();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleFavorite(String isoCode) async {
    await _favoritesService.toggle(isoCode);
    notifyListeners();
  }

  bool isFavorite(String isoCode) => _favoritesService.isFavorite(isoCode);

  void _setLoading() {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  void _setIdle() {
    _loadingState = LoadingState.idle;
    notifyListeners();
  }

  void _setError(String message) {
    // Keep the original technical message in logs for debugging
    // and show a concise, layman-friendly message to users.
    final friendly = _friendlyMessageFor(message);
    debugPrint('Error (technical): $message');

    _loadingState = LoadingState.error;
    _errorMessage = friendly;
    _errorCode = _errorCodeFor(message);
    notifyListeners();
  }

  String _friendlyMessageFor(String raw) {
    final lower = raw.toLowerCase();

    // Network/DNS related issues
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('host lookup') ||
        lower.contains('network is unreachable') ||
        (lower.contains('os error') && lower.contains('errno'))) {
      return 'Network error — unable to reach the server. Please check your internet connection and try again.';
    }

    // Specific common cases: API or update server unreachable
    if (lower.contains('api.github.com') || lower.contains('currency-api')) {
      return 'Unable to reach the remote service right now. Please try again later.';
    }

    // Generic fallback: short friendly message
    return 'Something went wrong. Please try again.';
  }

  String _errorCodeFor(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('host lookup') ||
        lower.contains('network is unreachable') ||
        (lower.contains('os error') && lower.contains('errno'))) {
      return 'error_network_unavailable';
    }

    if (lower.contains('api.github.com') || lower.contains('currency-api')) {
      return 'error_service_unavailable';
    }

    return 'error_generic';
  }

  void _loadThemeMode() {
    final raw = _cacheService.getString(AppConfig.themeModeKey);
    _themeMode = _parseThemeMode(raw);
  }

  ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
