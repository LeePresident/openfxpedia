import 'dart:math' as math;
import '../services/exchange_client.dart';
import '../services/exchange_api_source.dart';
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
  ExchangeApiSource _preferredSource = ExchangeApiSource.auto;
  int _cacheWriteGeneration = 0;

  ExchangeApiSource get preferredSource => _preferredSource;

  ConversionService({
    required ExchangeClient client,
    required CacheService cache,
  })  : _client = client,
        _cache = cache;

  void setPreferredSource(ExchangeApiSource source) {
    _preferredSource = source;
  }

  void invalidatePendingCacheWrites() {
    _cacheWriteGeneration++;
  }

  Future<ConversionResult> convert(
    double amount,
    String base,
    String target,
  ) =>
      _convert(amount, base, target);

  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) =>
      _convert(amount, base, target, date: date, forceRefresh: forceRefresh);

  Future<ConversionResult> _convert(
    double amount,
    String base,
    String target, {
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    final cacheWriteGeneration = _cacheWriteGeneration;
    final preferredSource = _preferredSource;
    final b = base.toLowerCase();
    final t = target.toLowerCase();
    final requestedDate =
        date == null ? null : DateTime.utc(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (requestedDate != null && requestedDate.isAfter(today)) {
      throw ExchangeApiException('Future historical date');
    }
    final cacheKey = requestedDate == null
        ? b
        : 'history:$b:$t:${requestedDate.toIso8601String().split('T').first}:${preferredSource.storageValue}';

    Map<String, double> rates;
    DateTime timestamp;
    bool fromCache = false;
    String source = 'cache';

    final cached = _cache.getCachedRateSnapshot(cacheKey);
    final compatibleSource =
        requestedDate != null && preferredSource == ExchangeApiSource.auto
            ? cached.source == 'frankfurter' || cached.source == 'legacy'
            : _matchesPreferredSource(cached.source, preferredSource);
    final compatibleDate = requestedDate == null ||
        (cached.timestamp != null && !cached.timestamp!.isAfter(requestedDate));
    final freshCacheHasRequestedRate = cached.rates?.containsKey(t) ?? false;
    final canUseFreshPreferredCache = !forceRefresh &&
        cached.rates != null &&
        (!cached.isStale ||
            (requestedDate != null && requestedDate.isBefore(today))) &&
        compatibleSource &&
        compatibleDate &&
        freshCacheHasRequestedRate;

    if (canUseFreshPreferredCache) {
      rates = cached.rates!;
      timestamp = cached.timestamp!;
      fromCache = true;
      source = cached.source ?? 'cache';
    } else {
      try {
        final snapshot = requestedDate == null
            ? await _client.fetchRateSnapshotFor(
                b,
                target: t,
                preferredSource: preferredSource,
              )
            : await _client.fetchHistoricalRateSnapshotFor(
                b,
                target: t,
                date: requestedDate,
                preferredSource: preferredSource,
              );
        rates = snapshot.rates;
        timestamp = snapshot.quotedAt;
        source = snapshot.sourceId;
        if (cacheWriteGeneration == _cacheWriteGeneration) {
          await _cache.putRateSnapshot(
            cacheKey,
            rates,
            timestamp,
            source: snapshot.sourceId,
          );
        }
      } catch (_) {
        if (cached.rates != null &&
            freshCacheHasRequestedRate &&
            compatibleDate &&
            (compatibleSource ||
                (requestedDate == null && cached.source == null))) {
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
    final cacheWriteGeneration = _cacheWriteGeneration;
    final snapshot = await _client.fetchRateSnapshotFor(
      base.toLowerCase(),
      preferredSource: _preferredSource,
    );
    if (cacheWriteGeneration == _cacheWriteGeneration) {
      await _cache.putRateSnapshot(
        base.toLowerCase(),
        snapshot.rates,
        snapshot.quotedAt,
        source: snapshot.sourceId,
      );
    }
  }

  bool _matchesPreferredSource(
      String? source, ExchangeApiSource preferredSource) {
    if (source == null) {
      return false;
    }

    final normalized = source.toLowerCase();
    if (preferredSource == ExchangeApiSource.auto ||
        preferredSource == ExchangeApiSource.frankfurter) {
      return normalized.contains('frank');
    }

    return normalized.contains('legacy') ||
        normalized.contains('exchange_api') ||
        normalized.contains('exchangeapi');
  }

  double _roundToDecimals(double value, int places) {
    final factor = math.pow(10, places).toDouble();
    return (value * factor).roundToDouble() / factor;
  }
}
