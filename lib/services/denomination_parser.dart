import '../models/currency.dart';
import 'currency_localizer.dart';

class DenominationParser {
  static double? parse(Currency currency, String denomination) {
    final fraction =
        RegExp(r'(\d+)\s*[/\u2044]\s*(\d+)').firstMatch(denomination);
    final amountMatch = fraction == null
        ? RegExp(r'\d+(?:,\d{3})*(?:\.\d+)?').firstMatch(denomination)
        : null;
    final amount = fraction != null
        ? double.parse(fraction.group(1)!) / double.parse(fraction.group(2)!)
        : double.tryParse(amountMatch?.group(0)?.replaceAll(',', '') ?? '');
    if (amount == null) return null;

    if (_isMinorUnitDenomination(currency, denomination) &&
        currency.minorUnitsPerMajor != null &&
        currency.minorUnitsPerMajor! > 0) {
      return amount / currency.minorUnitsPerMajor!;
    }
    return amount;
  }

  static bool _isMinorUnitDenomination(
    Currency currency,
    String denomination,
  ) {
    final minorUnit = currency.minorUnit;
    if (minorUnit == null || minorUnit.isEmpty) return false;

    final normalizedUnit = minorUnit.toLowerCase();
    if (RegExp(r'\d\s*(?:c|\u00a2)$', caseSensitive: false)
        .hasMatch(denomination)) {
      return true;
    }
    if (RegExp(r'\d\s*p$', caseSensitive: false).hasMatch(denomination)) {
      return true;
    }

    final terms = [
      minorUnit,
      ...?CurrencyLocalizer.denominationUnitAliases[normalizedUnit],
    ].map(RegExp.escape).join('|');
    return RegExp(
      '(?<![\\p{L}\\p{N}])(?:$terms)s?(?![\\p{L}\\p{N}])',
      caseSensitive: false,
      unicode: true,
    ).hasMatch(denomination);
  }
}
