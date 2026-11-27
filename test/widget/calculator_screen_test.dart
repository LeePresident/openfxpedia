import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/l10n/localization_delegates.dart';
import 'package:openfxpedia/main.dart';
import 'package:openfxpedia/models/cached_catalog.dart';
import 'package:openfxpedia/models/cached_rate_snapshot.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/screens/calculator_screen.dart';
import 'package:openfxpedia/screens/settings_screen.dart';
import 'package:openfxpedia/screens/currency_map_screen.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_provider.dart';
import 'package:openfxpedia/services/favorites_service.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      quotedAt: DateTime.utc(
        date.year,
        date.month,
        date.day,
      ).subtract(const Duration(days: 2)),
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
  }) async => [_usd, _eur, _gbp];
}

class _MapCatalog extends _StubCatalog {
  _MapCatalog({required super.client, required super.cache});

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async => [
    Currency(
      isoCode: 'USD',
      name: 'US Dollar',
      regions: ['United States', 'Zimbabwe', 'Puerto Rico'],
      regionCodes: ['US', 'ZW', 'PR'],
    ),
    Currency(
      isoCode: 'EUR',
      name: 'Euro',
      regions: ['France', 'Germany'],
      regionCodes: ['FR', 'DE'],
    ),
    Currency(
      isoCode: 'ZWG',
      name: 'Zimbabwe Gold',
      regions: ['Zimbabwe'],
      regionCodes: ['ZW'],
    ),
    Currency(
      isoCode: 'GIP',
      name: 'Gibraltar Pound',
      regions: ['Gibraltar'],
      regionCodes: ['GI'],
    ),
  ];
}

Future<int> _mapPixel(
  WidgetTester tester,
  Finder map,
  double lon,
  double lat,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(map);
  final pixel = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final x = ((lon + 180) / 360 * image.width).floor();
    final y = ((90 - lat) / 180 * image.height).floor();
    final result = bytes!.getUint32((y * image.width + x) * 4);
    image.dispose();
    return result;
  });
  return pixel!;
}

void main() {
  testWidgets('map finds currencies and retains selections between tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cache = _StubCache();
    final client = _RateClient();
    final state = AppState(
      conversionService: ConversionService(client: client, cache: cache),
      catalogService: _MapCatalog(client: client, cache: cache),
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
      systemLocales: () => const [Locale('en')],
    );
    addTearDown(state.dispose);
    await state.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const OpenFXpediaApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Currency map'));
    await tester.pump();
    final map = find.byKey(const ValueKey('currency-world-map'));
    for (var i = 0; i < 200 && map.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(CurrencyMapScreen), findsOneWidget);

    expect(map, findsOneWidget);
    final rect = tester.getRect(map);
    // Tap just outside Gibraltar's tiny geometry.
    Offset gibraltarTap(Rect bounds) =>
        bounds.topLeft +
        Offset(
          bounds.width * (174.65 / 360) + 3,
          bounds.height * (53.87 / 180),
        );
    await tester.tapAt(gibraltarTap(rect));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsOneWidget);
    expect(find.text('Gibraltar'), findsOneWidget);
    await tester.ensureVisible(find.text('Gibraltar'));
    await tester.tap(find.text('Gibraltar'));
    await tester.pumpAndSettle();
    expect(find.text('GIP — Gibraltar Pound'), findsOneWidget);

    // Paris, in equirectangular map coordinates.
    final franceRect = tester.getRect(map);
    await tester.tapAt(
      franceRect.topLeft +
          Offset(
            franceRect.width * (182.35 / 360),
            franceRect.height * (41.14 / 180),
          ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsOneWidget);
    await tester.ensureVisible(find.text('France'));
    await tester.tap(find.text('France'));
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget);
    expect(find.text('EUR — Euro'), findsOneWidget);
    final beforeUs = await _mapPixel(tester, map, -98, 38);
    final beforeFrance = await _mapPixel(tester, map, 2.35, 48.86);
    final beforeZimbabwe = await _mapPixel(tester, map, 29.8, -19);

    await tester.tap(find.text('Search for a currency'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('currency_search_field')),
      'USD',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    expect(find.text('USD — US Dollar'), findsOneWidget);
    expect(find.text('United States, Zimbabwe, Puerto Rico'), findsOneWidget);
    expect(find.text('France'), findsNothing);
    expect(find.text('EUR — Euro'), findsNothing);
    expect(find.text('Selected region'), findsNothing);
    expect(await _mapPixel(tester, map, -98, 38), isNot(beforeUs));
    expect(await _mapPixel(tester, map, 29.8, -19), isNot(beforeZimbabwe));
    expect(await _mapPixel(tester, map, 2.35, 48.86), isNot(beforeFrance));

    final selectedCurrencyRect = tester.getRect(map);
    await tester.tapAt(
      selectedCurrencyRect.topLeft +
          Offset(
            selectedCurrencyRect.width * (182.35 / 360),
            selectedCurrencyRect.height * (41.14 / 180),
          ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('France'));
    await tester.tap(find.text('France'));
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget);
    expect(find.text('EUR — Euro'), findsOneWidget);
    expect(find.text('Search for a currency'), findsOneWidget);
    expect(find.text('United States, Zimbabwe, Puerto Rico'), findsNothing);
    expect(await _mapPixel(tester, map, -98, 38), beforeUs);

    await tester.tap(find.text('Search for a currency'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('currency_search_field')),
      'USD',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!
          .value
          .getMaxScaleOnAxis(),
      2,
    );
    await tester.tap(find.byTooltip('Reset map'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Find a country or region'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Zimbabwe');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zimbabwe').last);
    await tester.pumpAndSettle();
    expect(find.text('Zimbabwe'), findsOneWidget);
    expect(find.text('ZWG — Zimbabwe Gold'), findsOneWidget);
    expect(find.text('USD — US Dollar'), findsOneWidget);
    expect(find.text('Search for a currency'), findsOneWidget);
    expect(find.text('United States, Zimbabwe, Puerto Rico'), findsNothing);

    await tester.tap(find.text('Search for a currency'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('currency_search_field')),
      'USD',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();
    expect(find.text('Zimbabwe'), findsNothing);
    expect(find.text('ZWG — Zimbabwe Gold'), findsNothing);
    expect(find.text('Selected region'), findsNothing);
    expect(find.text('United States, Zimbabwe, Puerto Rico'), findsOneWidget);

    await tester.tap(find.byTooltip('Find a country or region'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Zimbabwe');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zimbabwe').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(CurrencyMapScreen), findsOneWidget);
    expect(find.text('ZWG — Zimbabwe Gold'), findsOneWidget);
    expect(find.text('USD — US Dollar'), findsOneWidget);
    expect(find.text('Search for a currency'), findsOneWidget);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await state.setLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    await tester.pumpAndSettle();
    expect(find.text('貨幣地圖'), findsOneWidget);
    expect(find.text('ZWG — Zimbabwe Gold'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CurrencyMapScreen), findsNothing);
    expect(find.text('貨幣地圖'), findsOneWidget);
  });

  testWidgets('More navigation keeps settings accessible across screen sizes', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'OpenFXpedia',
      packageName: 'openfxpedia',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    state.addCalculatorEntry();

    for (final size in [const Size(390, 844), const Size(1440, 900)]) {
      tester.view.physicalSize = size;
      state.setSelectedTab(0);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const OpenFXpediaApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
        hasLength(5),
      );
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );

      await tester.tap(find.text('Calculator'));
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorScreen), findsOneWidget);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.ensureVisible(find.text('Change log'));
      await tester.tap(find.text('Change log'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsNothing);
      expect(state.calculatorEntries, hasLength(2));
    }

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await state.setLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('更多'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets(
    'calculator adds entries, sums in the result currency, and keeps session state',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
      expect(tester.getSize(find.byType(Card).first).width, greaterThan(1300));

      final firstEntry = state.calculatorEntries.first;
      await tester.tap(find.text('Add amount'));
      await tester.pumpAndSettle();
      expect(state.calculatorEntries, hasLength(2));
      final secondEntry = state.calculatorEntries.last;

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('calculator-output-currency')),
          matching: find.byType(InkWell),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('GBP'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(ValueKey('calculator-currency-${secondEntry.id}')),
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(ValueKey('calculator-currency-${secondEntry.id}')),
          matching: find.byType(InkWell),
        ),
      );
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
    },
  );
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
          localizationsDelegates: appLocalizationDelegates,
          home: currentState.selectedTab == 1
              ? const CalculatorScreen()
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
