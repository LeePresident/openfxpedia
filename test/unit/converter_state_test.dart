import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/providers/converter_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_client.dart';

void main() {
  test(
    'latest and historical conversions retain their date and source data',
    () async {
      final conversion = _RecordingConversion();
      final state = ConverterState(
        conversionService: conversion,
        onChanged: () {},
        onHistoryRefresh: () {},
      );
      final usd = Currency(isoCode: 'USD', name: 'US Dollar');
      final eur = Currency(isoCode: 'EUR', name: 'Euro');
      state.setCurrencyPair(baseCurrency: usd, targetCurrency: eur);
      state.setInputAmount(3);
      await state.convert();

      expect(state.convertedAmount, 6);
      expect(state.lastRate?.rate, 2);
      expect(state.loadingState, LoadingState.idle);

      await state.setConversionDate(DateTime(2024, 3, 10, 18));
      expect(conversion.historicalDates.last, DateTime(2024, 3, 10));
      expect(conversion.historicalForceRefreshes.last, isFalse);

      await state.refreshRates();
      expect(conversion.historicalForceRefreshes.last, isTrue);
    },
  );

  test(
    'reset prevents an in-flight conversion from restoring stale data',
    () async {
      final conversion = _DeferredConversion();
      final state = ConverterState(
        conversionService: conversion,
        onChanged: () {},
        onHistoryRefresh: () {},
      );
      final usd = Currency(isoCode: 'USD', name: 'US Dollar');
      final eur = Currency(isoCode: 'EUR', name: 'Euro');
      state.setCurrencyPair(baseCurrency: usd, targetCurrency: eur);
      await conversion.firstRequestStarted.future;
      final pendingConversion = state.convert();
      await conversion.secondRequestStarted.future;

      state.cancelPending();
      state.reset();
      for (final request in conversion.requests) {
        request.complete(_result(99, 'USD', 'EUR'));
      }
      await pendingConversion;

      expect(state.baseCurrency, isNull);
      expect(state.targetCurrency, isNull);
      expect(state.convertedAmount, isNull);
      expect(state.lastRate, isNull);
    },
  );

  test(
    'latest conversion failures expose a stable error and stop loading',
    () async {
      final conversion = _FailingConversion();
      final state = ConverterState(
        conversionService: conversion,
        onChanged: () {},
        onHistoryRefresh: () {},
      );
      state.setCurrencyPair(
        baseCurrency: Currency(isoCode: 'USD', name: 'US Dollar'),
        targetCurrency: Currency(isoCode: 'EUR', name: 'Euro'),
      );

      await state.convert();

      expect(state.loadingState, LoadingState.error);
      expect(state.errorCode, 'network');
      expect(state.convertedAmount, isNull);
    },
  );

  test(
    'historical conversion failures use the historical error code',
    () async {
      final conversion = _FailingConversion();
      final state = ConverterState(
        conversionService: conversion,
        onChanged: () {},
        onHistoryRefresh: () {},
      );
      state.setCurrencyPair(
        baseCurrency: Currency(isoCode: 'USD', name: 'US Dollar'),
        targetCurrency: Currency(isoCode: 'EUR', name: 'Euro'),
      );

      await state.setConversionDate(DateTime(2024, 3, 10));

      expect(state.loadingState, LoadingState.error);
      expect(state.errorCode, 'error_historical_unavailable');
      expect(state.convertedAmount, isNull);
    },
  );
}

class _RecordingConversion extends ConversionService {
  _RecordingConversion()
    : super(client: ExchangeClient(), cache: CacheService());

  final historicalDates = <DateTime>[];
  final historicalForceRefreshes = <bool>[];

  @override
  Future<ConversionResult> convert(
    double amount,
    String base,
    String target,
  ) async {
    return _result(amount * 2, base, target);
  }

  @override
  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    historicalDates.add(date);
    historicalForceRefreshes.add(forceRefresh);
    return _result(amount * 3, base, target);
  }
}

class _DeferredConversion extends ConversionService {
  _DeferredConversion()
    : super(client: ExchangeClient(), cache: CacheService());

  final List<Completer<ConversionResult>> requests = [];
  final Completer<void> firstRequestStarted = Completer<void>();
  final Completer<void> secondRequestStarted = Completer<void>();

  @override
  Future<ConversionResult> convert(double amount, String base, String target) {
    final request = Completer<ConversionResult>();
    requests.add(request);
    if (requests.length == 1) firstRequestStarted.complete();
    if (requests.length == 2) secondRequestStarted.complete();
    return request.future;
  }
}

class _FailingConversion extends ConversionService {
  _FailingConversion() : super(client: ExchangeClient(), cache: CacheService());

  @override
  Future<ConversionResult> convert(
    double amount,
    String base,
    String target,
  ) async {
    throw Exception('SocketException: failed host lookup');
  }

  @override
  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    throw Exception('historical quote missing');
  }
}

ConversionResult _result(double amount, String base, String target) {
  return ConversionResult(
    amount: amount,
    rate: ExchangeRate(
      baseCurrency: base.toLowerCase(),
      targetCurrency: target.toLowerCase(),
      rate: 2,
      timestamp: DateTime.utc(2024, 1, 1),
      source: 'test',
    ),
    fromCache: false,
  );
}
