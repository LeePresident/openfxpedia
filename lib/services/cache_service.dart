import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../core/config.dart';
import '../models/cached_catalog.dart';
import '../models/cached_rate_snapshot.dart';

class CacheService {
  late Box<String> _ratesBox;
  late Box<String> _currenciesBox;
  late Box<String> _prefsBox;

  static bool _compactWhenWasteful(int entries, int deletedEntries) {
    return entries > 0 && deletedEntries > 20 && deletedEntries / entries > 0.2;
  }

  bool _initialized = false;
  late Directory _supportDirectory;

  Future<void> init() async {
    if (_initialized) return;
    final supportDirectory = await getApplicationSupportDirectory();
    _supportDirectory = supportDirectory;
    Hive.init(supportDirectory.path);
    final encryptionKey = await _loadEncryptionKey(supportDirectory);
    final openedBoxes = <Box<String>>[];
    try {
      _ratesBox = await _openEncryptedBox(
        AppConfig.encryptedRatesBoxName,
        AppConfig.ratesBoxName,
        encryptionKey,
      );
      openedBoxes.add(_ratesBox);
      _currenciesBox = await _openEncryptedBox(
        AppConfig.encryptedCurrenciesBoxName,
        AppConfig.currenciesBoxName,
        encryptionKey,
      );
      openedBoxes.add(_currenciesBox);
      _prefsBox = await _openEncryptedBox(
        AppConfig.encryptedPrefsBoxName,
        AppConfig.prefsBoxName,
        encryptionKey,
      );
      openedBoxes.add(_prefsBox);
      _initialized = true;
    } catch (_) {
      for (final box in openedBoxes) {
        if (box.isOpen) await box.close();
      }
      rethrow;
    }
  }

  Future<List<int>> _loadEncryptionKey(Directory supportDirectory) async {
    final keyFile = File(
      '${supportDirectory.path}${Platform.pathSeparator}${AppConfig.hiveEncryptionKeyFileName}',
    );
    if (await keyFile.exists()) {
      return base64Url.decode(await keyFile.readAsString());
    }

    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await keyFile.writeAsString(base64UrlEncode(Uint8List.fromList(key)));
    return key;
  }

  Future<Box<String>> _openEncryptedBox(
    String name,
    String legacyName,
    List<int> encryptionKey,
  ) async {
    final cipher = HiveAesCipher(encryptionKey);
    try {
      final encryptedBox = await Hive.openBox<String>(
        name,
        encryptionCipher: cipher,
        compactionStrategy: _compactWhenWasteful,
      );
      if (encryptedBox.isEmpty && await _boxFileExists(legacyName)) {
        await _migrateLegacyBox(encryptedBox, legacyName, cipher);
      }
      return encryptedBox;
    } on HiveError {
      if (!await _boxFileExists(legacyName)) rethrow;
      final legacyValues = await _readLegacyValues(legacyName, cipher);
      final encryptedBox = await Hive.openBox<String>(
        name,
        encryptionCipher: cipher,
        compactionStrategy: _compactWhenWasteful,
      );
      for (final entry in legacyValues.entries) {
        await encryptedBox.put(entry.key, entry.value);
      }
      await _deleteLegacyBox(legacyName);
      return encryptedBox;
    }
  }

  Future<void> _migrateLegacyBox(
    Box<String> encryptedBox,
    String legacyName,
    HiveAesCipher cipher,
  ) async {
    final legacyValues = await _readLegacyValues(legacyName, cipher);
    try {
      for (final entry in legacyValues.entries) {
        await encryptedBox.put(entry.key, entry.value);
      }
      await _deleteLegacyBox(legacyName);
    } catch (_) {
      await encryptedBox.clear();
      await encryptedBox.compact();
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> _readLegacyValues(
    String legacyName,
    HiveAesCipher cipher,
  ) async {
    Box<String>? legacyBox;
    try {
      legacyBox = await Hive.openBox<String>(legacyName);
    } on HiveError {
      legacyBox = await Hive.openBox<String>(
        legacyName,
        encryptionCipher: cipher,
      );
    }
    final values = Map<dynamic, dynamic>.from(legacyBox.toMap());
    await legacyBox.close();
    return values;
  }

  Future<bool> _boxFileExists(String name) async {
    final hiveFile = File(
      '${_supportDirectory.path}${Platform.pathSeparator}$name.hive',
    );
    return hiveFile.exists();
  }

  Future<void> _deleteLegacyBox(String name) async {
    final hiveFile = File(
      '${_supportDirectory.path}${Platform.pathSeparator}$name.hive',
    );
    final lockFile = File(
      '${_supportDirectory.path}${Platform.pathSeparator}$name.lock',
    );
    if (await hiveFile.exists()) await hiveFile.delete();
    if (await lockFile.exists()) await lockFile.delete();
  }

  Future<void> putRateSnapshot(
    String base,
    Map<String, double> rates,
    DateTime timestamp, {
    String? source,
  }) async {
    final payload = jsonEncode({
      'rates': rates,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'source': source,
    });
    await _ratesBox.put(base.toLowerCase(), payload);
  }

  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {
    await putRateSnapshot(base, rates, timestamp);
  }

  CachedRateSnapshot getCachedRateSnapshot(
    String base, {
    int ttlHours = AppConfig.rateTtlHours,
  }) {
    final raw = _ratesBox.get(base.toLowerCase());
    if (raw == null) {
      return const CachedRateSnapshot(
        rates: null,
        timestamp: null,
        source: null,
        isStale: true,
      );
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp'] as String);
    final stale =
        DateTime.now().toUtc().difference(timestamp).inHours >= ttlHours;

    final rates = (decoded['rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    return CachedRateSnapshot(
      rates: rates,
      timestamp: timestamp,
      source: decoded['source'] as String?,
      isStale: stale,
    );
  }

  CachedRateSnapshot getCachedRates(
    String base, {
    int ttlHours = AppConfig.rateTtlHours,
  }) {
    final cached = getCachedRateSnapshot(base, ttlHours: ttlHours);
    return CachedRateSnapshot(
      rates: cached.rates,
      timestamp: cached.timestamp,
      source: cached.source,
      isStale: cached.isStale,
    );
  }

  Future<void> putCurrencyCatalog(
    Map<String, String> catalog,
    DateTime timestamp,
  ) async {
    final payload = jsonEncode({
      'catalog': catalog,
      'timestamp': timestamp.toUtc().toIso8601String(),
    });
    await _currenciesBox.put('catalog', payload);
  }

  CachedCatalog getCachedCatalog({
    int ttlHours = AppConfig.catalogTtlHours,
  }) {
    final raw = _currenciesBox.get('catalog');
    if (raw == null) {
      return const CachedCatalog(
        catalog: null,
        timestamp: null,
        isStale: true,
      );
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp'] as String);
    final stale =
        DateTime.now().toUtc().difference(timestamp).inHours >= ttlHours;

    final catalog = (decoded['catalog'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()));
    return CachedCatalog(
      catalog: catalog,
      timestamp: timestamp,
      isStale: stale,
    );
  }

  Future<void> putFavorites(List<String> favorites) async {
    await _prefsBox.put(AppConfig.favoritesKey, jsonEncode(favorites));
  }

  List<String> getFavorites() {
    final raw = _prefsBox.get(AppConfig.favoritesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  Future<void> putString(String key, String value) async {
    await _prefsBox.put(key, value);
  }

  String? getString(String key) => _prefsBox.get(key);

  // Convenience helpers for locale persistence
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefsBox.delete(AppConfig.localeKey);
    } else {
      await putString(AppConfig.localeKey, code);
    }
  }

  String? getLocaleCode() => getString(AppConfig.localeKey);

  Future<void> clearAll() async {
    await _ratesBox.clear();
    await _ratesBox.compact();
    await _currenciesBox.clear();
    await _currenciesBox.compact();
    await _prefsBox.clear();
    await _prefsBox.compact();
    await _deleteLegacyBox(AppConfig.ratesBoxName);
    await _deleteLegacyBox(AppConfig.currenciesBoxName);
    await _deleteLegacyBox(AppConfig.prefsBoxName);
  }

  Future<void> close() async {
    await _ratesBox.close();
    await _currenciesBox.close();
    await _prefsBox.close();
    _initialized = false;
  }
}
