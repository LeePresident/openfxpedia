class ExchangeRate {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime timestamp;
  final String source;

  ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.timestamp,
    required this.source,
  });

  factory ExchangeRate.fromMap(String base, String target, Map<String, dynamic> m) => ExchangeRate(
        baseCurrency: base,
        targetCurrency: target,
        rate: (m['rate'] as num).toDouble(),
        timestamp: DateTime.parse(m['timestamp'] as String),
        source: m['source'] as String,
      );

  Map<String, dynamic> toMap() => {
        'base_currency': baseCurrency,
        'target_currency': targetCurrency,
        'rate': rate,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'source': source,
      };
}
