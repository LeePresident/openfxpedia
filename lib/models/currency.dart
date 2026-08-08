class Currency {
  final String isoCode;
  final String? isoNumeric;
  final String name;
  final String? symbol;
  final String? iconAsset;
  final List<String> regions;
  final String? description;

  Currency({
    required this.isoCode,
    this.isoNumeric,
    required this.name,
    this.symbol,
    this.iconAsset,
    this.regions = const [],
    this.description,
  });

  factory Currency.fromMap(Map<String, dynamic> m) => Currency(
        isoCode: m['iso_code'] as String,
        isoNumeric: m['iso_numeric'] as String?,
        name: m['name'] as String,
        symbol: m['symbol'] as String?,
        iconAsset: m['icon_asset'] as String?,
        regions: (m['regions'] as List<dynamic>?)?.cast<String>() ?? [],
        description: m['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'iso_code': isoCode,
        'iso_numeric': isoNumeric,
        'name': name,
        'symbol': symbol,
        'icon_asset': iconAsset,
        'regions': regions,
        'description': description,
      };
}
