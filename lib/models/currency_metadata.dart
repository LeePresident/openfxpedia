class CurrencyMetadata {
  final String isoCode;
  final String? isoNumeric;
  final String? name;
  final String? symbol;
  final List<String> regions;
  final String? description;
  final List<String> coins;
  final List<String> banknotes;
  final String? majorUnit;
  final String? minorUnit;
  final int? minorUnitsPerMajor;

  const CurrencyMetadata({
    required this.isoCode,
    this.isoNumeric,
    this.name,
    this.symbol,
    this.regions = const [],
    this.description,
    this.coins = const [],
    this.banknotes = const [],
    this.majorUnit,
    this.minorUnit,
    this.minorUnitsPerMajor,
  });

  factory CurrencyMetadata.fromJson(Map<String, dynamic> json) {
    final isoCode =
        (json['iso_code'] ?? json['iso'] ?? '').toString().toUpperCase();
    final rawRegions = json['regions'];
    final rawCoins = json['coins'];
    final rawBanknotes = json['banknotes'];

    return CurrencyMetadata(
      isoCode: isoCode,
      isoNumeric: json['iso_numeric']?.toString(),
      name: json['name']?.toString(),
      symbol: json['symbol']?.toString(),
      regions: rawRegions is List
          ? rawRegions.whereType<String>().toList()
          : const [],
      description: json['description']?.toString(),
      coins:
          rawCoins is List ? rawCoins.whereType<String>().toList() : const [],
      banknotes: rawBanknotes is List
          ? rawBanknotes.whereType<String>().toList()
          : const [],
      majorUnit: json['major_unit']?.toString(),
      minorUnit: json['minor_unit']?.toString(),
      minorUnitsPerMajor: (json['minor_units_per_major'] as num?)?.toInt(),
    );
  }
}
