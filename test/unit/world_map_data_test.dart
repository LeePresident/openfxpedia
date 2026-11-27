import 'dart:io';
import 'dart:ui' show Path;

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/world_map_data.dart';

void main() {
  test('map geometry supports polygons, holes, and multiple islands', () {
    final map = WorldMapData.fromJson('''
      [
        {"name":"Example","code":"EX","geometry":{"type":"Polygon",
          "coordinates":[[[0,0],[10,0],[10,10],[0,10],[0,0]],
                         [[2,2],[4,2],[4,4],[2,4],[2,2]]]}},
        {"name":"Islands","code":"IS","geometry":{"type":"MultiPolygon",
          "coordinates":[[[[20,0],[22,0],[22,2],[20,2],[20,0]]],
                         [[[30,0],[32,0],[32,2],[30,2],[30,0]]]]}}
      ]
    ''');
    expect(map.regions[0].contains(const Offset(181, 89)), isTrue);
    expect(map.regions[0].contains(const Offset(183, 87)), isFalse);
    expect(map.regions[1].contains(const Offset(201, 89)), isTrue);
    expect(map.regions[1].contains(const Offset(211, 89)), isTrue);
    expect(map.regions[1].contains(const Offset(206, 89)), isFalse);
  });

  test('small regions have screen-sized targets without hiding neighbors', () {
    final map = WorldMapData.fromJson('''
      [
        {"name":"Large","code":"LA","geometry":{"type":"Polygon",
          "coordinates":[[[0,0],[20,0],[20,20],[0,20],[0,0]]]}},
        {"name":"Small","code":"SM","geometry":{"type":"Polygon",
          "coordinates":[[[5,5],[5.2,5],[5.2,5.2],[5,5.2],[5,5]]]}},
        {"name":"Other island","code":"SM","geometry":{"type":"Polygon",
          "coordinates":[[[5.3,5],[5.4,5],[5.4,5.1],[5.3,5.1],[5.3,5]]]}}
      ]
    ''');
    final near = map.regionsAt(
      const Offset(185.6, 84.9),
      mapUnitsPerPixel: 0.1,
    );
    expect(near.map((region) => region.code), ['SM', 'LA']);
    expect(
      map.regionsAt(const Offset(195, 75), mapUnitsPerPixel: 0.1).single.code,
      'LA',
    );
    expect(
      map
          .regionsAt(const Offset(185.6, 84.9), mapUnitsPerPixel: 0.01)
          .single
          .code,
      'LA',
    );
    expect(
      map.regionsAt(const Offset(250, 50), mapUnitsPerPixel: 0.1),
      isEmpty,
    );
  });

  test('borders merge neighboring subunits but retain country boundaries', () {
    final map = WorldMapData.fromJson('''
      [
        {"name":"West","code":"AA","geometry":{"type":"Polygon",
          "coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}},
        {"name":"East","code":"AA","geometry":{"type":"Polygon",
          "coordinates":[[[1,0],[2,0],[2,1],[1,1],[1,0]]]}},
        {"name":"Island","code":"AA","geometry":{"type":"Polygon",
          "coordinates":[[[4,0],[5,0],[5,1],[4,1],[4,0]]]}},
        {"name":"Neighbor","code":"BB","geometry":{"type":"Polygon",
          "coordinates":[[[2,0],[3,0],[3,1],[2,1],[2,0]]]}}
      ]
    ''');
    expect(map.regions, hasLength(4));
    expect(map.mapShapes, hasLength(2));
    final mergedPerimeter = map.mapShapes.first.path
        .computeMetrics()
        .fold<double>(0, (sum, metric) => sum + metric.length);
    expect(mergedPerimeter, closeTo(10, 0.001));
    expect(
      map.mapShapes.last.path.computeMetrics().single.length,
      closeTo(4, 0.001),
    );
    expect(map.regions[0].contains(const Offset(180.5, 89.5)), isTrue);
    expect(map.regions[1].contains(const Offset(181.5, 89.5)), isTrue);
  });

  test('bundled UK and Bosnia subunits no longer add internal borders', () {
    final map = WorldMapData.fromJson(
      File(
        ['assets', 'data', 'world-map-50m.json'].join(Platform.pathSeparator),
      ).readAsStringSync(),
    );
    double perimeter(Path path) =>
        path.computeMetrics().fold(0.0, (sum, metric) => sum + metric.length);

    for (final code in ['GB', 'BA']) {
      final subunits = map.regions.where((region) => region.code == code);
      final original = subunits.fold<double>(
        0,
        (sum, region) => sum + perimeter(region.path),
      );
      final merged = map.mapShapes.singleWhere((region) => region.code == code);
      expect(subunits.length, greaterThan(1));
      expect(perimeter(merged.path), lessThan(original - 0.1), reason: code);
      for (final region in subunits) {
        final bounds = region.bounds;
        for (var x = 1; x < 5; x++) {
          for (var y = 1; y < 5; y++) {
            final point = Offset(
              bounds.left + bounds.width * x / 5,
              bounds.top + bounds.height * y / 5,
            );
            expect(
              merged.contains(point),
              subunits.any((part) => part.contains(point)),
              reason: '$code at $point',
            );
          }
        }
      }
    }
  });
}
