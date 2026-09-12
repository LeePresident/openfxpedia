import 'dart:convert';
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

  Future<void> init() async {
    if (_initialized) return;
    final supportDirectory = await getApplicationSupportDirectory();
    Hive.init(supportDirectory.path);
    _ratesBox = await Hive.openBox<String>(
      AppConfig.ratesBoxName,
      compactionStrategy: _compactWhenWasteful,
    );
    _currenciesBox = await Hive.openBox<String>(
      AppConfig.currenciesBoxName,
      compactionStrategy: _compactWhenWasteful,
    );
    _prefsBox = await Hive.openBox<String>(
      AppConfig.prefsBoxName,
      compactionStrategy: _compactWhenWasteful,
    );
    _initialized = true;
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

  Future<void> close() async {
    await _ratesBox.close();
    await _currenciesBox.close();
    await _prefsBox.close();
    _initialized = false;
  }
}
