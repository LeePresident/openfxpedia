import '../services/cache_service.dart';
import '../services/exchange_client.dart';

class CurrencyCatalogRepository {
  final ExchangeClient _client;
  final CacheService _cache;

  const CurrencyCatalogRepository({
    required ExchangeClient client,
    required CacheService cache,
  })  : _client = client,
        _cache = cache;

  Future<Map<String, String>> load({bool forceRefresh = false}) async {
    final cached = _cache.getCachedCatalog();
    if (!forceRefresh && cached.catalog != null && !cached.isStale) {
      return cached.catalog!;
    }

    try {
      final catalog = await _client.fetchCurrencyCatalog();
      await _cache.putCurrencyCatalog(catalog, DateTime.now().toUtc());
      return catalog;
    } catch (_) {
      if (cached.catalog != null) return cached.catalog!;
      rethrow;
    }
  }
}
