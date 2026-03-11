import '../services/cache_service.dart';

class FavoritesService {
  final CacheService _cache;
  List<String> _favorites = [];

  FavoritesService({required CacheService cache}) : _cache = cache;

  List<String> get favorites => List.unmodifiable(_favorites);

  void load() {
    _favorites = _cache.getFavorites();
  }

  Future<void> add(String isoCode) async {
    final code = isoCode.toLowerCase();
    if (!_favorites.contains(code)) {
      _favorites = [..._favorites, code];
      await _cache.putFavorites(_favorites);
    }
  }

  Future<void> remove(String isoCode) async {
    final code = isoCode.toLowerCase();
    _favorites = _favorites.where((c) => c != code).toList();
    await _cache.putFavorites(_favorites);
  }

  Future<void> toggle(String isoCode) async {
    final code = isoCode.toLowerCase();
    if (_favorites.contains(code)) {
      await remove(code);
    } else {
      await add(code);
    }
  }

  bool isFavorite(String isoCode) =>
      _favorites.contains(isoCode.toLowerCase());
}
