import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import '../models/currency_metadata.dart';
import '../models/currency_metadata_catalog.dart';

class CurrencyMetadataLoader {
  static const String assetPath = 'assets/data/fiat_currencies.json';

  final AssetBundle _bundle;
  CurrencyMetadataCatalog? _catalog;

  CurrencyMetadataLoader({required AssetBundle bundle}) : _bundle = bundle;

  Future<CurrencyMetadataCatalog> load() async {
    final cached = _catalog;
    if (cached != null) return cached;

    try {
      final jsonStr = await _bundle.loadString(assetPath);
      final data = jsonDecode(jsonStr) as List<dynamic>;
      final codes = <String>{};
      final metadata = <String, CurrencyMetadata>{};

      for (final item in data) {
        if (item is String) {
          codes.add(item.toUpperCase());
        } else if (item is Map<String, dynamic>) {
          final currency = CurrencyMetadata.fromJson(item);
          if (currency.isoCode.isNotEmpty) {
            codes.add(currency.isoCode);
            metadata[currency.isoCode] = currency;
          }
        }
      }

      return _catalog = CurrencyMetadataCatalog(
        codes: codes,
        metadata: metadata,
      );
    } catch (_) {
      return _catalog = const CurrencyMetadataCatalog(
        codes: <String>{},
        metadata: <String, CurrencyMetadata>{},
      );
    }
  }
}
