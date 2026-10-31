import 'dart:async';

import 'package:flutter/material.dart';
import '../models/calculator_entry.dart';
import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../services/cache_service.dart';
import '../services/conversion_service.dart';
import '../services/currency_catalog.dart';
import '../services/exchange_api_source.dart';
import '../services/favorites_service.dart';
import '../services/rate_history_service.dart';
import 'calculator_state.dart';
import 'converter_state.dart';
import 'rate_history_state.dart';
import 'user_preferences_state.dart';

export 'converter_state.dart' show LoadingState;

class AppState extends ChangeNotifier {
  final ConversionService _conversionService;
  final CurrencyCatalogService _catalogService;
  final FavoritesService _favoritesService;
  final CacheService _cacheService;
  int _localeRequestSequence = 0;
  late final UserPreferencesState _preferencesState;
  late final ConverterState _converterState;
  late final CalculatorState _calculatorState;
  late final RateHistoryState _rateHistoryState;

  List<Currency> _currencies = [];
  List<Currency> get currencies => _currencies;

  List<CalculatorEntry> get calculatorEntries => _calculatorState.entries;
  String? get calculatorOutputCurrencyCode =>
      _calculatorState.outputCurrencyCode;
  Currency? get calculatorOutputCurrency => _calculatorState.outputCurrency;
  DateTime? get calculatorDate => _calculatorState.date;
  double? get calculatorTotal => _calculatorState.total;
  Map<int, ConversionResult> get calculatorLineResults =>
      _calculatorState.lineResults;
  bool get calculatorLoading => _calculatorState.loading;
  String? get calculatorErrorCode => _calculatorState.errorCode;

  Currency? get baseCurrency => _converterState.baseCurrency;
  Currency? get targetCurrency => _converterState.targetCurrency;
  double get inputAmount => _converterState.inputAmount;
  DateTime? get conversionDate => _converterState.conversionDate;

  bool get historyVisible => _rateHistoryState.visible;
  bool get historyLoading => _rateHistoryState.loading;
  int get historyDays => _rateHistoryState.days;
  List<RateHistorySample> get historySamples => _rateHistoryState.samples;

  void setHistoryVisible(bool visible) {
    _rateHistoryState.setVisible(visible);
    if (visible) {
      unawaited(loadHistory());
    }
  }

  void setHistoryDays(int days) {
    if (!_rateHistoryState.setDays(days)) return;
    unawaited(loadHistory());
  }

  Future<void> loadHistory({bool forceRefresh = false}) async {
    final base = _converterState.baseCurrency;
    final target = _converterState.targetCurrency;
    if (base == null || target == null) return;
    await _rateHistoryState.load(
      base: base.isoCode,
      target: target.isoCode,
      endDate: _converterState.conversionDate ?? DateTime.now(),
      source: _preferencesState.exchangeApiSource,
      forceRefresh: forceRefresh,
    );
  }

  double? get convertedAmount => _converterState.convertedAmount;
  ExchangeRate? get lastRate => _converterState.lastRate;
  bool get rateFromCache => _converterState.rateFromCache;
  LoadingState get loadingState => _converterState.loadingState;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  String? get errorCode => _converterState.errorCode;

  ThemeMode get themeMode => _preferencesState.themeMode;
  Locale? get locale => _preferencesState.locale;
  ExchangeApiSource get exchangeApiSource =>
      _preferencesState.exchangeApiSource;

  AppState({
    required ConversionService conversionService,
    required CurrencyCatalogService catalogService,
    required FavoritesService favoritesService,
    required CacheService cacheService,
    Iterable<Locale> Function()? systemLocales,
  }) : _conversionService = conversionService,
       _catalogService = catalogService,
       _favoritesService = favoritesService,
       _cacheService = cacheService {
    _preferencesState = UserPreferencesState(
      cacheService: _cacheService,
      systemLocales:
          systemLocales ??
          (() => WidgetsBinding.instance.platformDispatcher.locales),
      onChanged: notifyListeners,
    );
    _converterState = ConverterState(
      conversionService: _conversionService,
      onChanged: notifyListeners,
      onHistoryRefresh: () => unawaited(loadHistory()),
    );
    _calculatorState = CalculatorState(
      conversionService: _conversionService,
      currencies: () => _currencies,
      onChanged: notifyListeners,
    );
    _rateHistoryState = RateHistoryState(
      conversionService: _conversionService,
      onChanged: notifyListeners,
    );
  }

  List<Currency> get favoriteCurrencies {
    return _favoritesService.favorites
        .map(
          (code) => _currencies.firstWhere(
            (c) => c.isoCode.toLowerCase() == code,
            orElse: () => Currency(isoCode: code.toUpperCase(), name: code),
          ),
        )
        .toList();
  }

  Future<bool> initialize() async {
    _setLoading();
    try {
      _preferencesState.load();
      _conversionService.setPreferredSource(
        _preferencesState.exchangeApiSource,
      );
      _currencies = await _catalogService.getCurrencies(
        locale: _preferencesState.effectiveLocale,
      );
      _initializeCalculator();
      await calculateCalculator();
      _favoritesService.load();
      _setIdle();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  void setBaseCurrency(Currency currency) {
    _converterState.setBaseCurrency(currency);
  }

  void setBaseCurrencyAndAmount(Currency currency, double amount) {
    _converterState.setBaseCurrencyAndAmount(currency, amount);
  }

  void setTargetCurrency(Currency currency) {
    _converterState.setTargetCurrency(currency);
  }

  void setCurrencyPair({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) {
    _converterState.setCurrencyPair(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );
  }

  void setInputAmount(double amount) => _converterState.setInputAmount(amount);

  void setSelectedTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _preferencesState.setThemeMode(mode);

  Future<void> setExchangeApiSource(ExchangeApiSource source) async {
    if (!_preferencesState.selectExchangeApiSource(source)) return;
    _conversionService.setPreferredSource(source);
    await _preferencesState.persistExchangeApiSource();

    await convert();
    await calculateCalculator();
  }

  Future<void> setLocale(Locale? locale) async {
    if (!_preferencesState.selectLocale(locale)) return;

    final requestId = ++_localeRequestSequence;
    final requestedLocale = _preferencesState.effectiveLocale;
    await _preferencesState.persistLocale();

    if (requestId == _localeRequestSequence && _currencies.isNotEmpty) {
      final currencies = await _catalogService.getCurrencies(
        locale: requestedLocale,
      );
      if (requestId != _localeRequestSequence) return;
      _currencies = currencies;
      _converterState.updateCurrencies(_currencies);

      notifyListeners();
      unawaited(calculateCalculator());
    }
  }

  void _initializeCalculator() {
    _calculatorState.initialize(
      baseCurrency: _converterState.baseCurrency,
      targetCurrency: _converterState.targetCurrency,
    );
  }

  void addCalculatorEntry() => _calculatorState.addEntry();

  void removeCalculatorEntry(int id) => _calculatorState.removeEntry(id);

  void setCalculatorEntryAmount(int id, double amount) =>
      _calculatorState.setEntryAmount(id, amount);

  void setCalculatorEntryCurrency(int id, Currency currency) =>
      _calculatorState.setEntryCurrency(id, currency);

  void setCalculatorOutputCurrency(Currency currency) =>
      _calculatorState.setOutputCurrency(currency);

  Future<void> setCalculatorDate(DateTime? date) async {
    await _calculatorState.setDate(date);
  }

  Future<void> calculateCalculator() => _calculatorState.calculate();

  Future<LatestRatesResult> loadComparisonRates(
    String base, {
    bool forceRefresh = false,
  }) => _conversionService.loadLatestRates(base, forceRefresh: forceRefresh);

  void swapCurrencies() => _converterState.swapCurrencies();

  Future<void> setConversionDate(DateTime? date) =>
      _converterState.setConversionDate(date);

  Future<void> convert({bool forceHistoricalRefresh = false}) =>
      _converterState.convert(forceHistoricalRefresh: forceHistoricalRefresh);

  Future<void> refreshRates() => _converterState.refreshRates();

  Future<void> toggleFavorite(String isoCode) async {
    await _favoritesService.toggle(isoCode);
    notifyListeners();
  }

  bool isFavorite(String isoCode) => _favoritesService.isFavorite(isoCode);

  Future<void> clearLocalData() async {
    _converterState.cancelPending();
    _calculatorState.cancelPending();
    _rateHistoryState.reset();
    _conversionService.invalidatePendingCacheWrites();
    await _cacheService.clearAll();
    _favoritesService.load();
    _converterState.reset();
    _calculatorState.reset();
    notifyListeners();

    final initialized = await initialize();
    if (!initialized) {
      throw StateError('Currency catalog reload failed');
    }
  }

  void _setLoading() => _converterState.setLoading();

  void _setIdle() => _converterState.setIdle();

  void _setError(Object error, {String? code}) =>
      _converterState.setError(error, code: code);

  @override
  void dispose() {
    _rateHistoryState.cancelPending();
    _converterState.cancelPending();
    _calculatorState.cancelPending();
    super.dispose();
  }
}
