class Currency {
  final String isoCode;
  final String? isoNumeric;
  final String name;
  final String? symbol;
  final List<String> regions;
  final List<String?> regionCodes;
  final String? description;
  final List<String> coins;
  final List<String> banknotes;

  Currency({
    required this.isoCode,
    this.isoNumeric,
    required this.name,
    this.symbol,
    this.regions = const [],
    this.regionCodes = const [],
    this.description,
    this.coins = const [],
    this.banknotes = const [],
  });

  factory Currency.fromMap(Map<String, dynamic> m) => Currency(
        isoCode: m['iso_code'] as String,
        isoNumeric: m['iso_numeric'] as String?,
        name: m['name'] as String,
        symbol: m['symbol'] as String?,
        regions: (m['regions'] as List<dynamic>?)?.cast<String>() ?? [],
        regionCodes:
            (m['region_codes'] as List<dynamic>?)?.cast<String?>() ?? const [],
        description: m['description'] as String?,
        coins: (m['coins'] as List<dynamic>?)?.cast<String>() ?? const [],
        banknotes:
            (m['banknotes'] as List<dynamic>?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toMap() => {
        'iso_code': isoCode,
        'iso_numeric': isoNumeric,
        'name': name,
        'symbol': symbol,
        'regions': regions,
        'region_codes': regionCodes,
        'description': description,
        'coins': coins,
        'banknotes': banknotes,
      };
}
