import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/favorites_service.dart';

class _StubCacheService extends CacheService {
  List<String> storedFavorites;
  int putCalls = 0;

  _StubCacheService({List<String>? initialFavorites})
      : storedFavorites = List<String>.from(initialFavorites ?? []);

  @override
  List<String> getFavorites() => List<String>.from(storedFavorites);

  @override
  Future<void> putFavorites(List<String> favorites) async {
    putCalls += 1;
    storedFavorites = List<String>.from(favorites);
  }

  @override
  Future<void> init() async {}

  @override
  ({Map<String, String>? catalog, DateTime? timestamp, bool stale})
      getCachedCatalog({int ttlHours = 12}) {
    return (catalog: null, timestamp: null, stale: true);
  }

  @override
  ({Map<String, double>? rates, DateTime? timestamp, bool stale})
      getCachedRates(
    String base, {
    int ttlHours = 12,
  }) {
    return (rates: null, timestamp: null, stale: true);
  }
}

void main() {
  group('FavoritesService', () {
    test('load reads persisted favorites', () {
      final cache = _StubCacheService(initialFavorites: ['usd', 'eur']);
      final service = FavoritesService(cache: cache);

      service.load();

      expect(service.favorites, ['usd', 'eur']);
      expect(service.isFavorite('USD'), isTrue);
      expect(service.isFavorite('eur'), isTrue);
    });

    test('add normalizes ISO to lowercase and persists', () async {
      final cache = _StubCacheService();
      final service = FavoritesService(cache: cache);

      await service.add('USD');

      expect(service.favorites, ['usd']);
      expect(cache.storedFavorites, ['usd']);
      expect(cache.putCalls, 1);
    });

    test('add ignores duplicates and avoids extra persistence', () async {
      final cache = _StubCacheService(initialFavorites: ['usd']);
      final service = FavoritesService(cache: cache)..load();

      await service.add('USD');

      expect(service.favorites, ['usd']);
      expect(cache.putCalls, 0);
    });

    test('remove is case-insensitive and persists', () async {
      final cache = _StubCacheService(initialFavorites: ['usd', 'eur']);
      final service = FavoritesService(cache: cache)..load();

      await service.remove('USD');

      expect(service.favorites, ['eur']);
      expect(cache.storedFavorites, ['eur']);
      expect(cache.putCalls, 1);
    });

    test('toggle adds when missing and removes when existing', () async {
      final cache = _StubCacheService();
      final service = FavoritesService(cache: cache);

      await service.toggle('JPY');
      expect(service.favorites, ['jpy']);
      expect(service.isFavorite('JPY'), isTrue);

      await service.toggle('jpy');
      expect(service.favorites, isEmpty);
      expect(service.isFavorite('jpy'), isFalse);
      expect(cache.putCalls, 2);
    });

    test('favorites getter returns unmodifiable list', () {
      final cache = _StubCacheService(initialFavorites: ['usd']);
      final service = FavoritesService(cache: cache)..load();

      expect(
        () => service.favorites.add('eur'),
        throwsUnsupportedError,
      );
    });
  });
}
