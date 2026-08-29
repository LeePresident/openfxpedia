import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/widgets/region_flag.dart';

void main() {
  test('resolves country and territory names to ISO flag codes', () {
    expect(regionCountryCode('Hong Kong'), 'HK');
    expect(regionCountryCode('France (except French Polynesia)'), 'FR');
    expect(regionCountryCode('British Virgin Islands'), 'VG');
    expect(regionCountryCode('Unknown region'), isNull);
  });

  test('resolves the Euro currency flag override', () {
    expect(currencyFlagCode('EUR'), 'EU');
    expect(currencyFlagCode('USD'), isNull);
  });

  testWidgets('renders original icons for X-prefixed currencies',
      (tester) async {
    for (final currencyCode in ['XAF', 'XCD', 'XCG', 'XOF', 'XPF']) {
      await tester.pumpWidget(
        MaterialApp(
          home: buildCurrencyFlag(
            currencyCode: currencyCode,
            regions: const [],
            regionCodes: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget,
          reason: '$currencyCode should use its original SVG icon');
    }
  });
}
