import 'dart:io';
import 'dart:developer' as developer;

Future<void> main() async {
  final dir = Directory('assets/icons');
  if (!await dir.exists()) {
    developer.log('No icons directory found.', name: 'generate_icon_mapping');
    return;
  }

  final entries = <String, String>{};
  await for (final f in dir.list()) {
    if (f is File && f.path.endsWith('.svg')) {
      final name = f.uri.pathSegments.last;
      final key = name.replaceAll('.svg', '').toLowerCase();
      entries[key] = 'assets/icons/$name';
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('const Map<String, String> iconAsset = {');
  entries.forEach((k, v) => buffer.writeln("  '$k': '$v',"));
  buffer.writeln('};');

  final out = File('lib/generated/icon_asset.dart');
  await out.create(recursive: true);
  await out.writeAsString(buffer.toString());
  developer.log('Generated lib/generated/icon_asset.dart',
      name: 'generate_icon_mapping');
}
