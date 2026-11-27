import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/world_map_data.dart';
import 'package:openfxpedia/widgets/region_flag.dart';

void main() {
  test('every catalog region has a flag mapping', () {
    final catalog =
        jsonDecode(File('assets/data/fiat_currencies.json').readAsStringSync())
            as List<dynamic>;
    final regions = <String>{
      for (final currency in catalog)
        ...(currency['regions'] as List<dynamic>).cast<String>(),
    };
    final missing =
        regions.where((region) => regionCountryCode(region) == null).toList()
          ..sort();

    expect(missing, isEmpty, reason: 'Missing region flags: $missing');
  });

  test('offline map contains every mapped catalog region', () {
    final catalog =
        jsonDecode(File('assets/data/fiat_currencies.json').readAsStringSync())
            as List<dynamic>;
    final map = WorldMapData.fromJson(
      File('assets/data/world-map-50m.json').readAsStringSync(),
    );
    final mapCodes = map.regions.map((region) => region.code).toSet();
    final missing = <String>[];
    for (final currency in catalog) {
      for (final region
          in (currency['regions'] as List<dynamic>).cast<String>()) {
        final code = regionCountryCode(region);
        if (code != null && !mapCodes.contains(code)) missing.add(region);
      }
    }
    expect(missing, isEmpty, reason: 'Regions missing map geometry: $missing');
    expect(mapCodesForCatalogRegion('FI'), contains('AX'));
    expect(
      mapCodesForCatalogRegion('FR'),
      containsAll(['GF', 'GP', 'MQ', 'RE', 'YT']),
    );
    expect(mapCodesForCatalogRegion('FR'), isNot(contains('PF')));
  });
}
