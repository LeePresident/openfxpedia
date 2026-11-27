import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

// The catalog explicitly includes these territories in their parent regions.
const _includedTerritories = <String, Set<String>>{
  'FI': {'AX'},
  'FR': {'BL', 'GF', 'GP', 'MF', 'MQ', 'PM', 'RE', 'YT'},
};

Set<String> mapCodesForCatalogRegion(String code) => {
  code,
  ...?_includedTerritories[code],
};

class MapRegion {
  MapRegion({required this.name, required this.code, required this.path})
    : bounds = path.getBounds();

  final String name;
  final String? code;
  final Path path;
  final Rect bounds;

  bool contains(Offset point) => bounds.contains(point) && path.contains(point);

  bool needsMarker(double mapUnitsPerPixel) =>
      code != null &&
      bounds.width < 8 * mapUnitsPerPixel &&
      bounds.height < 8 * mapUnitsPerPixel;
}

class WorldMapData {
  WorldMapData(this.regions) : mapShapes = _buildMapShapes(regions);

  final List<MapRegion> regions;
  final List<MapRegion> mapShapes;

  static List<MapRegion> _buildMapShapes(List<MapRegion> regions) {
    final grouped = <String, MapRegion>{};
    final ungrouped = <MapRegion>[];
    for (final region in regions) {
      final code = region.code;
      if (code == null) {
        ungrouped.add(region);
      } else {
        final previous = grouped[code];
        grouped[code] = previous == null
            ? region
            : MapRegion(
                name: previous.name,
                code: code,
                path: Path.combine(
                  PathOperation.union,
                  previous.path,
                  region.path,
                ),
              );
      }
    }
    return [...grouped.values, ...ungrouped];
  }

  List<MapRegion> regionsAt(Offset point, {required double mapUnitsPerPixel}) {
    final nearby = <(MapRegion, double)>[];
    final exact = <MapRegion>[];
    for (final region in regions.reversed) {
      if (region.contains(point)) exact.add(region);
      if (region.needsMarker(mapUnitsPerPixel)) {
        final distance = (region.bounds.center - point).distance;
        if (distance <= 12 * mapUnitsPerPixel) {
          nearby.add((region, distance));
        }
      }
    }
    nearby.sort((a, b) => a.$2.compareTo(b.$2));
    final seen = <String>{};
    return [
      for (final region in [...nearby.map((item) => item.$1), ...exact])
        if (seen.add(region.code ?? region.name)) region,
    ];
  }

  static Future<WorldMapData> load({AssetBundle? bundle}) async {
    final json = await (bundle ?? rootBundle).loadString(
      'assets/data/world-map-50m.json',
    );
    return WorldMapData.fromJson(json);
  }

  factory WorldMapData.fromJson(String source) {
    final features = jsonDecode(source) as List<dynamic>;
    return WorldMapData(
      features
          .map((item) {
            final feature = item as Map<String, dynamic>;
            final geometry = feature['geometry'] as Map<String, dynamic>;
            final coordinates = geometry['coordinates'] as List<dynamic>;
            final polygons = switch (geometry['type']) {
              'Polygon' => [coordinates],
              'MultiPolygon' => coordinates,
              _ => throw FormatException(
                'Unsupported map geometry: ${geometry['type']}',
              ),
            };
            final path = Path()..fillType = PathFillType.evenOdd;
            for (final polygon in polygons) {
              for (final ring in polygon as List<dynamic>) {
                var first = true;
                for (final coordinate in ring as List<dynamic>) {
                  final pair = coordinate as List<dynamic>;
                  final x = (pair[0] as num).toDouble() + 180;
                  final y = 90 - (pair[1] as num).toDouble();
                  if (first) {
                    path.moveTo(x, y);
                    first = false;
                  } else {
                    path.lineTo(x, y);
                  }
                }
                path.close();
              }
            }
            return MapRegion(
              name: feature['name'] as String,
              code: feature['code'] as String?,
              path: path,
            );
          })
          .toList(growable: false),
    );
  }
}
