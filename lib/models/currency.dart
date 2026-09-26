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
  final String? majorUnit;
  final String? minorUnit;
  final int? minorUnitsPerMajor;

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
    this.majorUnit,
    this.minorUnit,
    this.minorUnitsPerMajor,
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
        majorUnit: m['major_unit'] as String?,
        minorUnit: m['minor_unit'] as String?,
        minorUnitsPerMajor: m['minor_units_per_major'] as int?,
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
        'major_unit': majorUnit,
        'minor_unit': minorUnit,
        'minor_units_per_major': minorUnitsPerMajor,
      };
}
