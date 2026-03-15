import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/encyclopedia_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';

class _FakeExchangeClient extends ExchangeClient {
  _FakeExchangeClient();

  @override
  Future<Map<String, String>> fetchCurrencyCatalog() async => {
        'usd': 'us dollar',
        'eur': 'euro',
        'jpy': 'japanese yen',
      };

  @override
  Future<Map<String, double>> fetchRatesFor(String base) async => {'usd': 1.0};
}

class _StubCacheService extends CacheService {
  final List<String> _favorites = [];

  @override
  Future<void> init() async {}

  @override
  List<String> getFavorites() => List.unmodifiable(_favorites);

  @override
  Future<void> putFavorites(List<String> favorites) async {
    _favorites
      ..clear()
      ..addAll(favorites);
  }

  @override
  String? getString(String key) => null;

  @override
  Future<void> putString(String key, String value) async {}

  @override
  ({Map<String, String>? catalog, DateTime? timestamp, bool stale})
      getCachedCatalog({int ttlHours = 12}) {
    return (catalog: null, timestamp: null, stale: true);
  }

  @override
  Future<void> putCurrencyCatalog(
    Map<String, String> catalog,
    DateTime timestamp,
  ) async {}

  @override
  ({Map<String, double>? rates, DateTime? timestamp, bool stale})
      getCachedRates(
    String base, {
    int ttlHours = 12,
  }) {
    return (rates: null, timestamp: null, stale: true);
  }

  @override
  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {}
}

class _FakeCurrencyCatalogService extends CurrencyCatalogService {
  _FakeCurrencyCatalogService({required super.client, required super.cache});

  @override
  Future<List<Currency>> getCurrencies({bool forceRefresh = false}) async {
    return [
      Currency(
        isoCode: 'USD',
        name: 'US Dollar',
        regions: const ['United States'],
      ),
      Currency(
        isoCode: 'EUR',
        name: 'Euro',
        regions: const ['Eurozone'],
      ),
      Currency(
        isoCode: 'JPY',
        name: 'Japanese Yen',
        regions: const ['Japan'],
      ),
    ];
  }
}

void main() {
  testWidgets('encyclopedia flow: initialize, search, open detail',
      (tester) async {
    final cache = _StubCacheService();
    final exchange = _FakeExchangeClient();
    final catalog = _FakeCurrencyCatalogService(client: exchange, cache: cache);
    final favorites = FavoritesService(cache: cache);
    final conversion = ConversionService(client: exchange, cache: cache);

    final state = AppState(
      conversionService: conversion,
      catalogService: catalog,
      favoritesService: favorites,
      cacheService: cache,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: EncyclopediaScreen()),
      ),
    );

    await state.initialize();
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'yen');
    await tester.pumpAndSettle();

    expect(find.text('JPY'), findsOneWidget);
    expect(find.text('USD'), findsNothing);

    await tester.tap(find.text('JPY'));
    await tester.pumpAndSettle();

    expect(find.text('ISO Code'), findsOneWidget);
    expect(find.text('JPY'), findsNWidgets(2));
    expect(find.text('Japanese Yen'), findsOneWidget);
  });
}
