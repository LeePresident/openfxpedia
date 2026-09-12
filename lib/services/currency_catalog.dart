import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../services/cache_service.dart';
import '../services/exchange_client.dart';
import '../models/currency.dart';
import '../models/currency_metadata_catalog.dart';
import '../widgets/region_flag.dart' show regionCountryCode;
import 'currency_metadata_loader.dart';
import 'currency_localizer.dart';
import 'currency_overlay_loader.dart';
import 'currency_catalog_repository.dart';

class CurrencyCatalogService {
  final CurrencyCatalogRepository _repository;
  final CurrencyMetadataLoader _metadataLoader;
  final CurrencyOverlayLoader _overlayLoader;

  List<Currency>? _currencies;
  String? _currenciesLocaleKey;

  CurrencyMetadataCatalog? _metadataCatalog;

  CurrencyCatalogService({
    required ExchangeClient client,
    required CacheService cache,
    AssetBundle? bundle,
  })  : _repository = CurrencyCatalogRepository(
          client: client,
          cache: cache,
        ),
        _metadataLoader = CurrencyMetadataLoader(bundle: bundle ?? rootBundle),
        _overlayLoader = CurrencyOverlayLoader(bundle: bundle ?? rootBundle);

  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    final localeKey = _localeKey(locale);
    if (!forceRefresh &&
        _currenciesLocaleKey == localeKey &&
        _currencies != null) {
      return _currencies!;
    }

    _metadataCatalog ??= await _metadataLoader.load();
    final overlay = await _overlayLoader.load(localeKey);
    final localizer = CurrencyLocalizer(localeKey: localeKey);

    final catalog = await _repository.load(forceRefresh: forceRefresh);

    _currencies = catalog.entries.where((e) => _isFiatCurrency(e.key)).map((e) {
      final iso = e.key.toUpperCase();
      final meta = _metadataCatalog!.metadata[iso];
      final overlayEntry = overlay[iso];
      final baseName = meta?.name ?? _capitalize(e.value);
      final name = localizer.resolveField(
        isoCode: iso,
        field: 'name',
        baseValue: baseName,
        overlayEntry: overlayEntry,
      );
      final regions = localizer.resolveList(
        isoCode: iso,
        field: 'regions',
        baseValue: meta?.regions,
        overlayEntry: overlayEntry,
      );
      final regionCodes = <String?>[];
      for (var i = 0; i < regions.length; i++) {
        final baseRegion =
            i < (meta?.regions.length ?? 0) ? meta!.regions[i] : regions[i];
        regionCodes.add(regionCountryCode(baseRegion));
      }
      final description = localizer.resolveField(
        isoCode: iso,
        field: 'description',
        baseValue: meta?.description,
        overlayEntry: overlayEntry,
      );

      return Currency(
        isoCode: iso,
        isoNumeric: meta?.isoNumeric,
        name: name,
        symbol: meta?.symbol,
        regions: regions,
        regionCodes: regionCodes,
        description: description,
      );
    }).toList()
      ..sort((a, b) => a.isoCode.compareTo(b.isoCode));

    _currenciesLocaleKey = localeKey;

    return _currencies!;
  }

  Currency? findByCode(String code) {
    return _currencies?.firstWhere(
      (c) => c.isoCode.toLowerCase() == code.toLowerCase(),
      orElse: () => Currency(isoCode: code.toUpperCase(), name: code),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  bool _isFiatCurrency(String code) {
    final upperCode = code.toUpperCase();
    return _metadataCatalog?.codes.contains(upperCode) ?? false;
  }

  String _localeKey(Locale? locale) {
    if (locale == null) return 'en';
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hans') return 'zh_Hans';
      if (locale.scriptCode == 'Hant') return 'zh_Hant';

      switch (locale.countryCode?.toUpperCase()) {
        case 'HK':
        case 'MO':
        case 'TW':
          return 'zh_Hant';
        case 'CN':
        case 'SG':
        case 'MY':
          return 'zh_Hans';
      }

      return 'zh_Hant';
    }
    return 'en';
  }
}
