import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/services/denomination_parser.dart';

void main() {
  final currency = Currency(
    isoCode: 'USD',
    name: 'US Dollar',
    minorUnit: 'cent',
    minorUnitsPerMajor: 100,
  );

  for (final example in <(String, double?)>[
    ('USD1', 1),
    ('HK\$1,000', 1000),
    ('1,000,000.50 dollars', 1000000.5),
    ('0.25 dollars', 0.25),
    ('1/2 dollar', 0.5),
    ('1 \u2044 4 dollar', 0.25),
    ('50 cents', 0.5),
    ('50 CENTS', 0.5),
    ('10c', 0.1),
    ('10\u00a2', 0.1),
    ('10p', 0.1),
    ('1/2 cent', 0.005),
    ('5 centavos', 5),
    ('0 cents', 0),
    ('No coins in circulation', null),
    ('', null),
  ]) {
    test('parses denomination "${example.$1}"', () {
      expect(DenominationParser.parse(currency, example.$1), example.$2);
    });
  }

  for (final example in [
    ('Agora', '10 agorot', 0.1),
    ('Ban', '5 bani', 0.05),
    ('Sente', '5 lisente', 0.05),
    ('Chetrum', '5 chhertum', 0.05),
    ('\u5206', '10 \u5206', 0.1),
  ]) {
    test('recognizes minor unit ${example.$1}', () {
      final currency = Currency(
        isoCode: 'TEST',
        name: 'Test Currency',
        minorUnit: example.$1,
        minorUnitsPerMajor: 100,
      );

      expect(DenominationParser.parse(currency, example.$2), example.$3);
    });
  }

  test('uses the currency-specific minor-unit ratio', () {
    final currency = Currency(
      isoCode: 'KWD',
      name: 'Kuwaiti Dinar',
      minorUnit: 'fils',
      minorUnitsPerMajor: 1000,
    );

    expect(DenominationParser.parse(currency, '50 fils'), 0.05);
  });

  for (final ratio in <int?>[null, 0, -1]) {
    test('does not scale amounts with minor-unit ratio $ratio', () {
      final currency = Currency(
        isoCode: 'TEST',
        name: 'Test Currency',
        minorUnit: 'cent',
        minorUnitsPerMajor: ratio,
      );

      expect(DenominationParser.parse(currency, '50 cents'), 50);
    });
  }

  for (final minorUnit in <String?>[null, '']) {
    test('does not infer minor units when the unit is "$minorUnit"', () {
      final currency = Currency(
        isoCode: 'TEST',
        name: 'Test Currency',
        minorUnit: minorUnit,
        minorUnitsPerMajor: 100,
      );

      expect(DenominationParser.parse(currency, '10c'), 10);
    });
  }
}
