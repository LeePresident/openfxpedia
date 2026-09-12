class CurrencyMetadata {
  final String isoCode;
  final String? isoNumeric;
  final String? name;
  final String? symbol;
  final List<String> regions;
  final String? description;

  const CurrencyMetadata({
    required this.isoCode,
    this.isoNumeric,
    this.name,
    this.symbol,
    this.regions = const [],
    this.description,
  });

  factory CurrencyMetadata.fromJson(Map<String, dynamic> json) {
    final isoCode =
        (json['iso_code'] ?? json['iso'] ?? '').toString().toUpperCase();
    final rawRegions = json['regions'];

    return CurrencyMetadata(
      isoCode: isoCode,
      isoNumeric: json['iso_numeric']?.toString(),
      name: json['name']?.toString(),
      symbol: json['symbol']?.toString(),
      regions: rawRegions is List
          ? rawRegions.whereType<String>().toList()
          : const [],
      description: json['description']?.toString(),
    );
  }
}
