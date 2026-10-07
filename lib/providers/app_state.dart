import 'dart:async';

import 'package:flutter/material.dart';
import '../core/config.dart';
import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../services/cache_service.dart';
import '../services/conversion_service.dart';
import '../services/currency_catalog.dart';
import '../services/error_classifier.dart';
import '../services/exchange_api_source.dart';
import '../services/favorites_service.dart';
import '../services/locale_resolver.dart';
import '../services/rate_history_service.dart';

enum LoadingState { idle, loading, error }

class AppState extends ChangeNotifier {
  final ConversionService _conversionService;
  final CurrencyCatalogService _catalogService;
  final FavoritesService _favoritesService;
  final CacheService _cacheService;
  final Iterable<Locale> Function() _systemLocales;
  int _conversionRequestSequence = 0;

  List<Currency> _currencies = [];
  List<Currency> get currencies => _currencies;

  Currency? _baseCurrency;
  Currency? _targetCurrency;
  Currency? get baseCurrency => _baseCurrency;
  Currency? get targetCurrency => _targetCurrency;

  double _inputAmount = 1.0;
  double get inputAmount => _inputAmount;

  DateTime? _conversionDate;
  DateTime? get conversionDate => _conversionDate;

  bool _historyVisible = false;
  bool get historyVisible => _historyVisible;
  bool _historyLoading = false;
  bool get historyLoading => _historyLoading;
  int _historyDays = 30;
  int get historyDays => _historyDays;
  int _historyRequestSequence = 0;
  String? _historyKey;
  List<RateHistorySample> _historySamples = [];
  List<RateHistorySample> get historySamples =>
      List.unmodifiable(_historySamples);

  void setHistoryVisible(bool visible) {
    _historyVisible = visible;
    if (visible) {
      unawaited(loadHistory());
    } else {
      _historyRequestSequence++;
      _historyKey = null;
      _historyLoading = false;
    }
    notifyListeners();
  }

  void setHistoryDays(int days) {
    if (![7, 30, 90].contains(days)) throw ArgumentError.value(days, 'days');
    if (_historyDays == days) return;
    _historyDays = days;
    unawaited(loadHistory());
  }

  Future<void> loadHistory({bool forceRefresh = false}) async {
    if (!_historyVisible || _baseCurrency == null || _targetCurrency == null) {
      return;
    }
    final base = _baseCurrency!.isoCode;
    final target = _targetCurrency!.isoCode;
    final date = DateUtils.dateOnly(_conversionDate ?? DateTime.now());
    final key = '$base:$target:$date:$_historyDays:$_exchangeApiSource';
    if (!forceRefresh && key == _historyKey) return;
    _historyKey = key;
    final requestId = ++_historyRequestSequence;
    _historySamples = [];
    _historyLoading = true;
    notifyListeners();
    final samples = await RateHistoryService(_conversionService).load(
      base: base,
      target: target,
      endDate: date,
      days: _historyDays,
      forceRefresh: forceRefresh,
      isCancelled: () => requestId != _historyRequestSequence,
    );
    if (requestId != _historyRequestSequence) return;
    _historySamples = samples;
    _historyLoading = false;
    notifyListeners();
  }

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
  ExchangeApiSource _exchangeApiSource = ExchangeApiSource.auto;
  ExchangeApiSource get exchangeApiSource => _exchangeApiSource;

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

  Future<bool> initialize() async {
    _setLoading();
    try {
      await _loadLocale();
      _loadThemeMode();
      _loadExchangeApiSource();
      _currencies = await _catalogService.getCurrencies(
        locale: _effectiveLocale,
      );
      _favoritesService.load();
      _setIdle();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void setBaseCurrency(Currency currency) {
    _baseCurrency = currency;
    notifyListeners();
    convert();
  }

  void setBaseCurrencyAndAmount(Currency currency, double amount) {
    _baseCurrency = currency;
    _inputAmount = amount;
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

  Future<void> setExchangeApiSource(ExchangeApiSource source) async {
    if (_exchangeApiSource == source) return;

    _exchangeApiSource = source;
    _conversionService.setPreferredSource(source);
    notifyListeners();

    await _cacheService.putString(
      AppConfig.exchangeApiSourceKey,
      source.storageValue,
    );

    await convert();
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

  Locale? _resolveSystemLocale() =>
      LocaleResolver.resolveSystemLocale(_systemLocales());

  void swapCurrencies() {
    final tmp = _baseCurrency;
    _baseCurrency = _targetCurrency;
    _targetCurrency = tmp;
    notifyListeners();
    convert();
  }

  Future<void> setConversionDate(DateTime? date) async {
    final normalized = date == null ? null : DateUtils.dateOnly(date);
    if (normalized != null &&
        normalized.isAfter(DateUtils.dateOnly(DateTime.now()))) {
      throw ArgumentError.value(date, 'date', 'Cannot select a future date');
    }
    if (_conversionDate == normalized) return;
    _conversionDate = normalized;
    await convert();
  }

  Future<void> convert({bool forceHistoricalRefresh = false}) async {
    final requestId = ++_conversionRequestSequence;
    unawaited(loadHistory());
    final requestedDate = _conversionDate;
    _convertedAmount = null;
    _lastRate = null;
    _rateFromCache = false;
    _errorMessage = null;
    _errorCode = null;
    _loadingState = LoadingState.idle;
    if (_baseCurrency == null || _targetCurrency == null) {
      notifyListeners();
      return;
    }
    if (_inputAmount <= 0) {
      _convertedAmount = 0;
      notifyListeners();
      return;
    }

    _setLoading();

    try {
      final result = requestedDate == null
          ? await _conversionService.convert(
              _inputAmount,
              _baseCurrency!.isoCode,
              _targetCurrency!.isoCode,
            )
          : await _conversionService.convertHistorical(
              _inputAmount,
              _baseCurrency!.isoCode,
              _targetCurrency!.isoCode,
              requestedDate,
              forceRefresh: forceHistoricalRefresh,
            );

      if (requestId != _conversionRequestSequence) {
        return;
      }

      _convertedAmount = result.amount;
      _lastRate = result.rate;
      _rateFromCache = result.fromCache;
      _errorMessage = null;
      _errorCode = null;
      _loadingState = LoadingState.idle;
      notifyListeners();
    } catch (e) {
      if (requestId != _conversionRequestSequence) {
        return;
      }

      _setError(e.toString(),
          code: requestedDate == null ? null : 'error_historical_unavailable');
    }
  }

  Future<void> refreshRates() async {
    if (_baseCurrency == null) return;
    if (_conversionDate != null) {
      await convert(forceHistoricalRefresh: true);
      return;
    }
    _setLoading();

    final requestId = ++_conversionRequestSequence;

    try {
      await _conversionService.refreshRates(_baseCurrency!.isoCode);

      if (requestId != _conversionRequestSequence) {
        return;
      }

      _setIdle();
      await convert();
    } catch (e) {
      if (requestId != _conversionRequestSequence) {
        return;
      }

      _setError(e.toString());
    }
  }

  Future<void> toggleFavorite(String isoCode) async {
    await _favoritesService.toggle(isoCode);
    notifyListeners();
  }

  bool isFavorite(String isoCode) => _favoritesService.isFavorite(isoCode);

  Future<void> clearLocalData() async {
    _conversionRequestSequence++;
    _historyRequestSequence++;
    _historyVisible = false;
    _historyLoading = false;
    _historyKey = null;
    _historySamples = [];
    _conversionService.invalidatePendingCacheWrites();
    await _cacheService.clearAll();
    _favoritesService.load();
    _baseCurrency = null;
    _targetCurrency = null;
    _inputAmount = 0.0;
    _conversionDate = null;
    _convertedAmount = null;
    _lastRate = null;
    _rateFromCache = false;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    final initialized = await initialize();
    if (!initialized) {
      throw StateError('Currency catalog reload failed');
    }
  }

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

  void _setError(String message, {String? code}) {
    final friendly = _friendlyMessageFor(message);
    debugPrint('Error code: ${ErrorClassifier.codeFor(message)}');

    _loadingState = LoadingState.error;
    _errorMessage = friendly;
    _errorCode = code ?? _errorCodeFor(message);
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

  void _loadExchangeApiSource() {
    final raw = _cacheService.getString(AppConfig.exchangeApiSourceKey);
    _exchangeApiSource = ExchangeApiSourceStorage.fromStorage(raw);
    _conversionService.setPreferredSource(_exchangeApiSource);
  }

  @override
  void dispose() {
    _historyRequestSequence++;
    _conversionRequestSequence++;
    super.dispose();
  }
}
