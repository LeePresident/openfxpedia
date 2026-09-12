class CachedRateSnapshot {
  final Map<String, double>? rates;
  final DateTime? timestamp;
  final String? source;
  final bool isStale;

  const CachedRateSnapshot({
    required this.rates,
    required this.timestamp,
    required this.source,
    required this.isStale,
  });
}
