import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/widgets/region_flag.dart';

void main() {
  test('every catalog region has a flag mapping', () {
    final catalog = jsonDecode(
      File('assets/data/fiat_currencies.json').readAsStringSync(),
    ) as List<dynamic>;
    final regions = <String>{
      for (final currency in catalog)
        ...(currency['regions'] as List<dynamic>).cast<String>(),
    };
    final missing = regions
        .where((region) => regionCountryCode(region) == null)
        .toList()
      ..sort();

    expect(missing, isEmpty, reason: 'Missing region flags: $missing');
  });
}
