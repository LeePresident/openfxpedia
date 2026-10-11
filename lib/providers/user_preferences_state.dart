import 'package:flutter/material.dart';

import '../core/config.dart';
import '../services/cache_service.dart';
import '../services/exchange_api_source.dart';
import '../services/locale_resolver.dart';

class UserPreferencesState {
  UserPreferencesState({
    required CacheService cacheService,
    required Iterable<Locale> Function() systemLocales,
    required void Function() onChanged,
  })  : _cacheService = cacheService,
        _systemLocales = systemLocales,
        _onChanged = onChanged;

  final CacheService _cacheService;
  final Iterable<Locale> Function() _systemLocales;
  final void Function() _onChanged;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  ExchangeApiSource _exchangeApiSource = ExchangeApiSource.auto;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  ExchangeApiSource get exchangeApiSource => _exchangeApiSource;
  Locale? get effectiveLocale => _locale ?? _resolveSystemLocale();

  void load() {
    _locale = _readLocale(_cacheService.getLocaleCode());
    _themeMode = _parseThemeMode(
      _cacheService.getString(AppConfig.themeModeKey),
    );
    _exchangeApiSource = ExchangeApiSourceStorage.fromStorage(
      _cacheService.getString(AppConfig.exchangeApiSourceKey),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _onChanged();
    await _cacheService.putString(
      AppConfig.themeModeKey,
      _serializeThemeMode(mode),
    );
  }

  bool selectExchangeApiSource(ExchangeApiSource source) {
    if (_exchangeApiSource == source) return false;
    _exchangeApiSource = source;
    _onChanged();
    return true;
  }

  Future<void> persistExchangeApiSource() {
    return _cacheService.putString(
      AppConfig.exchangeApiSourceKey,
      _exchangeApiSource.storageValue,
    );
  }

  bool selectLocale(Locale? locale) {
    if ((_locale?.languageCode == locale?.languageCode) &&
        (_locale?.scriptCode == locale?.scriptCode)) {
      return false;
    }
    _locale = locale;
    _onChanged();
    return true;
  }

  Future<void> persistLocale() {
    return _cacheService.setLocaleCode(_localeCode(_locale));
  }

  Locale? _readLocale(String? code) {
    if (code == null) return _resolveSystemLocale();
    if (code.startsWith('zh_')) {
      final parts = code.split('_');
      if (parts.length >= 2) {
        return Locale.fromSubtags(languageCode: 'zh', scriptCode: parts[1]);
      }
    }
    return Locale(code);
  }

  String? _localeCode(Locale? locale) {
    if (locale == null) return null;
    if (locale.languageCode == 'zh' && locale.scriptCode != null) {
      return 'zh_${locale.scriptCode}';
    }
    return locale.languageCode;
  }

  Locale? _resolveSystemLocale() =>
      LocaleResolver.resolveSystemLocale(_systemLocales());

  ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
