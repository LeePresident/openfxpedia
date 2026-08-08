import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Currency', () {
    test('round-trips iso_numeric through map serialization', () {
      final currency = Currency.fromMap({
        'iso_code': 'ALL',
        'iso_numeric': '008',
        'name': 'Albanian Lek',
      });

      expect(currency.isoNumeric, '008');
      expect(currency.toMap()['iso_numeric'], '008');
    });

    test('allows currencies without an ISO numeric code', () {
      final currency = Currency.fromMap({
        'iso_code': 'TEST',
        'name': 'Test Currency',
      });

      expect(currency.isoNumeric, isNull);
      expect(currency.toMap()['iso_numeric'], isNull);
    });
  });

  test('fiat currency asset contains an ISO numeric code for every record',
      () async {
    final json =
        await rootBundle.loadString('assets/data/fiat_currencies.json');
    final records =
        (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>();

    expect(records, isNotEmpty);
    for (final record in records) {
      expect(record['iso_numeric'], isA<String>(),
          reason: 'Missing ISO numeric code for ${record['iso_code']}');
      expect((record['iso_numeric'] as String), hasLength(3),
          reason: 'Invalid ISO numeric code for ${record['iso_code']}');
    }

    final byCode = {
      for (final record in records) record['iso_code'] as String: record,
    };
    expect(byCode['ALL']!['iso_numeric'], '008');
    expect(byCode['DZD']!['iso_numeric'], '012');
    expect(byCode['SBD']!['iso_numeric'], '090');
  });
}
