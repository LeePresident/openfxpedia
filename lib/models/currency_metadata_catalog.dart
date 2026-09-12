import 'currency_metadata.dart';

class CurrencyMetadataCatalog {
  final Set<String> codes;
  final Map<String, CurrencyMetadata> metadata;

  const CurrencyMetadataCatalog({
    required this.codes,
    required this.metadata,
  });
}
