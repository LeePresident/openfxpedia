import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/encyclopedia_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:openfxpedia/services/observability.dart';

void main() {
  testWidgets(
    'encyclopedia shows localized currency names and falls back to English for missing fields',
    (tester) async {
      LocalizationObservability.clear();

      final cache = _StubCacheService();
      final exchange = _FakeExchangeClient();
      final catalog = _FakeCurrencyCatalogService(
        client: exchange,
        cache: cache,
        bundle: _OverlayAssetBundle(
          {
            'assets/data/fiat_currency_overlays/zh_Hans.json': jsonEncode({
              'entries': {
                'USD': {
                  'name': '美元',
                },
              },
            }),
          },
        ),
      );
      final favorites = FavoritesService(cache: cache);
      final conversion = ConversionService(client: exchange, cache: cache);

      final state = AppState(
        conversionService: conversion,
        catalogService: catalog,
        favoritesService: favorites,
        cacheService: cache,
        systemLocales: () => const [
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ],
      );

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
            home: const EncyclopediaScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('美元'), findsOneWidget);

      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();

      expect(find.text('美元'), findsOneWidget);
      expect(
        find.text(
          'Official currency of the United States (including its territories) and other regions. The world\'s primary reserve currency.',
        ),
        findsOneWidget,
      );
      expect(
        LocalizationObservability.events,
        anyElement(
          predicate<Map<String, String>>((event) =>
              event['event'] == 'localization_fallback' &&
              event['surface'] == 'encyclopedia' &&
              event['locale'] == 'zh_Hans' &&
              event['fallback'] == 'en' &&
              event['currency'] == 'USD' &&
              event['field'] == 'description'),
        ),
      );
    },
  );
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

class _FakeCurrencyCatalogService extends CurrencyCatalogService {
  _FakeCurrencyCatalogService({
    required super.client,
    required super.cache,
    super.bundle,
  });

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    return super.getCurrencies(forceRefresh: forceRefresh, locale: locale);
  }
}

class _OverlayAssetBundle extends CachingAssetBundle {
  _OverlayAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value != null) {
      return ByteData.view(Uint8List.fromList(utf8.encode(value)).buffer);
    }

    return rootBundle.load(key);
  }
}
