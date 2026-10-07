import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/rate_history_service.dart';

void main() {
  test('samples endpoints with bounded requests and unit amounts', () async {
    final conversion = _Conversion();
    final samples = await RateHistoryService(conversion).load(
      base: 'USD',
      target: 'EUR',
      endDate: DateTime(2024, 3, 31),
      days: 90,
      forceRefresh: true,
    );
    expect(samples.length, 8);
    expect(samples.first.requestedDate, DateTime.utc(2024, 1, 2));
    expect(samples.last.requestedDate, DateTime.utc(2024, 3, 31));
    expect(conversion.amounts, everyElement(1));
    expect(conversion.refreshes, everyElement(isTrue));
    expect(samples.map((sample) => sample.quote!.rate.source),
        everyElement('frankfurter'));
  });

  test('missing and out-of-range quotes remain gaps; actual dates survive',
      () async {
    final conversion = _Conversion()..withGaps = true;
    final samples = await RateHistoryService(conversion).load(
      base: 'USD',
      target: 'EUR',
      endDate: DateTime(2024, 3, 10),
      days: 7,
    );
    expect(samples[0].quote, isNull);
    expect(samples[1].quote, isNull);
    expect(samples[2].quote, isNull);
    expect(samples.last.quote!.rate.timestamp, DateTime.utc(2024, 3, 9));
    expect(samples.last.quote!.fromCache, isTrue);
  });

  test('cancellation stops additional dated lookups', () async {
    final conversion = _Conversion();
    final samples = await RateHistoryService(conversion).load(
      base: 'USD',
      target: 'EUR',
      endDate: DateTime(2024, 3, 10),
      days: 30,
      isCancelled: () => conversion.amounts.isNotEmpty,
    );
    expect(samples.length, 1);
    expect(conversion.amounts.length, 1);
  });
}

class _Conversion extends ConversionService {
  _Conversion() : super(client: ExchangeClient(), cache: CacheService());

  bool withGaps = false;
  final amounts = <double>[];
  final refreshes = <bool>[];

  @override
  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    amounts.add(amount);
    refreshes.add(forceRefresh);
    if (withGaps && amounts.length == 1) throw StateError('Unavailable');
    final offset = withGaps
        ? (amounts.length == 2 ? -10 : (amounts.length == 3 ? 1 : -1))
        : 0;
    return ConversionResult(
      amount: 0.9,
      rate: ExchangeRate(
        baseCurrency: base.toLowerCase(),
        targetCurrency: target.toLowerCase(),
        rate: 0.9,
        timestamp: date.add(Duration(days: offset)),
        source: 'frankfurter',
      ),
      fromCache: true,
    );
  }
}
