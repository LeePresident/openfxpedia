import 'dart:math' as math;
import '../services/exchange_client.dart';
import '../services/exchange_api_source.dart';
import '../services/cache_service.dart';
import '../services/exchange_provider.dart';
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

class LatestRatesResult {
  final Map<String, double> rates;
  final DateTime timestamp;
  final String source;
  final bool fromCache;

  LatestRatesResult({
    required Map<String, double> rates,
    required this.timestamp,
    required this.source,
    required this.fromCache,
  }) : rates = Map.unmodifiable(rates);
}

class ConversionService {
  final ExchangeClient _client;
  final CacheService _cache;
  ExchangeApiSource _preferredSource = ExchangeApiSource.auto;
  int _cacheWriteGeneration = 0;
  final Map<String, Future<ExchangeRateSnapshot>> _pendingLatestSnapshots = {};

  ExchangeApiSource get preferredSource => _preferredSource;

  ConversionService({
    required ExchangeClient client,
    required CacheService cache,
  }) : _client = client,
       _cache = cache;

  void setPreferredSource(ExchangeApiSource source) {
    _preferredSource = source;
  }

  void invalidatePendingCacheWrites() {
    _cacheWriteGeneration++;
    _pendingLatestSnapshots.clear();
  }

  Future<ConversionResult> convert(double amount, String base, String target) =>
      _convert(amount, base, target);

  Future<ConversionResult> convertPrecise(
    double amount,
    String base,
    String target,
  ) => _convert(amount, base, target, roundAmount: false);

  Future<ConversionResult> convertHistorical(
    double amount,
    String base,
    String target,
    DateTime date, {
    bool forceRefresh = false,
  }) => _convert(amount, base, target, date: date, forceRefresh: forceRefresh);

  Future<ConversionResult> convertHistoricalPrecise(
    double amount,
    String base,
    String target,
    DateTime date,
  ) => _convert(amount, base, target, date: date, roundAmount: false);

  Future<LatestRatesResult> loadLatestRates(
    String base, {
    bool forceRefresh = false,
  }) async {
    final normalizedBase = base.toLowerCase();
    final preferredSource = _preferredSource;
    final cacheWriteGeneration = _cacheWriteGeneration;
    final cached = _cache.getCachedRateSnapshot(normalizedBase);
    final compatibleSource = _matchesPreferredSource(
      cached.source,
      preferredSource,
    );

    if (!forceRefresh &&
        cached.rates != null &&
        cached.timestamp != null &&
        !cached.isStale &&
        compatibleSource) {
      return LatestRatesResult(
        rates: cached.rates!,
        timestamp: cached.timestamp!,
        source: cached.source!,
        fromCache: true,
      );
    }

    try {
      final snapshot = await _fetchLatestSnapshot(
        normalizedBase,
        preferredSource: preferredSource,
      );
      if (snapshot.baseCurrency != normalizedBase ||
          snapshot.rates.isEmpty ||
          snapshot.rates.values.any((rate) => !rate.isFinite || rate <= 0)) {
        throw ExchangeApiException('Invalid latest rates snapshot');
      }
      if (cacheWriteGeneration == _cacheWriteGeneration) {
        await _cache.putRateSnapshot(
          normalizedBase,
          snapshot.rates,
          snapshot.quotedAt,
          source: snapshot.sourceId,
        );
      }
      return LatestRatesResult(
        rates: snapshot.rates,
        timestamp: snapshot.quotedAt,
        source: snapshot.sourceId,
        fromCache: false,
      );
    } catch (_) {
      if (cached.rates != null &&
          cached.timestamp != null &&
          (compatibleSource ||
              (preferredSource == ExchangeApiSource.auto &&
                  cached.source == null))) {
        return LatestRatesResult(
          rates: cached.rates!,
          timestamp: cached.timestamp!,
          source: cached.source ?? 'cache',
          fromCache: true,
        );
      }
      rethrow;
    }
  }

  Future<ConversionResult> _convert(
    double amount,
    String base,
    String target, {
    DateTime? date,
    bool forceRefresh = false,
    bool roundAmount = true,
  }) async {
    final cacheWriteGeneration = _cacheWriteGeneration;
    final preferredSource = _preferredSource;
    final b = base.toLowerCase();
    final t = target.toLowerCase();
    final requestedDate = date == null
        ? null
        : DateTime.utc(date.year, date.month, date.day);
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
    final compatibleDate =
        requestedDate == null ||
        (cached.timestamp != null && !cached.timestamp!.isAfter(requestedDate));
    final freshCacheHasRequestedRate = cached.rates?.containsKey(t) ?? false;
    final canUseFreshPreferredCache =
        !forceRefresh &&
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
            ? await _fetchLatestSnapshot(
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

    final convertedAmount = roundAmount
        ? _roundToDecimals(amount * rateValue, 6)
        : amount * rateValue;

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
    final snapshot = await _fetchLatestSnapshot(
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

  Future<ExchangeRateSnapshot> _fetchLatestSnapshot(
    String base, {
    String? target,
    required ExchangeApiSource preferredSource,
  }) {
    final key =
        '${base.toLowerCase()}:${target ?? ''}:${preferredSource.storageValue}';
    final pending = _pendingLatestSnapshots[key];
    if (pending != null) return pending;

    final request = Future<ExchangeRateSnapshot>.sync(
      () => _client.fetchRateSnapshotFor(
        base.toLowerCase(),
        target: target,
        preferredSource: preferredSource,
      ),
    );
    late final Future<ExchangeRateSnapshot> trackedRequest;
    trackedRequest = request.whenComplete(() {
      if (identical(_pendingLatestSnapshots[key], trackedRequest)) {
        _pendingLatestSnapshots.remove(key);
      }
    });
    _pendingLatestSnapshots[key] = trackedRequest;
    return trackedRequest;
  }

  bool _matchesPreferredSource(
    String? source,
    ExchangeApiSource preferredSource,
  ) {
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
