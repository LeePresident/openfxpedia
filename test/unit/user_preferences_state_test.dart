import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/core/config.dart';
import 'package:openfxpedia/providers/user_preferences_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';

void main() {
  test('preferences persist and reload theme, source, and script locale',
      () async {
    final cache = _MemoryCacheService();
    final state = _preferences(cache);
    state.load();

    const traditionalChinese =
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    await state.setThemeMode(ThemeMode.dark);
    expect(
      state.selectExchangeApiSource(ExchangeApiSource.exchangeApi),
      isTrue,
    );
    await state.persistExchangeApiSource();
    expect(state.selectLocale(traditionalChinese), isTrue);
    await state.persistLocale();

    final reloaded = _preferences(cache)..load();

    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.exchangeApiSource, ExchangeApiSource.exchangeApi);
    expect(reloaded.locale, traditionalChinese);
    expect(reloaded.effectiveLocale, traditionalChinese);
  });

  test('missing or invalid preferences use system and default values', () {
    final cache = _MemoryCacheService()
      ..values[AppConfig.themeModeKey] = 'invalid'
      ..values[AppConfig.exchangeApiSourceKey] = 'invalid';
    final state = _preferences(cache)..load();

    expect(state.themeMode, ThemeMode.system);
    expect(state.exchangeApiSource, ExchangeApiSource.auto);
    expect(state.locale, const Locale('en'));
    expect(state.effectiveLocale, const Locale('en'));
  });

  test('selecting system locale clears a previously persisted locale',
      () async {
    final cache = _MemoryCacheService();
    final state = _preferences(cache)..load();

    expect(state.selectLocale(const Locale('fr')), isTrue);
    await state.persistLocale();
    expect(cache.getLocaleCode(), 'fr');

    expect(state.selectLocale(null), isTrue);
    await state.persistLocale();

    expect(cache.getLocaleCode(), isNull);
    expect(state.effectiveLocale, const Locale('en'));
  });
}

UserPreferencesState _preferences(CacheService cache) {
  return UserPreferencesState(
    cacheService: cache,
    systemLocales: () => const [Locale('en')],
    onChanged: () {},
  );
}

class _MemoryCacheService extends CacheService {
  final values = <String, String>{};

  @override
  String? getString(String key) => values[key];

  @override
  String? getLocaleCode() => values[AppConfig.localeKey];

  @override
  Future<void> putString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      values.remove(AppConfig.localeKey);
    } else {
      values[AppConfig.localeKey] = code;
    }
  }
}
