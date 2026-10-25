import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/providers/calculator_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_client.dart';

void main() {
  test(
    'calculates line results and rounds the total to output minor units',
    () async {
      final currency = Currency(
        isoCode: 'USD',
        name: 'US Dollar',
        minorUnitsPerMajor: 100,
      );
      final currencies = [currency];
      final state = CalculatorState(
        conversionService: _ImmediateConversion(),
        currencies: () => currencies,
        onChanged: () {},
      );
      state.initialize(baseCurrency: currency, targetCurrency: currency);

      final firstEntry = state.entries.single;
      state.setEntryAmount(firstEntry.id, 1);
      state.addEntry();
      final secondEntry = state.entries.last;
      state.setEntryAmount(secondEntry.id, 1);
      await state.calculate();

      expect(state.total, 2.01);
      expect(state.loading, isFalse);
      expect(
        state.lineResults.keys,
        containsAll([firstEntry.id, secondEntry.id]),
      );
    },
  );

  test('reset discards pending conversion results', () async {
    final currency = Currency(isoCode: 'USD', name: 'US Dollar');
    final conversion = _DeferredConversion();
    final state = CalculatorState(
      conversionService: conversion,
      currencies: () => [currency],
      onChanged: () {},
    );
    state.initialize(baseCurrency: currency, targetCurrency: currency);

    state.setEntryAmount(state.entries.single.id, 1);
    await conversion.firstRequestStarted.future;
    final pendingCalculation = state.calculate();
    await conversion.secondRequestStarted.future;

    state.reset();
    for (final request in conversion.requests) {
      request.complete(_result(1, 'USD', 'USD'));
    }
    await pendingCalculation;

    expect(state.entries, isEmpty);
    expect(state.total, isNull);
    expect(state.lineResults, isEmpty);
    expect(state.loading, isFalse);
    expect(state.errorCode, isNull);
  });

  test(
    'conversion failures clear loading state and expose a stable error',
    () async {
      final currency = Currency(isoCode: 'USD', name: 'US Dollar');
      final state = CalculatorState(
        conversionService: _FailingConversion(),
        currencies: () => [currency],
        onChanged: () {},
      );
      state.initialize(baseCurrency: currency, targetCurrency: currency);
      state.setEntryAmount(state.entries.single.id, 10);

      await state.calculate();

      expect(state.loading, isFalse);
      expect(state.total, isNull);
      expect(state.errorCode, 'network');
    },
  );

  test(
    'future calculator dates are rejected without changing the date',
    () async {
      final currency = Currency(isoCode: 'USD', name: 'US Dollar');
      final state = CalculatorState(
        conversionService: _ImmediateConversion(),
        currencies: () => [currency],
        onChanged: () {},
      );
      state.initialize(baseCurrency: currency, targetCurrency: currency);

      await expectLater(
        state.setDate(DateTime.now().add(const Duration(days: 1))),
        throwsArgumentError,
      );
      expect(state.date, isNull);
    },
  );
}

class _ImmediateConversion extends ConversionService {
  _ImmediateConversion()
    : super(client: ExchangeClient(), cache: CacheService());

  @override
  Future<ConversionResult> convertPrecise(
    double amount,
    String base,
    String target,
  ) async {
    const rate = 1.003;
    return ConversionResult(
      amount: amount * rate,
      rate: _rate(base, target, rate),
      fromCache: false,
    );
  }
}

class _DeferredConversion extends ConversionService {
  _DeferredConversion()
    : super(client: ExchangeClient(), cache: CacheService());

  final List<Completer<ConversionResult>> requests = [];
  final Completer<void> firstRequestStarted = Completer<void>();
  final Completer<void> secondRequestStarted = Completer<void>();

  @override
  Future<ConversionResult> convertPrecise(
    double amount,
    String base,
    String target,
  ) {
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
  Future<ConversionResult> convertPrecise(
    double amount,
    String base,
    String target,
  ) async {
    throw Exception('SocketException: failed host lookup');
  }
}

ConversionResult _result(double amount, String base, String target) {
  return ConversionResult(
    amount: amount,
    rate: _rate(base, target, 1),
    fromCache: false,
  );
}

ExchangeRate _rate(String base, String target, double rate) {
  return ExchangeRate(
    baseCurrency: base.toLowerCase(),
    targetCurrency: target.toLowerCase(),
    rate: rate,
    timestamp: DateTime.utc(2024, 1, 1),
    source: 'test',
  );
}
