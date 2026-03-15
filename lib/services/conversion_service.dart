import 'dart:math' as math;
import '../services/exchange_client.dart';
import '../services/cache_service.dart';
import '../models/exchange_rate.dart';
import '../core/config.dart';

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

    final cached = _cache.getCachedRates(b);
    if (cached.rates != null && !cached.stale) {
      rates = cached.rates!;
      timestamp = cached.timestamp!;
      fromCache = true;
    } else {
      try {
        rates = await _client.fetchRatesFor(b);
        timestamp = DateTime.now().toUtc();
        await _cache.putRates(b, rates, timestamp);
      } catch (_) {
        if (cached.rates != null) {
          rates = cached.rates!;
          timestamp = cached.timestamp!;
          fromCache = true;
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
        source: fromCache ? 'cache' : AppConfig.exchangeApiBase,
      ),
      fromCache: fromCache,
    );
  }

  Future<void> refreshRates(String base) async {
    final rates = await _client.fetchRatesFor(base.toLowerCase());
    await _cache.putRates(base.toLowerCase(), rates, DateTime.now().toUtc());
  }

  double _roundToDecimals(double value, int places) {
    final factor = math.pow(10, places).toDouble();
    return (value * factor).roundToDouble() / factor;
  }
}
