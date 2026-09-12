import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

class CurrencyOverlayLoader {
  static const String assetPrefix = 'assets/data/fiat_currency_overlays';

  final AssetBundle _bundle;
  final Map<String, Map<String, Map<String, dynamic>>> _overlays = {};

  CurrencyOverlayLoader({required AssetBundle bundle}) : _bundle = bundle;

  Future<Map<String, Map<String, dynamic>>> load(String localeKey) async {
    final cached = _overlays[localeKey];
    if (cached != null) return cached;

    final overlay = <String, Map<String, dynamic>>{};
    try {
      final jsonStr = await _bundle.loadString('$assetPrefix/$localeKey.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entries = data['entries'];
      if (entries is Map<String, dynamic>) {
        for (final item in entries.entries) {
          final value = item.value;
          if (value is Map<String, dynamic>) {
            overlay[item.key.toUpperCase()] =
                value.map((key, value) => MapEntry(key.toString(), value));
          }
        }
      }
    } catch (_) {
      // Missing locale overlays fall back to the English/base dataset.
    }

    _overlays[localeKey] = overlay;
    return overlay;
  }
}
