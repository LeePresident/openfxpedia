import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../services/exchange_client.dart';
import '../services/cache_service.dart';
import '../models/currency.dart';
import '../generated/icon_asset.dart' as generated_icons;
import 'observability.dart';

class CurrencyCatalogService {
  final ExchangeClient _client;
  final CacheService _cache;
  final AssetBundle _bundle;

  List<Currency>? _currencies;

  static Set<String>? _fiatCurrencies;
  static Map<String, Map<String, dynamic>>? _fiatMetadata;
  static final Map<String, List<Currency>> _resolvedCurrenciesByLocale = {};
  static final Map<String, Map<String, Map<String, dynamic>>> _localeOverlays =
      {};
  static const String _fiatAssetPath = 'assets/data/fiat_currencies.json';
  static const String _overlayAssetPrefix =
      'assets/data/fiat_currency_overlays';

  CurrencyCatalogService({
    required ExchangeClient client,
    required CacheService cache,
    AssetBundle? bundle,
  })  : _client = client,
        _cache = cache,
        _bundle = bundle ?? rootBundle;

  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    final localeKey = _localeKey(locale);
    if (!forceRefresh && _resolvedCurrenciesByLocale[localeKey] != null) {
      return _resolvedCurrenciesByLocale[localeKey]!;
    }

    await _ensureFiatLoaded();
    final overlay = await _ensureLocaleOverlayLoaded(localeKey);

    Map<String, String> catalog;
    final cached = _cache.getCachedCatalog();

    if (!forceRefresh && cached.catalog != null && !cached.stale) {
      catalog = cached.catalog!;
    } else {
      try {
        catalog = await _client.fetchCurrencyCatalog();
        await _cache.putCurrencyCatalog(catalog, DateTime.now().toUtc());
      } catch (_) {
        if (cached.catalog != null) {
          catalog = cached.catalog!;
        } else {
          rethrow;
        }
      }
    }

    _currencies = catalog.entries.where((e) => _isFiatCurrency(e.key)).map((e) {
      final iso = e.key.toUpperCase();
      final meta = _fiatMetadata?[iso];
      final overlayEntry = overlay[iso];
      final baseName = (meta != null && meta['name'] != null)
          ? meta['name'].toString()
          : _capitalize(e.value);
      final name = _resolveLocalizedField(
        localeKey: localeKey,
        isoCode: iso,
        field: 'name',
        baseValue: baseName,
        overlayEntry: overlayEntry,
      );
      final symbol = overlayEntry != null && overlayEntry['symbol'] != null
          ? overlayEntry['symbol'].toString()
          : (meta != null ? meta['symbol'] as String? : null);
      final regions = _resolveLocalizedList(
        localeKey: localeKey,
        isoCode: iso,
        field: 'regions',
        baseValue: meta != null ? meta['regions'] as List<dynamic>? : null,
        overlayEntry: overlayEntry,
      );
      final description = _resolveLocalizedField(
        localeKey: localeKey,
        isoCode: iso,
        field: 'description',
        baseValue: meta != null ? meta['description'] as String? : null,
        overlayEntry: overlayEntry,
      );

      return Currency(
        isoCode: iso,
        name: name,
        symbol: symbol,
        iconAsset: _iconAssetPath(e.key),
        regions: regions,
        description: description,
      );
    }).toList()
      ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

    _resolvedCurrenciesByLocale[localeKey] = _currencies!;

    return _currencies!;
  }

  Currency? findByCode(String code) {
    return _currencies?.firstWhere(
      (c) => c.isoCode.toLowerCase() == code.toLowerCase(),
      orElse: () => Currency(isoCode: code.toUpperCase(), name: code),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String? _iconAssetPath(String isoCode) {
    final key = isoCode.toLowerCase();
    return generated_icons.iconAsset[key] ??
        generated_icons.iconAsset['generic'];
  }

  bool _isFiatCurrency(String code) {
    final upperCode = code.toUpperCase();
    return _fiatCurrencies?.contains(upperCode) ?? false;
  }

  String _localeKey(Locale? locale) {
    if (locale == null) return 'en';
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hans') return 'zh_Hans';
      if (locale.scriptCode == 'Hant') return 'zh_Hant';

      switch (locale.countryCode?.toUpperCase()) {
        case 'HK':
        case 'MO':
        case 'TW':
          return 'zh_Hant';
        case 'CN':
        case 'SG':
        case 'MY':
          return 'zh_Hans';
      }

      return 'zh_Hant';
    }
    return 'en';
  }

  String _resolveLocalizedField({
    required String localeKey,
    required String isoCode,
    required String field,
    required String? baseValue,
    required Map<String, dynamic>? overlayEntry,
  }) {
    final overlayValue = overlayEntry != null ? overlayEntry[field] : null;
    if (overlayValue is String && overlayValue.trim().isNotEmpty) {
      return overlayValue.trim();
    }

    if (localeKey != 'en') {
      LocalizationObservability.recordFallback(
        surface: 'encyclopedia',
        localeKey: localeKey,
        fallbackKey: 'en',
        currency: isoCode,
        field: field,
      );
    }

    return baseValue ?? '';
  }

  List<String> _resolveLocalizedList({
    required String localeKey,
    required String isoCode,
    required String field,
    required List<dynamic>? baseValue,
    required Map<String, dynamic>? overlayEntry,
  }) {
    final overlayValue = overlayEntry != null ? overlayEntry[field] : null;
    if (overlayValue is List) {
      final localized = overlayValue
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (localized.isNotEmpty) {
        return localized;
      }
    }

    if (localeKey != 'en') {
      LocalizationObservability.recordFallback(
        surface: 'encyclopedia',
        localeKey: localeKey,
        fallbackKey: 'en',
        currency: isoCode,
        field: field,
      );
    }

    return baseValue?.whereType<String>().toList() ?? <String>[];
  }

  Future<Map<String, Map<String, dynamic>>> _ensureLocaleOverlayLoaded(
    String localeKey,
  ) async {
    if (_localeOverlays.containsKey(localeKey)) {
      return _localeOverlays[localeKey]!;
    }

    final overlay = <String, Map<String, dynamic>>{};
    try {
      final jsonStr =
          await _bundle.loadString('$_overlayAssetPrefix/$localeKey.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entries = data['entries'];
      if (entries is Map<String, dynamic>) {
        for (final item in entries.entries) {
          final value = item.value;
          if (value is Map<String, dynamic>) {
            overlay[item.key.toUpperCase()] =
                value.map((k, v) => MapEntry(k.toString(), v));
          }
        }
      }
    } catch (_) {
      // Missing locale overlays fall back to the English/base dataset.
    }

    _localeOverlays[localeKey] = overlay;
    return overlay;
  }

  Future<void> _ensureFiatLoaded() async {
    if (_fiatCurrencies != null) return;
    try {
      final jsonStr = await _bundle.loadString(_fiatAssetPath);
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final Set<String> codes = <String>{};
      final Map<String, Map<String, dynamic>> meta = {};
      for (final item in data) {
        if (item is String) {
          codes.add(item.toUpperCase());
        } else if (item is Map<String, dynamic>) {
          final iso =
              (item['iso_code'] ?? item['iso'] ?? '').toString().toUpperCase();
          if (iso.isNotEmpty) {
            codes.add(iso);
            meta[iso] = item.map((k, v) => MapEntry(k.toString(), v));
          }
        }
      }
      _fiatCurrencies = codes;
      _fiatMetadata = meta;
    } catch (_) {
      _fiatCurrencies = <String>{};
    }
  }
}
