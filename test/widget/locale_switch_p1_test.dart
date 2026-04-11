import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:openfxpedia/core/config.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';

void main() {
  testWidgets('P1 language switch updates UI and persists selection', (
    tester,
  ) async {
    final cache = InMemoryCacheService();
    final appState = _buildAppState(cache);
    await appState.initialize();

    await tester.pumpWidget(
      _TestHarness(state: appState, child: const _LocaleSwitchPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Select language'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simplified Chinese'));
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(cache.getLocaleCode(), 'zh_Hans');

    final restartedState = _buildAppState(cache);
    await restartedState.initialize();
    await tester.pumpWidget(
      _TestHarness(state: restartedState, child: const _LocaleSwitchPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
  });
}

AppState _buildAppState(InMemoryCacheService cache) {
  return AppState(
    conversionService: _FakeConversionService(cache: cache),
    catalogService: _FakeCatalogService(cache: cache),
    favoritesService: FavoritesService(cache: cache),
    cacheService: cache,
    systemLocales: () => const [Locale('en')],
  );
}

class _TestHarness extends StatelessWidget {
  final AppState state;
  final Widget child;

  const _TestHarness({required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
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
            home: child,
          );
        },
      ),
    );
  }
}

class _LocaleSwitchPage extends StatelessWidget {
  const _LocaleSwitchPage();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.settings_language, key: const Key('language-title')),
            Text(_describeLocale(appState.locale, l10n),
                key: const Key('language-value')),
            TextButton(
              onPressed: () => _showLanguageDialog(context, appState),
              child: Text(l10n.settings_language_dialog_title),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    AppState appState,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<Locale?>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(l10n.settings_language_dialog_title),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, const Locale('en')),
              child: Text(l10n.language_english),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                dialogContext,
                const Locale.fromSubtags(
                    languageCode: 'zh', scriptCode: 'Hans'),
              ),
              child: Text(l10n.language_simplified_chinese),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                dialogContext,
                const Locale.fromSubtags(
                    languageCode: 'zh', scriptCode: 'Hant'),
              ),
              child: Text(l10n.language_traditional_chinese),
            ),
          ],
        );
      },
    );

    await appState.setLocale(chosen);
  }

  String _describeLocale(Locale? locale, AppLocalizations l10n) {
    if (locale == null) {
      return l10n.settings_system;
    }
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hans') {
      return l10n.language_simplified_chinese;
    }
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return l10n.language_traditional_chinese;
    }
    return l10n.language_english;
  }
}

class InMemoryCacheService extends CacheService {
  final Map<String, String> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> putString(String key, String value) async {
    _store[key] = value;
  }

  @override
  String? getString(String key) => _store[key];

  @override
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      _store.remove(AppConfig.localeKey);
    } else {
      _store[AppConfig.localeKey] = code;
    }
  }

  @override
  String? getLocaleCode() => _store[AppConfig.localeKey];

  @override
  Future<void> putFavorites(List<String> favorites) async {
    _store[AppConfig.favoritesKey] = jsonEncode(favorites);
  }

  @override
  List<String> getFavorites() {
    final raw = _store[AppConfig.favoritesKey];
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }
}

class _FakeConversionService extends ConversionService {
  _FakeConversionService({required super.cache})
      : super(client: ExchangeClient());

  @override
  Future<ConversionResult> convert(
      double amount, String base, String target) async {
    throw UnimplementedError('Not used by locale switch test.');
  }

  @override
  Future<void> refreshRates(String base) async {}
}

class _FakeCatalogService extends CurrencyCatalogService {
  _FakeCatalogService({required super.cache}) : super(client: ExchangeClient());

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    return const [];
  }
}
