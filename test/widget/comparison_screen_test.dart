import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/cached_catalog.dart';
import 'package:openfxpedia/models/cached_rate_snapshot.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/comparison_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/exchange_provider.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:provider/provider.dart';

final _currencies = [
  Currency(isoCode: 'USD', name: 'US Dollar'),
  Currency(isoCode: 'EUR', name: 'Euro'),
  Currency(isoCode: 'GBP', name: 'Pound Sterling'),
];

class _RateClient extends ExchangeClient {
  int latestCalls = 0;

  @override
  Future<ExchangeRateSnapshot> fetchRateSnapshotFor(
    String base, {
    String? target,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    latestCalls++;
    return ExchangeRateSnapshot(
      baseCurrency: base.toLowerCase(),
      quotedAt: DateTime.utc(2026, 10, 30),
      sourceId: 'frankfurter',
      rates: {'eur': 0.92, 'gbp': 0.79},
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
  CachedRateSnapshot getCachedRateSnapshot(String base, {int ttlHours = 12}) =>
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
}

class _StubCatalog extends CurrencyCatalogService {
  _StubCatalog({required super.client, required super.cache});

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async => _currencies;
}

void main() {
  testWidgets('compares selected currencies against one base snapshot', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ComparisonScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Compare rates'), findsOneWidget);
    expect(find.text('Rate per 1 USD'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(client.latestCalls, 1);

    await tester.tap(find.byKey(const Key('comparison-select-currencies')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('comparison-currency-GBP')));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Pound Sterling'), findsOneWidget);
    expect(client.latestCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
