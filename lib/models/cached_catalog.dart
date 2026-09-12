class CachedCatalog {
  final Map<String, String>? catalog;
  final DateTime? timestamp;
  final bool isStale;

  const CachedCatalog({
    required this.catalog,
    required this.timestamp,
    required this.isStale,
  });
}
