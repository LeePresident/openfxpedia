import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../services/exchange_client.dart';
import '../services/cache_service.dart';
import '../models/currency.dart';

class CurrencyCatalogService {
  final ExchangeClient _client;
  final CacheService _cache;

  List<Currency>? _currencies;

  // Fiat currencies whitelist will be loaded from asset JSON at runtime.
  static Set<String>? _fiatCurrencies;
  static Map<String, Map<String, dynamic>>? _fiatMetadata;
  static const String _fiatAssetPath = 'assets/data/fiat_currencies.json';

  CurrencyCatalogService({
    required ExchangeClient client,
    required CacheService cache,
  })  : _client = client,
        _cache = cache;

  /// Returns the full list of fiat currencies, loading from cache or network.
  /// Excludes cryptocurrencies and precious metals.
  Future<List<Currency>> getCurrencies({bool forceRefresh = false}) async {
    if (_currencies != null && !forceRefresh) return _currencies!;

    // Ensure fiat whitelist is loaded from bundled JSON asset.
    await _ensureFiatLoaded();

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
      final name = (meta != null && meta['name'] != null)
          ? meta['name'].toString()
          : _capitalize(e.value);
      final symbol = meta != null ? meta['symbol'] as String? : null;
      final regions = meta != null
          ? (meta['regions'] as List<dynamic>?)?.cast<String>() ?? <String>[]
          : <String>[];

      return Currency(
        isoCode: iso,
        name: name,
        symbol: symbol,
        iconAsset: _iconAssetPath(e.key),
        regions: regions,
        description: meta != null ? meta['description'] as String? : null,
      );
    }).toList()
      ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

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
    // Return asset path only if the icon file exists in the bundle.
    // Icons should be at assets/icons/<lowercase_code>.svg or .png
    return 'assets/icons/${isoCode.toLowerCase()}.svg';
  }

  /// Checks if a currency code is a fiat currency (not crypto or precious metal).
  bool _isFiatCurrency(String code) {
    final upperCode = code.toUpperCase();
    return _fiatCurrencies?.contains(upperCode) ?? false;
  }

  Future<void> _ensureFiatLoaded() async {
    if (_fiatCurrencies != null) return;
    try {
      final jsonStr = await rootBundle.loadString(_fiatAssetPath);
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
      // If asset loading fails, fall back to an empty set to avoid including non-fiat codes.
      _fiatCurrencies = <String>{};
    }
  }
}
