import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/core/config.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/providers/app_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/currency_catalog.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/favorites_service.dart';

void main() {
  test(
    'changing exchange source persists it and recalculates both features',
    () async {
      final cache = _MemoryCacheService();
      final conversion = _RecordingConversionService(cache);
      final client = ExchangeClient();
      final state = AppState(
        conversionService: conversion,
        catalogService: _StubCatalogService(client: client, cache: cache),
        favoritesService: FavoritesService(cache: cache),
        cacheService: cache,
        systemLocales: () => const [Locale('en')],
      );
      addTearDown(state.dispose);

      expect(await state.initialize(), isTrue);
      final usd = state.currencies.firstWhere(
        (currency) => currency.isoCode == 'USD',
      );
      final eur = state.currencies.firstWhere(
        (currency) => currency.isoCode == 'EUR',
      );

      state.setCurrencyPair(baseCurrency: usd, targetCurrency: eur);
      await state.convert();
      final entry = state.calculatorEntries.single;
      state.setCalculatorEntryAmount(entry.id, 10);
      await state.calculateCalculator();

      conversion.latestSources.clear();
      conversion.preciseSources.clear();
      await state.setExchangeApiSource(ExchangeApiSource.exchangeApi);

      expect(state.exchangeApiSource, ExchangeApiSource.exchangeApi);
      expect(
        cache.getString(AppConfig.exchangeApiSourceKey),
        ExchangeApiSource.exchangeApi.storageValue,
      );
      expect(conversion.preferredSource, ExchangeApiSource.exchangeApi);
      expect(conversion.latestSources, [ExchangeApiSource.exchangeApi]);
      expect(conversion.preciseSources, [ExchangeApiSource.exchangeApi]);
    },
  );
}

class _RecordingConversionService extends ConversionService {
  _RecordingConversionService(CacheService cache)
    : super(client: ExchangeClient(), cache: cache);

  final latestSources = <ExchangeApiSource>[];
  final preciseSources = <ExchangeApiSource>[];

  @override
  Future<ConversionResult> convert(
    double amount,
    String base,
    String target,
  ) async {
    latestSources.add(preferredSource);
    return _result(amount, base, target);
  }

  @override
  Future<ConversionResult> convertPrecise(
    double amount,
    String base,
    String target,
  ) async {
    preciseSources.add(preferredSource);
    return _result(amount, base, target);
  }

  ConversionResult _result(double amount, String base, String target) {
    return ConversionResult(
      amount: amount,
      rate: ExchangeRate(
        baseCurrency: base.toLowerCase(),
        targetCurrency: target.toLowerCase(),
        rate: 1,
        timestamp: DateTime.utc(2024, 1, 1),
        source: 'test',
      ),
      fromCache: false,
    );
  }
}

class _StubCatalogService extends CurrencyCatalogService {
  _StubCatalogService({required super.client, required super.cache});

  @override
  Future<List<Currency>> getCurrencies({
    bool forceRefresh = false,
    Locale? locale,
  }) async {
    return [
      Currency(isoCode: 'USD', name: 'US Dollar'),
      Currency(isoCode: 'EUR', name: 'Euro'),
    ];
  }
}

class _MemoryCacheService extends CacheService {
  final values = <String, String>{};

  @override
  Future<void> putString(String key, String value) async {
    values[key] = value;
  }

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> putFavorites(List<String> favorites) async {}

  @override
  List<String> getFavorites() => const [];

  @override
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      values.remove(AppConfig.localeKey);
    } else {
      values[AppConfig.localeKey] = code;
    }
  }

  @override
  String? getLocaleCode() => values[AppConfig.localeKey];
}
