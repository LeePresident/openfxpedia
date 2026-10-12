class CachedRateSnapshot {
  final Map<String, double>? rates;
  final DateTime? timestamp;
  final DateTime? fetchedAt;
  final String? source;
  final bool isStale;

  const CachedRateSnapshot({
    required this.rates,
    required this.timestamp,
    this.fetchedAt,
    required this.source,
    required this.isStale,
  });
}
