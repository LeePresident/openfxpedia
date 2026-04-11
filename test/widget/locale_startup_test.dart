import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';

void main() {
  testWidgets('first run starts in the matching supported locale', (
    tester,
  ) async {
    final cache = _InMemoryCacheService();
    final state = AppState(
      conversionService: _FakeConversionService(cache: cache),
      catalogService: _FakeCatalogService(cache: cache),
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
      systemLocales: () => const [
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ],
    );

    await state.initialize();

    expect(state.locale,
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return MaterialApp(
              locale: state.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const _LocaleProbePage(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
  });

  testWidgets('system locale zh_HK resolves to Traditional Chinese', (
    tester,
  ) async {
    final cache = _InMemoryCacheService();
    final catalog = _FakeCatalogService(cache: cache);
    final state = AppState(
      conversionService: _FakeConversionService(cache: cache),
      catalogService: catalog,
      favoritesService: FavoritesService(cache: cache),
      cacheService: cache,
      systemLocales: () => const [
        Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK'),
      ],
    );

    await state.initialize();

    expect(
      state.locale,
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(
      catalog.lastLocale,
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return MaterialApp(
              locale: state.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const _LocaleProbePage(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('語言'), findsOneWidget);
  });
}

class _LocaleProbePage extends StatelessWidget {
  const _LocaleProbePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(child: Text(l10n.settings_language)),
    );
  }
}

class _InMemoryCacheService extends CacheService {
  @override
  Future<void> init() async {}

  @override
  Future<void> putFavorites(List<String> favorites) async {}

  @override
  List<String> getFavorites() => const [];

  @override
  Future<void> putString(String key, String value) async {}

  @override
  String? getString(String key) => null;

  @override
  Future<void> setLocaleCode(String? code) async {}

  @override
  String? getLocaleCode() => null;
}

class _FakeConversionService extends ConversionService {
  _FakeConversionService({required super.cache})
      : super(client: ExchangeClient());

  @override
  Future<ConversionResult> convert(
      double amount, String base, String target) async {
    throw UnimplementedError('Not used by locale startup test.');
  }

  @override
  Future<void> refreshRates(String base) async {}
}

class _FakeCatalogService extends CurrencyCatalogService {
  Locale? lastLocale;

  _FakeCatalogService({required super.cache}) : super(client: ExchangeClient());

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    lastLocale = locale;
    return const [];
  }
}
