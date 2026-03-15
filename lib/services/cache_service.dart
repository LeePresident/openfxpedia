import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/config.dart';

class CacheService {
  late Box<String> _ratesBox;
  late Box<String> _currenciesBox;
  late Box<String> _prefsBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _ratesBox = await Hive.openBox<String>(AppConfig.ratesBoxName);
    _currenciesBox = await Hive.openBox<String>(AppConfig.currenciesBoxName);
    _prefsBox = await Hive.openBox<String>(AppConfig.prefsBoxName);
    _initialized = true;
  }

  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {
    final payload = jsonEncode({
      'rates': rates,
      'timestamp': timestamp.toUtc().toIso8601String(),
    });
    await _ratesBox.put(base.toLowerCase(), payload);
  }

  ({Map<String, double>? rates, DateTime? timestamp, bool stale})
      getCachedRates(
    String base, {
    int ttlHours = AppConfig.rateTtlHours,
  }) {
    final raw = _ratesBox.get(base.toLowerCase());
    if (raw == null) return (rates: null, timestamp: null, stale: true);

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp'] as String);
    final stale =
        DateTime.now().toUtc().difference(timestamp).inHours >= ttlHours;

    final rates = (decoded['rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    return (rates: rates, timestamp: timestamp, stale: stale);
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

  ({Map<String, String>? catalog, DateTime? timestamp, bool stale})
      getCachedCatalog({
    int ttlHours = AppConfig.catalogTtlHours,
  }) {
    final raw = _currenciesBox.get('catalog');
    if (raw == null) return (catalog: null, timestamp: null, stale: true);

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final timestamp = DateTime.parse(decoded['timestamp'] as String);
    final stale =
        DateTime.now().toUtc().difference(timestamp).inHours >= ttlHours;

    final catalog = (decoded['catalog'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()));
    return (catalog: catalog, timestamp: timestamp, stale: stale);
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

  Future<void> close() async {
    await _ratesBox.close();
    await _currenciesBox.close();
    await _prefsBox.close();
    _initialized = false;
  }
}
