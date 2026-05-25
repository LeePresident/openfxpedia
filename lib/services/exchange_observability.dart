import 'dart:convert';

import 'package:flutter/foundation.dart';

class ExchangeObservability {
  static final List<Map<String, String>> _events = [];

  static List<Map<String, String>> get events => List.unmodifiable(_events);

  static void clear() => _events.clear();

  static void recordAttempt({
    required String source,
    required String status,
    required String base,
    String? failureReason,
  }) {
    final event = <String, String>{
      'event': 'exchange_lookup',
      'source': source,
      'status': status,
      'base': base,
    };
    if (failureReason != null && failureReason.isNotEmpty) {
      event['failure_reason'] = failureReason;
    }
    _events.add(event);

    if (kDebugMode) {
      debugPrint(jsonEncode(event));
    }
  }
}
