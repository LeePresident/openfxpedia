import 'observability.dart';

class CurrencyLocalizer {
  final String localeKey;

  static const _denominationUnitAliases = <String, List<String>>{
    'agora': ['agorot'],
    'ban': ['bani'],
    'chetrum': ['chhertum'],
    'denar': ['denari'],
    'fening': ['feninga'],
    'franc': ['francs'],
    'krona': ['kr'],
    'krone': ['kr'],
    'króna': ['kr'],
    'kopeck': ['kapiejka', 'kapiejki', 'kopiyky'],
    'leu': ['lei'],
    'piastre': ['pt', 'qirsh'],
    'sente': ['lisente'],
    'sen': ['cent'],
    'grosz': ['gr'],
  };

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

  List<String> localizeDenominations({
    required List<String> denominations,
    required String? baseUnit,
    required String? localizedUnit,
  }) {
    if (localeKey == 'en' ||
        baseUnit == null ||
        localizedUnit == null ||
        baseUnit.isEmpty ||
        localizedUnit.isEmpty) {
      return denominations;
    }

    final unitTerms = [
      baseUnit,
      ...?_denominationUnitAliases[baseUnit.toLowerCase()],
    ].map(RegExp.escape).join('|');
    final unitPattern = RegExp(
      '(?<![\\p{L}\\p{N}])(?:$unitTerms)s?(?![\\p{L}\\p{N}])',
      caseSensitive: false,
      unicode: true,
    );
    return denominations
        .map((denomination) =>
            denomination.replaceAll(unitPattern, localizedUnit))
        .toList();
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
