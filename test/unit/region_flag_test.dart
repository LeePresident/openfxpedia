import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/widgets/region_flag.dart';

void main() {
  test('resolves country and territory names to ISO flag codes', () {
    expect(regionCountryCode('Hong Kong'), 'HK');
    expect(regionCountryCode('France (except French Polynesia)'), 'FR');
    expect(regionCountryCode('British Virgin Islands'), 'VG');
    expect(regionCountryCode('Unknown region'), isNull);
  });
}
