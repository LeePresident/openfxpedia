import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/screens/converter_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';

final _usd = Currency(isoCode: 'USD', name: 'US Dollar');
final _eur = Currency(isoCode: 'EUR', name: 'Euro');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'chart opens on demand, changes range and refreshes independently',
      (tester) async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache);
    final state = _state(cache, conversion);
    addTearDown(state.dispose);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    await state.setConversionDate(DateTime(2024, 3, 10));
    await tester.pumpWidget(_Harness(state));
    await tester.pumpAndSettle();
    expect(find.byType(LineChart), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('history-toggle'))).height,
        greaterThanOrEqualTo(48));
    await tester.ensureVisible(find.byKey(const Key('history-toggle')));
    await tester.tap(find.text('Rate history'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(state.historySamples.length, 8);
    expect(state.historySamples.last.requestedDate, DateTime.utc(2024, 3, 10));
    await tester.ensureVisible(find.text('1W'));
    await tester.tap(find.text('1W'));
    await tester.pumpAndSettle();
    expect(state.historyDays, 7);
    expect(state.historySamples.length, 7);
    expect(find.text('Sampled quotes: 3/7'), findsOneWidget);
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.minY, lessThan(chart.data.maxY));
    expect(
        chart.data.lineBarsData.single.spots
            .where((spot) => !spot.isNull())
            .length,
        1);
    final amount = state.convertedAmount;
    await tester.ensureVisible(find.byKey(const Key('history-refresh')));
    await tester.tap(find.byKey(const Key('history-refresh')));
    await tester.pumpAndSettle();
    expect(conversion.forceRefresh, isTrue);
    expect(state.convertedAmount, amount);
    final samples = state.historySamples;
    state.setInputAmount(0);
    await tester.pumpAndSettle();
    expect(state.historySamples, samples);
    expect(state.convertedAmount, 0);
    await tester.ensureVisible(find.text('Rate history'));
    await tester.tap(find.text('Rate history'));
    await tester.pumpAndSettle();
    expect(state.historyVisible, isFalse);
    expect(find.byType(LineChart), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable chart range does not replace the conversion result',
      (tester) async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache);
    final state = _state(cache, conversion);
    addTearDown(state.dispose);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    await state.convert();
    final amount = state.convertedAmount;
    conversion.fail = true;
    state.setHistoryVisible(true);
    await tester.pumpWidget(_Harness(state));
    await tester.pumpAndSettle();
    expect(state.historyLoading, isFalse);
    expect(find.byType(LineChart), findsNothing);
    expect(
        find.textContaining('No historical quotes available'), findsOneWidget);
    expect(state.convertedAmount, amount);
    expect(state.errorCode, isNull);
    expect(tester.takeException(), isNull);
  });

  test('new range ignores old chart responses and close cancels pending work',
      () async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache);
    final state = _state(cache, conversion);
    addTearDown(state.dispose);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    await state.setConversionDate(DateTime(2024, 3, 10));
    conversion.holdRequests = true;
    state.setHistoryVisible(true);
    state.setHistoryDays(7);
    expect(conversion.pending.length, 2);
    conversion.holdRequests = false;
    conversion.pending[1].complete(_result(DateTime.utc(2024, 3, 4), 0.9));
    await Future<void>.delayed(Duration.zero);
    expect(state.historySamples.length, 7);
    conversion.pending[0].complete(_result(DateTime.utc(2024, 2, 10), 0.9));
    await Future<void>.delayed(Duration.zero);
    expect(state.historySamples.length, 7);
    expect(state.historySamples.first.requestedDate, DateTime.utc(2024, 3, 4));
    conversion.holdRequests = true;
    final refresh = state.loadHistory(forceRefresh: true);
    state.setHistoryVisible(false);
    conversion.pending.last.complete(_result(DateTime.utc(2024, 3, 4), 0.9));
    await refresh;
    expect(state.historySamples, isEmpty);
    expect(state.historyLoading, isFalse);
    expect(conversion.pending.length, 3);
  });

  testWidgets(
      'date picker selects history, cancels safely and returns to latest',
      (tester) async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache);
    final state = _state(cache, conversion);
    addTearDown(state.dispose);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    state.setInputAmount(10);
    await tester.pumpWidget(_Harness(state));
    await tester.pumpAndSettle();
    expect(find.text('Conversion date: Latest'), findsOneWidget);
    await tester.tap(find.byKey(const Key('conversion-date')));
    await tester.pumpAndSettle();
    final picker =
        tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
    final material =
        MaterialLocalizations.of(tester.element(find.byType(DatePickerDialog)));
    await tester.tap(find.byTooltip(material.inputDateModeButtonLabel));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: find.byType(DatePickerDialog),
            matching: find.byType(TextField)),
        material.formatCompactDate(DateTime(2024, 3, 10)));
    await tester.tap(find.text(material.okButtonLabel));
    await tester.pumpAndSettle();
    expect(state.conversionDate, DateTime(2024, 3, 10));
    expect(find.text('Requested date: Mar 10, 2024'), findsOneWidget);
    expect(find.textContaining('Rate date: Mar 8, 2024'), findsOneWidget);
    expect(find.text('9.0 EUR'), findsOneWidget);
    await tester.tap(find.byKey(const Key('conversion-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(material.cancelButtonLabel));
    await tester.pumpAndSettle();
    expect(state.conversionDate, DateTime(2024, 3, 10));
    await tester.tap(find.byKey(const Key('conversion-use-latest')));
    await tester.pumpAndSettle();
    expect(state.conversionDate, isNull);
    expect(state.inputAmount, 10);
    expect(state.baseCurrency!.isoCode, 'USD');
    expect(state.targetCurrency!.isoCode, 'EUR');
    expect(find.text('Conversion date: Latest'), findsOneWidget);
    expect(find.textContaining('Requested date:'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ]) {
    testWidgets('historical metadata and errors fit narrow layout in $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cache = _MemoryCache();
      final conversion = _Conversion(cache);
      final state = _state(cache, conversion);
      addTearDown(state.dispose);
      await state.initialize();
      state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
      await state.setConversionDate(DateTime(2024, 3, 10));
      state.setHistoryVisible(true);
      await tester.pumpWidget(_Harness(state));
      await state.setLocale(locale);
      await state.setThemeMode(ThemeMode.dark);
      state.setSelectedTab(1);
      state.setSelectedTab(0);
      await tester.pumpAndSettle();
      final l10n =
          AppLocalizations.of(tester.element(find.byType(ConverterScreen)));
      final formatter = DateFormat.yMMMd(l10n.localeName);
      final effectiveDate = l10n.rate_info_effective_date(
        formatter.format(DateTime.utc(2024, 3, 8)),
      );
      expect(
          find.text(l10n.rate_info_requested_date(
              formatter.format(DateTime(2024, 3, 10)))),
          findsOneWidget);
      expect(find.textContaining(effectiveDate), findsOneWidget);
      expect(state.conversionDate, DateTime(2024, 3, 10));
      expect(find.byType(LineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
      conversion.fail = true;
      await state.setConversionDate(DateTime(2024, 3, 11));
      await tester.pumpAndSettle();
      expect(find.text(l10n.error_historical_unavailable), findsOneWidget);
      expect(find.textContaining(effectiveDate), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  test('date changes ignore old results and refresh keeps the date', () async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache)..holdRequests = true;
    final state = _state(cache, conversion);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    final historical = state.setConversionDate(DateTime(2024, 3, 10));
    expect(state.lastRate, isNull);
    expect(state.convertedAmount, isNull);
    expect(state.loadingState, LoadingState.loading);
    conversion.pending[1].complete(_result(DateTime.utc(2024, 3, 8), 0.9));
    await historical;
    conversion.pending[0].complete(_result(DateTime.utc(2026, 5, 8), 0.8));
    await Future<void>.delayed(Duration.zero);
    expect(state.lastRate!.timestamp, DateTime.utc(2024, 3, 8));
    expect(state.convertedAmount, 0.9);
    conversion.holdRequests = false;
    await state.refreshRates();
    expect(conversion.lastDate, DateTime(2024, 3, 10));
    expect(conversion.forceRefresh, isTrue);
    await state.setConversionDate(null);
    expect(state.conversionDate, isNull);
    expect(conversion.lastDate, isNull);
    state.dispose();
  });

  test('date selection and zero amount invalidate pending results', () async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache)..holdRequests = true;
    final state = _state(cache, conversion);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    state.setInputAmount(0);
    await state.setConversionDate(DateTime(2024, 3, 10));
    conversion.pending.single.complete(_result(DateTime.utc(2026, 5, 8), 0.8));
    await Future<void>.delayed(Duration.zero);
    expect(state.convertedAmount, 0);
    expect(state.lastRate, isNull);
    expect(state.loadingState, LoadingState.idle);
    state.dispose();
  });

  test(
      'unavailable historical date clears old quote and reports specific error',
      () async {
    final cache = _MemoryCache();
    final conversion = _Conversion(cache);
    final state = _state(cache, conversion);
    await state.initialize();
    state.setCurrencyPair(baseCurrency: _usd, targetCurrency: _eur);
    await state.convert();
    conversion.fail = true;
    await state.setConversionDate(DateTime(2024, 3, 10));
    expect(state.lastRate, isNull);
    expect(state.convertedAmount, isNull);
    expect(state.errorCode, 'error_historical_unavailable');
    state.dispose();
  });
}

class _Harness extends StatelessWidget {
  const _Harness(this.state);
  final AppState state;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: state,
        child: Consumer<AppState>(
            builder: (context, state, _) => MaterialApp(
                  locale: state.locale,
                  themeMode: state.themeMode,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const ConverterScreen(),
                )),
      );
}

AppState _state(_MemoryCache cache, _Conversion conversion) => AppState(
      conversionService: conversion,
      catalogService: _Catalog(cache),
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
      systemLocales: () => const [Locale('en')],
    );

ConversionResult _result(DateTime date, double amount) => ConversionResult(
      amount: amount,
      rate: ExchangeRate(
          baseCurrency: 'usd',
          targetCurrency: 'eur',
          rate: 0.9,
          timestamp: date,
          source: 'frankfurter'),
      fromCache: false,
    );

class _Conversion extends ConversionService {
  _Conversion(CacheService cache)
      : super(client: ExchangeClient(), cache: cache);
  bool holdRequests = false;
  bool fail = false;
  bool forceRefresh = false;
  DateTime? lastDate;
  final pending = <Completer<ConversionResult>>[];

  Future<ConversionResult> _request(DateTime? date, double amount) async {
    lastDate = date;
    if (fail) throw ExchangeApiException('Unavailable');
    if (holdRequests) {
      final completer = Completer<ConversionResult>();
      pending.add(completer);
      return completer.future;
    }
    return _result(
        date == null ? DateTime.utc(2026, 5, 8) : DateTime.utc(2024, 3, 8),
        amount * 0.9);
  }

  @override
  Future<ConversionResult> convert(double amount, String base, String target) =>
      _request(null, amount);

  @override
  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) {
    this.forceRefresh = forceRefresh;
    return _request(date, amount);
  }
}

class _Catalog extends CurrencyCatalogService {
  _Catalog(CacheService cache) : super(client: ExchangeClient(), cache: cache);

  @override
  Future<List<Currency>> getCurrencies(
          {bool forceRefresh = false, Locale? locale}) async =>
      [_usd, _eur];
}

class _MemoryCache extends CacheService {
  final _strings = <String, String>{};

  @override
  String? getString(String key) => _strings[key];

  @override
  Future<void> putString(String key, String value) async {
    _strings[key] = value;
  }

  @override
  String? getLocaleCode() => null;

  @override
  Future<void> setLocaleCode(String? code) async {}

  @override
  List<String> getFavorites() => [];
}
