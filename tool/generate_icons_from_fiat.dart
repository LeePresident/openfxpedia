import 'dart:convert';
import 'dart:io';

String hslToHex(double h, double s, double l) {
  s /= 100;
  l /= 100;
  final c = (1 - (2 * l - 1).abs()) * s;
  final x = c * (1 - ((h / 60) % 2 - 1).abs());
  final m = l - c / 2;
  double r = 0, g = 0, b = 0;
  if (h < 60) {
    r = c;
    g = x;
    b = 0;
  } else if (h < 120) {
    r = x;
    g = c;
    b = 0;
  } else if (h < 180) {
    r = 0;
    g = c;
    b = x;
  } else if (h < 240) {
    r = 0;
    g = x;
    b = c;
  } else if (h < 300) {
    r = x;
    g = 0;
    b = c;
  } else {
    r = c;
    g = 0;
    b = x;
  }

  int R = ((r + m) * 255).round();
  int G = ((g + m) * 255).round();
  int B = ((b + m) * 255).round();
  String two(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${two(R)}${two(G)}${two(B)}';
}

Future<void> main() async {
  final jsonFile = File('assets/data/fiat_currencies.json');
  if (!await jsonFile.exists()) {
    stderr.writeln('fiat_currencies.json not found');
    exit(1);
  }

  final data = jsonDecode(await jsonFile.readAsString()) as List<dynamic>;
  final iconsDir = Directory('assets/icons');
  if (!await iconsDir.exists()) await iconsDir.create(recursive: true);

  for (var i = 0; i < data.length; i++) {
    final entry = data[i] as Map<String, dynamic>;
    final iso = (entry['iso_code'] as String).toUpperCase();
    final isoFile = iso.toLowerCase();
    final file = File('assets/icons/$isoFile.svg');
    if (await file.exists()) continue; // don't overwrite existing icons

    // generate two related colors using golden-angle stepping
    final hue = (i * 137.508) % 360; // golden angle
    final bg = hslToHex(hue, 65, 25); // darker background
    final circle = hslToHex((hue + 18) % 360, 60, 45); // lighter circle
    const textColor = '#F7FAFC';

    final svg =
        '''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="24" fill="$bg"/>
  <circle cx="64" cy="64" r="42" fill="$circle"/>
  <text x="64" y="72" text-anchor="middle" font-size="26" font-family="Arial, sans-serif" fill="$textColor">$iso</text>
</svg>
''';

    await file.writeAsString(svg);
    stdout.writeln('Created assets/icons/$isoFile.svg');
  }
  // also create a generic placeholder icon if it doesn't exist
  final genericFile = File('assets/icons/generic.svg');
  if (!await genericFile.exists()) {
    final hueG = ((data.length + 1) * 137.508) % 360;
    final bgG = hslToHex(hueG, 65, 25);
    final circleG = hslToHex((hueG + 18) % 360, 60, 45);
    const textColor = '#F7FAFC';

    final genericSvg =
        '''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="24" fill="$bgG"/>
  <circle cx="64" cy="64" r="42" fill="$circleG"/>
  <text x="64" y="72" text-anchor="middle" font-size="26" font-family="Arial, sans-serif" fill="$textColor">FX</text>
</svg>
''';

    await genericFile.writeAsString(genericSvg);
    stdout.writeln('Created assets/icons/generic.svg');
  }

  // normalize filenames in assets/icons: rename uppercase names to lowercase
  // or remove uppercase duplicates when lowercase target exists
  final dir = Directory('assets/icons');
  if (await dir.exists()) {
    final List<String> removed = [];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.svg')) {
        final fileName = entity.uri.pathSegments.last;
        final lower = fileName.toLowerCase();
        if (fileName != lower) {
          final lowerFile = File('${dir.path}/$lower');
          if (await lowerFile.exists()) {
            await entity.delete();
            removed.add(fileName);
          } else {
            await entity.rename('${dir.path}/$lower');
          }
        }
      }
    }

    if (removed.isNotEmpty) {
      stdout.writeln('Removed uppercase duplicates:');
      for (final f in removed) {
        stdout.writeln(' - $f');
      }
    }
  }

  stdout.writeln('Icon generation complete.');
}
