import 'package:flutter/material.dart';
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

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  AppState({
    required ConversionService conversionService,
    required CurrencyCatalogService catalogService,
    required FavoritesService favoritesService,
    required CacheService cacheService,
  })  : _conversionService = conversionService,
        _catalogService = catalogService,
        _favoritesService = favoritesService,
        _cacheService = cacheService;

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
      _loadThemeMode();
      _currencies = await _catalogService.getCurrencies();
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
    notifyListeners();
  }

  void _setIdle() {
    _loadingState = LoadingState.idle;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
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
