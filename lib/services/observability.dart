import 'dart:convert';

import 'package:flutter/foundation.dart';

class LocalizationObservability {
  static final List<Map<String, String>> _events = [];

  static List<Map<String, String>> get events => List.unmodifiable(_events);

  static void clear() => _events.clear();

  static void recordFallback({
    required String surface,
    required String localeKey,
    required String fallbackKey,
    String? currency,
    String? field,
  }) {
    final event = <String, String>{
      'event': 'localization_fallback',
      'surface': surface,
      'locale': localeKey,
      'fallback': fallbackKey,
    };
    if (currency != null) {
      event['currency'] = currency;
    }
    if (field != null) {
      event['field'] = field;
    }
    _events.add(event);

    if (kDebugMode) {
      debugPrint(jsonEncode(event));
    }
  }
}
