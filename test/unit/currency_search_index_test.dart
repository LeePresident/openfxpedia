import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/models/currency_search_index.dart';

void main() {
  test('matches currency code and name without case sensitivity', () {
    final index = CurrencySearchIndex(
      Currency(isoCode: 'USD', name: 'US Dollar'),
    );

    expect(index.matches(CurrencySearchQuery('usd')), isTrue);
    expect(index.matches(CurrencySearchQuery('dOlLaR')), isTrue);
    expect(index.matches(CurrencySearchQuery('eur')), isFalse);
  });

  test('matches numeric codes and treats an empty query as all currencies', () {
    final index = CurrencySearchIndex(
      Currency(isoCode: 'JPY', isoNumeric: '392', name: 'Japanese Yen'),
    );

    expect(index.matches(CurrencySearchQuery('39')), isTrue);
    expect(index.matches(CurrencySearchQuery('')), isTrue);
  });
}
