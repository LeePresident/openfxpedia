import 'dart:math' as math;
import '../services/exchange_client.dart';
import '../services/cache_service.dart';
import '../models/exchange_rate.dart';

class ConversionResult {
  final double amount;
  final ExchangeRate rate;
  final bool fromCache;

  const ConversionResult({
    required this.amount,
    required this.rate,
    required this.fromCache,
  });
}

class ConversionService {
  final ExchangeClient _client;
  final CacheService _cache;

  ConversionService({
    required ExchangeClient client,
    required CacheService cache,
  })  : _client = client,
        _cache = cache;

  Future<ConversionResult> convert(
    double amount,
    String base,
    String target,
  ) async {
    final b = base.toLowerCase();
    final t = target.toLowerCase();

    Map<String, double> rates;
    DateTime timestamp;
    bool fromCache = false;
    String source = 'cache';

    final cached = _cache.getCachedRateSnapshot(b);
    final freshCacheHasRequestedRate = cached.rates?.containsKey(t) ?? false;
    final canUseFreshPrimaryCache = cached.rates != null &&
        !cached.stale &&
        cached.source == 'frankfurter' &&
        freshCacheHasRequestedRate;

    if (canUseFreshPrimaryCache) {
      rates = cached.rates!;
      timestamp = cached.timestamp!;
      fromCache = true;
      source = cached.source ?? 'cache';
    } else {
      try {
        final snapshot = await _client.fetchRateSnapshotFor(b, target: t);
        rates = snapshot.rates;
        timestamp = snapshot.quotedAt;
        source = snapshot.sourceId;
        await _cache.putRateSnapshot(
          b,
          rates,
          timestamp,
          source: snapshot.sourceId,
        );
      } catch (_) {
        if (cached.rates != null) {
          rates = cached.rates!;
          timestamp = cached.timestamp!;
          fromCache = true;
          source = cached.source ?? 'cache';
        } else {
          rethrow;
        }
      }
    }

    final rateValue = rates[t];
    if (rateValue == null) {
      throw ExchangeApiException('No rate found for target $target');
    }

    final convertedAmount = _roundToDecimals(amount * rateValue, 6);

    return ConversionResult(
      amount: convertedAmount,
      rate: ExchangeRate(
        baseCurrency: b,
        targetCurrency: t,
        rate: rateValue,
        timestamp: timestamp,
        source: source,
      ),
      fromCache: fromCache,
    );
  }

  Future<void> refreshRates(String base) async {
    final snapshot = await _client.fetchRateSnapshot(base.toLowerCase());
    await _cache.putRateSnapshot(
      base.toLowerCase(),
      snapshot.rates,
      snapshot.quotedAt,
      source: snapshot.sourceId,
    );
  }

  double _roundToDecimals(double value, int places) {
    final factor = math.pow(10, places).toDouble();
    return (value * factor).roundToDouble() / factor;
  }
}
