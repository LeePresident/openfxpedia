import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/services/currency_localizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Currency', () {
    test('round-trips iso_numeric through map serialization', () {
      final currency = Currency.fromMap({
        'iso_code': 'ALL',
        'iso_numeric': '008',
        'name': 'Albanian Lek',
        'coins': ['1 lek'],
        'banknotes': ['100 lek'],
        'major_unit': 'lek',
        'minor_unit': 'qindarkë',
        'minor_units_per_major': 100,
      });

      expect(currency.isoNumeric, '008');
      expect(currency.toMap()['iso_numeric'], '008');
      expect(currency.coins, ['1 lek']);
      expect(currency.banknotes, ['100 lek']);
      expect(currency.toMap()['coins'], ['1 lek']);
      expect(currency.toMap()['banknotes'], ['100 lek']);
      expect(currency.majorUnit, 'lek');
      expect(currency.minorUnit, 'qindarkë');
      expect(currency.minorUnitsPerMajor, 100);
      expect(currency.toMap()['major_unit'], 'lek');
      expect(currency.toMap()['minor_unit'], 'qindarkë');
      expect(currency.toMap()['minor_units_per_major'], 100);
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

  test('localizes denomination unit names without changing currency codes', () {
    const localizer = CurrencyLocalizer(localeKey: 'zh_Hant');

    expect(
      localizer.localizeDenominations(
        denominations: ['1 fils', '5 fils', 'AED1'],
        baseUnit: 'Fils',
        localizedUnit: '費爾斯',
      ),
      ['1 費爾斯', '5 費爾斯', 'AED1'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['10 cents'],
        baseUnit: 'Cent',
        localizedUnit: '美分',
      ),
      ['10 美分'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['1 qirsh'],
        baseUnit: 'Piastre',
        localizedUnit: '皮阿斯特',
      ),
      ['1 皮阿斯特'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['1 kr'],
        baseUnit: 'Krone',
        localizedUnit: '克朗',
      ),
      ['1 克朗'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['1 leu', '10 lei'],
        baseUnit: 'Leu',
        localizedUnit: '列伊',
      ),
      ['1 列伊', '10 列伊'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['1 cent', '5 cents'],
        baseUnit: 'Sen',
        localizedUnit: '仙',
      ),
      ['1 仙', '5 仙'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['25 PT', '50 PT'],
        baseUnit: 'Piastre',
        localizedUnit: '皮阿斯特',
      ),
      ['25 皮阿斯特', '50 皮阿斯特'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['1 gr', '2 gr'],
        baseUnit: 'Grosz',
        localizedUnit: '格羅希',
      ),
      ['1 格羅希', '2 格羅希'],
    );
    expect(
      localizer.localizeDenominations(
        denominations: ['50 kopiyky'],
        baseUnit: 'Kopeck',
        localizedUnit: '戈比',
      ),
      ['50 戈比'],
    );
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
    expect(byCode['ALL']!['minor_unit'], 'Qindarkë');
    expect(byCode['VUV']!['minor_unit'], isNull);
    expect(byCode['VUV']!['minor_units_per_major'], isNull);
    expect(byCode['ZWG']!['minor_unit'], 'Cent');
    expect(byCode['ZWG']!['minor_units_per_major'], 100);
    expect(byCode['ALL']!['iso_numeric'], '008');
    expect(byCode['DZD']!['iso_numeric'], '012');
    expect(byCode['SBD']!['iso_numeric'], '090');
  });

  test('fiat currency units are defined and localized for every record',
      () async {
    final records = (jsonDecode(await rootBundle.loadString(
      'assets/data/fiat_currencies.json',
    )) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final simplified = jsonDecode(await rootBundle.loadString(
      'assets/data/fiat_currency_overlays/zh_Hans.json',
    )) as Map<String, dynamic>;
    final traditional = jsonDecode(await rootBundle.loadString(
      'assets/data/fiat_currency_overlays/zh_Hant.json',
    )) as Map<String, dynamic>;
    final simplifiedEntries = simplified['entries'] as Map<String, dynamic>;
    final traditionalEntries = traditional['entries'] as Map<String, dynamic>;
    final aed = records.firstWhere((record) => record['iso_code'] == 'AED');

    expect(aed['major_unit'], 'Dirham');
    expect((simplifiedEntries['AED'] as Map<String, dynamic>)['major_unit'],
        '迪拉姆');
    expect((traditionalEntries['AED'] as Map<String, dynamic>)['major_unit'],
        '迪拉姆');

    for (final record in records) {
      final code = record['iso_code'] as String;
      expect(record['major_unit'], isA<String>(), reason: code);
      expect((record['major_unit'] as String).trim(), isNotEmpty, reason: code);
      expect(record['major_unit'], isNot(record['name']), reason: code);

      final minorUnit = record['minor_unit'];
      if (minorUnit == null) {
        expect(record['minor_units_per_major'], isNull, reason: code);
      } else {
        expect(minorUnit, isA<String>(), reason: code);
        expect(record['minor_units_per_major'], isA<int>(), reason: code);
      }

      for (final entries in [simplifiedEntries, traditionalEntries]) {
        final translated = entries[code] as Map<String, dynamic>;
        expect(translated['major_unit'], isA<String>(), reason: '$code major');
        if (minorUnit != null) {
          expect(translated['minor_unit'], isA<String>(),
              reason: '$code minor');
        }
      }
    }
  });
}
