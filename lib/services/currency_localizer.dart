import 'observability.dart';

class CurrencyLocalizer {
  final String localeKey;

  const CurrencyLocalizer({required this.localeKey});

  String resolveField({
    required String isoCode,
    required String field,
    required String? baseValue,
    required Map<String, dynamic>? overlayEntry,
  }) {
    final overlayValue = overlayEntry?[field];
    if (overlayValue is String && overlayValue.trim().isNotEmpty) {
      return overlayValue.trim();
    }

    _recordFallback(isoCode: isoCode, field: field);
    return baseValue ?? '';
  }

  List<String> resolveList({
    required String isoCode,
    required String field,
    required List<String>? baseValue,
    required Map<String, dynamic>? overlayEntry,
  }) {
    final overlayValue = overlayEntry?[field];
    if (overlayValue is List) {
      final localized = overlayValue
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (localized.isNotEmpty) return localized;
    }

    _recordFallback(isoCode: isoCode, field: field);
    return baseValue ?? const [];
  }

  void _recordFallback({required String isoCode, required String field}) {
    if (localeKey == 'en') return;

    LocalizationObservability.recordFallback(
      surface: 'encyclopedia',
      localeKey: localeKey,
      fallbackKey: 'en',
      currency: isoCode,
      field: field,
    );
  }
}
