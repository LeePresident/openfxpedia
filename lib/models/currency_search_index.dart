import 'currency.dart';

class CurrencySearchIndex {
  CurrencySearchIndex(this.currency)
    : normalizedIsoCode = currency.isoCode.toLowerCase(),
      normalizedName = currency.name.toLowerCase();

  final Currency currency;
  final String normalizedIsoCode;
  final String normalizedName;

  bool matches(CurrencySearchQuery query) {
    return query.value.isEmpty ||
        normalizedIsoCode.contains(query.value) ||
        normalizedName.contains(query.value) ||
        (currency.isoNumeric?.contains(query.value) ?? false);
  }
}

class CurrencySearchQuery {
  CurrencySearchQuery(String query) : value = query.toLowerCase();

  final String value;
}
