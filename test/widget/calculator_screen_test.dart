import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/cached_catalog.dart';
import 'package:openfxpedia/models/cached_rate_snapshot.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/calculator_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_provider.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:provider/provider.dart';

final _usd = Currency(
  isoCode: 'USD',
  name: 'US Dollar',
  symbol: '\$',
  minorUnitsPerMajor: 100,
);
final _eur = Currency(
  isoCode: 'EUR',
  name: 'Euro',
  symbol: '€',
  minorUnitsPerMajor: 100,
);
final _gbp = Currency(
  isoCode: 'GBP',
  name: 'Pound Sterling',
  symbol: '£',
  minorUnitsPerMajor: 100,
);

class _RateClient extends ExchangeClient {
  DateTime? lastHistoricalDate;

  Map<String, double> _rates(String base) {
    switch (base.toLowerCase()) {
      case 'usd':
        return {'usd': 1, 'eur': 0.9, 'gbp': 0.8};
      case 'eur':
        return {'usd': 1.1, 'eur': 1, 'gbp': 0.86};
      default:
        return {'usd': 1.25, 'eur': 1.16, 'gbp': 1};
    }
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateSnapshotFor(
    String base, {
    String? target,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    return ExchangeRateSnapshot(
      baseCurrency: base.toLowerCase(),
      quotedAt: DateTime.utc(2026, 10, 6),
      sourceId: 'frankfurter',
      rates: _rates(base),
    );
  }

  @override
  Future<ExchangeRateSnapshot> fetchHistoricalRateSnapshotFor(
    String base, {
    required String target,
    required DateTime date,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    lastHistoricalDate = date;
    return ExchangeRateSnapshot(
      baseCurrency: base.toLowerCase(),
      quotedAt: DateTime.utc(date.year, date.month, date.day)
          .subtract(const Duration(days: 2)),
      sourceId: 'frankfurter',
      rates: _rates(base),
    );
  }
}

class _StubCache extends CacheService {
  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => null;

  @override
  Future<void> putString(String key, String value) async {}

  @override
  String? getLocaleCode() => null;

  @override
  Future<void> setLocaleCode(String? code) async {}

  @override
  List<String> getFavorites() => [];

  @override
  Future<void> putFavorites(List<String> favorites) async {}

  @override
  CachedCatalog getCachedCatalog({int ttlHours = 12}) =>
      const CachedCatalog(catalog: null, timestamp: null, isStale: true);

  @override
  Future<void> putCurrencyCatalog(
    Map<String, String> catalog,
    DateTime timestamp,
  ) async {}

  @override
  CachedRateSnapshot getCachedRates(String base, {int ttlHours = 12}) =>
      const CachedRateSnapshot(
        rates: null,
        timestamp: null,
        source: null,
        isStale: true,
      );

  @override
  CachedRateSnapshot getCachedRateSnapshot(
    String base, {
    int ttlHours = 12,
  }) =>
      const CachedRateSnapshot(
        rates: null,
        timestamp: null,
        source: null,
        isStale: true,
      );

  @override
  Future<void> putRateSnapshot(
    String base,
    Map<String, double> rates,
    DateTime timestamp, {
    String? source,
  }) async {}

  @override
  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {}
}

class _StubCatalog extends CurrencyCatalogService {
  _StubCatalog({required super.client, required super.cache});

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async =>
      [_usd, _eur, _gbp];
}

void main() {
  testWidgets(
      'calculator adds entries, sums in the result currency, and keeps session state',
      (tester) async {
    final cache = _StubCache();
    final client = _RateClient();
    final state = AppState(
      conversionService: ConversionService(client: client, cache: cache),
      catalogService: _StubCatalog(client: client, cache: cache),
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
      systemLocales: () => const [Locale('en')],
    );
    addTearDown(state.dispose);
    await state.initialize();
    state.setSelectedTab(1);

    await tester.pumpWidget(_Harness(state));
    expect(find.text('Calculator'), findsOneWidget);
    expect(state.calculatorEntries, hasLength(1));

    final firstEntry = state.calculatorEntries.first;
    await tester.tap(find.text('Add amount'));
    await tester.pumpAndSettle();
    expect(state.calculatorEntries, hasLength(2));
    final secondEntry = state.calculatorEntries.last;

    await tester.tap(find.descendant(
      of: find.byKey(const ValueKey('calculator-output-currency')),
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GBP'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(ValueKey('calculator-currency-${secondEntry.id}')),
    );
    await tester.tap(find.descendant(
      of: find.byKey(ValueKey('calculator-currency-${secondEntry.id}')),
      matching: find.byType(InkWell),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EUR'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(ValueKey('calculator-amount-${firstEntry.id}')),
        matching: find.byType(TextField),
      ),
      '10',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(ValueKey('calculator-amount-${secondEntry.id}')),
        matching: find.byType(TextField),
      ),
      '15',
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(state.calculatorTotal, 20.9);
    expect(state.calculatorLineResults, hasLength(2));
    expect(find.textContaining('20.90'), findsOneWidget);

    await state.setCalculatorDate(DateTime(2024, 3, 10));
    await tester.pumpAndSettle();
    expect(client.lastHistoricalDate, DateTime.utc(2024, 3, 10));
    expect(state.conversionDate, isNull);

    state.setSelectedTab(0);
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorScreen), findsNothing);
    state.setSelectedTab(1);
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorScreen), findsOneWidget);
    expect(state.calculatorEntries, hasLength(2));
    expect(state.calculatorOutputCurrencyCode, 'GBP');
    expect(state.calculatorDate, DateTime(2024, 3, 10));

    await state.setLocale(const Locale('zh'));
    await tester.pumpAndSettle();
    expect(state.calculatorEntries.map((entry) => entry.currencyCode), [
      'USD',
      'EUR',
    ]);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('移除金额').last);
    await tester.pumpAndSettle();
    expect(state.calculatorEntries, hasLength(1));
  });
}

class _Harness extends StatelessWidget {
  const _Harness(this.state);

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: state,
      child: Consumer<AppState>(
        builder: (context, currentState, _) => MaterialApp(
          locale: currentState.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: currentState.selectedTab == 1
              ? const CalculatorScreen()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
