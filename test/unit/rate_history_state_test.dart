import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/providers/rate_history_state.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_client.dart';

void main() {
  test('hiding history cancels an in-flight load', () async {
    final conversion = _DeferredHistoricalConversion();
    final state = RateHistoryState(
      conversionService: conversion,
      onChanged: () {},
    );
    state.setVisible(true);
    final pendingLoad = state.load(
      base: 'USD',
      target: 'EUR',
      endDate: DateTime(2024, 3, 10),
      source: ExchangeApiSource.auto,
    );
    await conversion.requestStarted.future;

    state.setVisible(false);
    conversion.request.complete(
      _result(
        0.9,
        DateTime.utc(
          conversion.requestedDate!.year,
          conversion.requestedDate!.month,
          conversion.requestedDate!.day,
        ),
      ),
    );
    await pendingLoad;

    expect(state.visible, isFalse);
    expect(state.loading, isFalse);
    expect(state.samples, isEmpty);
  });

  test('only supported history windows can be selected', () {
    final state = RateHistoryState(
      conversionService: _DeferredHistoricalConversion(),
      onChanged: () {},
    );

    expect(state.setDays(7), isTrue);
    expect(state.days, 7);
    expect(() => state.setDays(14), throwsArgumentError);
  });
}

class _DeferredHistoricalConversion extends ConversionService {
  _DeferredHistoricalConversion()
      : super(client: ExchangeClient(), cache: CacheService());

  final Completer<ConversionResult> request = Completer<ConversionResult>();
  final Completer<void> requestStarted = Completer<void>();
  DateTime? requestedDate;

  @override
  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) {
    requestedDate = date;
    requestStarted.complete();
    return request.future;
  }
}

ConversionResult _result(double amount, DateTime timestamp) {
  return ConversionResult(
    amount: amount,
    rate: ExchangeRate(
      baseCurrency: 'usd',
      targetCurrency: 'eur',
      rate: 0.9,
      timestamp: timestamp,
      source: 'test',
    ),
    fromCache: false,
  );
}
