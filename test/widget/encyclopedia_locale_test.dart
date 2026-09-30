import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/cached_catalog.dart';
import 'package:openfxpedia/models/cached_rate_snapshot.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/currency_detail_screen.dart';
import 'package:openfxpedia/screens/encyclopedia_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:openfxpedia/services/observability.dart';
import 'package:openfxpedia/widgets/amount_input.dart';

void main() {
  testWidgets('Traditional Chinese resources use Hong Kong terminology',
      (tester) async {
    final l10n = await AppLocalizations.delegate.load(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );

    expect(l10n.startup_loading, '正在載入貨幣和緩存匯率');
    expect(l10n.settings_license, '許可證');
    expect(l10n.settings_clear_local_data, '清除本地資料');
    expect(l10n.rate_info_cached, '緩存');
    expect(l10n.rate_info_live, '在線');
    expect(l10n.error_network_unavailable, contains('網絡'));
    expect(l10n.error_network_unavailable, contains('服務器'));
    expect(l10n.detail_sos_no_coins, contains('索馬里'));

    final overlay = jsonDecode(
      await rootBundle.loadString(
        'assets/data/fiat_currency_overlays/zh_Hant.json',
      ),
    ) as Map<String, dynamic>;
    final entries = overlay['entries'] as Map<String, dynamic>;

    expect(overlay['locale'], 'zh_Hant');
    expect(entries['BND']['name'], '文萊元');
    expect(entries['BND']['regions'], ['文萊']);
    expect(entries['EUR']['regions'], contains('黑山'));
    expect(entries['KPW']['name'], '朝鮮圜');
    expect(entries['KPW']['major_unit'], '圜');
    expect(entries['KRW']['name'], '韓圜');
    expect(entries['NZD']['name'], '紐西蘭元');
    expect(entries['NZD']['regions'], contains('紐西蘭'));
    expect(entries['VED']['major_unit'], '數碼玻利瓦爾');
    expect(entries['VES']['major_unit'], '主權玻利瓦爾');
  });

  for (final example in [
    ('ILS', 'Agora', '10 agorot', 0.1),
    ('RON', 'Ban', '5 bani', 0.05),
    ('LSL', 'Sente', '5 lisente', 0.05),
    ('BTN', 'Chetrum', '5 chhertum', 0.05),
  ]) {
    testWidgets('${example.$1} minor denomination sets a fractional amount',
        (tester) async {
      final cache = _StubCacheService();
      final exchange = _FakeExchangeClient();
      final state = AppState(
        conversionService: ConversionService(client: exchange, cache: cache),
        catalogService: CurrencyCatalogService(client: exchange, cache: cache),
        favoritesService: FavoritesService(cache: cache),
        cacheService: cache,
      );
      final currency = Currency(
        isoCode: example.$1,
        name: example.$1,
        minorUnit: example.$2,
        minorUnitsPerMajor: 100,
        coins: [example.$3],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CurrencyDetailScreen(currency: currency),
                  ),
                ),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(example.$3));
      await tester.pumpAndSettle();

      expect(state.baseCurrency?.isoCode, example.$1);
      expect(state.inputAmount, example.$4);
    });
  }

  testWidgets('denomination amount is reset when local data is cleared',
      (tester) async {
    final cache = _StubCacheService();
    final exchange = _FakeExchangeClient();
    final state = AppState(
      conversionService: ConversionService(client: exchange, cache: cache),
      catalogService: CurrencyCatalogService(
        client: exchange,
        cache: cache,
      ),
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
    );
    final currency = Currency(
      isoCode: 'HKD',
      name: 'Hong Kong Dollar',
      coins: ['10c'],
      banknotes: ['HK\$1000'],
      majorUnit: 'Dollar',
      minorUnit: '分',
      minorUnitsPerMajor: 100,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AppState>(
            builder: (context, currentState, _) => Scaffold(
              body: Column(
                children: [
                  AmountInput(
                    initialValue: currentState.inputAmount,
                    label: 'Amount',
                    onChanged: currentState.setInputAmount,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CurrencyDetailScreen(currency: currency),
                      ),
                    ),
                    child: const Text('Open detail'),
                  ),
                  TextButton(
                    onPressed: currentState.clearLocalData,
                    child: const Text('Clear local data'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HK\$1000'));
    await tester.pumpAndSettle();

    expect(state.baseCurrency?.isoCode, 'HKD');
    expect(state.inputAmount, 1000);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '1000.0',
    );
    expect(find.text('Open detail'), findsOneWidget);

    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10c'));
    await tester.pumpAndSettle();

    expect(state.baseCurrency?.isoCode, 'HKD');
    expect(state.inputAmount, 0.1);

    await tester.tap(find.text('Clear local data'));
    await tester.pumpAndSettle();

    expect(state.inputAmount, 0);
    expect(state.baseCurrency, isNull);
    expect(state.targetCurrency, isNull);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '0.0',
    );
  });

  testWidgets(
    'encyclopedia shows localized currency names and falls back to English for missing fields',
    (tester) async {
      LocalizationObservability.clear();

      final cache = _StubCacheService();
      final exchange = _FakeExchangeClient();
      final catalog = CurrencyCatalogService(
        client: exchange,
        cache: cache,
        bundle: _OverlayAssetBundle(
          {
            'assets/data/fiat_currencies.json': jsonEncode([
              {
                'iso_code': 'USD',
                'name': 'US Dollar',
                'regions': ['United States'],
                'major_unit': 'US dollar',
                'minor_unit': 'cent',
                'minor_units_per_major': 100,
                'coins': ['1 cent', 'USD1'],
                'description':
                    'Official currency of the United States (including its territories) and other regions. The world\'s primary reserve currency.',
              },
              {
                'iso_code': 'EUR',
                'name': 'Euro',
                'regions': ['Eurozone'],
              },
              {
                'iso_code': 'JPY',
                'name': 'Japanese Yen',
                'regions': ['Japan'],
              },
            ]),
            'assets/data/fiat_currency_overlays/zh_Hans.json': jsonEncode({
              'entries': {
                'USD': {
                  'name': '美元',
                  'major_unit': '美元',
                  'minor_unit': '美分',
                },
                'EUR': {
                  'name': '欧元',
                },
                'JPY': {
                  'name': '日元',
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

      await tester.tap(find.byTooltip('排序货币'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('名称（A-Z）'));
      await tester.pumpAndSettle();

      expect(
        (tester.widget<ListTile>(find.byType(ListTile).first).title as Text)
            .data,
        'USD',
      );

      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();

      expect(find.text('美元'), findsNWidgets(2));
      expect(find.text('美元 / 美分（1:100）'), findsOneWidget);
      expect(find.text('1 美分'), findsOneWidget);
      expect(find.text('USD1'), findsOneWidget);
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
  Future<void> clearAll() async {
    _favorites.clear();
  }

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
  CachedCatalog getCachedCatalog({int ttlHours = 12}) {
    return const CachedCatalog(
      catalog: null,
      timestamp: null,
      isStale: true,
    );
  }

  @override
  Future<void> putCurrencyCatalog(
    Map<String, String> catalog,
    DateTime timestamp,
  ) async {}

  @override
  CachedRateSnapshot getCachedRates(
    String base, {
    int ttlHours = 12,
  }) {
    return const CachedRateSnapshot(
      rates: null,
      timestamp: null,
      source: null,
      isStale: true,
    );
  }

  @override
  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {}
}

class _FakeExchangeClient extends ExchangeClient {
  _FakeExchangeClient()
      : super(httpClient: MockClient((_) async => Response('{}', 200)));

  @override
  Future<Map<String, String>> fetchCurrencyCatalog() async => {
        'usd': 'us dollar',
        'eur': 'euro',
        'jpy': 'japanese yen',
      };

  @override
  Future<Map<String, double>> fetchRatesFor(String base) async => {'usd': 1.0};
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
