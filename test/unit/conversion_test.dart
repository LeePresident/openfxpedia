import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/cached_rate_snapshot.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/cache_service.dart';
import 'package:openfxpedia/services/exchange_provider.dart';

class _FakeExchangeClient extends ExchangeClient {
  final Map<String, Map<String, double>> _rates;
  final Map<String, Map<String, double>> _fallbackRates;
  bool calledFetch = false;
  ExchangeApiSource? lastPreferredSource;
  Completer<ExchangeRateSnapshot>? pendingSnapshot;
  DateTime? lastHistoricalDate;
  int historicalCalls = 0;
  bool historicalUnavailable = false;

  _FakeExchangeClient(this._rates,
      {Map<String, Map<String, double>>? fallbackRates})
      : _fallbackRates = fallbackRates ?? const {};

  @override
  Future<Map<String, double>> fetchRatesFor(String base) async {
    calledFetch = true;
    final key = base.toLowerCase();
    if (!_rates.containsKey(key)) {
      throw ExchangeApiException('no rates for $key');
    }
    return _rates[key]!;
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateSnapshot(String base) async {
    final rates = await fetchRatesFor(base);
    return ExchangeRateSnapshot(
      baseCurrency: base.toLowerCase(),
      quotedAt: DateTime.utc(2026, 5, 7),
      sourceId: 'frankfurter',
      rates: rates,
    );
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateSnapshotFor(
    String base, {
    String? target,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    if (pendingSnapshot != null) return pendingSnapshot!.future;
    final normalizedBase = base.toLowerCase();
    final normalizedTarget = target?.toLowerCase();
    lastPreferredSource = preferredSource;

    if (preferredSource == ExchangeApiSource.exchangeApi) {
      final fallbackRates = _fallbackRates[normalizedBase];
      if (fallbackRates == null ||
          (normalizedTarget != null &&
              !fallbackRates.containsKey(normalizedTarget))) {
        throw ExchangeApiException('no fallback rates for $normalizedBase');
      }

      return ExchangeRateSnapshot(
        baseCurrency: normalizedBase,
        quotedAt: DateTime.utc(2026, 5, 8),
        sourceId: 'legacy',
        rates: fallbackRates,
      );
    }

    final primary = await fetchRateSnapshot(normalizedBase);
    if (normalizedTarget == null ||
        primary.rates.containsKey(normalizedTarget)) {
      return primary;
    }

    final fallbackRates = _fallbackRates[normalizedBase];
    if (fallbackRates == null) {
      throw ExchangeApiException('no fallback rates for $normalizedBase');
    }

    return ExchangeRateSnapshot(
      baseCurrency: normalizedBase,
      quotedAt: DateTime.utc(2026, 5, 8),
      sourceId: 'legacy',
      rates: fallbackRates,
    );
  }

  @override
  Future<ExchangeRateSnapshot> fetchHistoricalRateSnapshotFor(
    String base, {
    required String target,
    required DateTime date,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    historicalCalls++;
    lastHistoricalDate = date;
    if (historicalUnavailable) throw ExchangeApiException('Unavailable');
    return fetchRateSnapshotFor(base,
        target: target, preferredSource: preferredSource);
  }

  @override
  Future<Map<String, String>> fetchCurrencyCatalog() async => {};
}

class _StubCacheService extends CacheService {
  final historicalSnapshots = <String, CachedRateSnapshot>{};
  Map<String, double>? _storedRates;
  DateTime? _storedTimestamp;
  String? _storedSource;
  bool _stale;

  _StubCacheService({bool stale = true}) : _stale = stale;

  @override
  Future<void> init() async {}

  @override
  CachedRateSnapshot getCachedRates(
    String base, {
    int ttlHours = 12,
  }) {
    if (_storedRates == null) {
      return const CachedRateSnapshot(
        rates: null,
        timestamp: null,
        source: null,
        isStale: true,
      );
    }
    return CachedRateSnapshot(
      rates: _storedRates,
      timestamp: _storedTimestamp,
      source: _storedSource,
      isStale: _stale,
    );
  }

  @override
  Future<void> putRates(
    String base,
    Map<String, double> rates,
    DateTime timestamp,
  ) async {
    _storedRates = rates;
    _storedTimestamp = timestamp;
    _stale = false;
  }

  @override
  CachedRateSnapshot getCachedRateSnapshot(
    String base, {
    int ttlHours = 12,
  }) {
    if (base.startsWith('history:')) {
      return historicalSnapshots[base] ??
          const CachedRateSnapshot(
            rates: null,
            timestamp: null,
            source: null,
            isStale: true,
          );
    }
    if (_storedRates == null) {
      return const CachedRateSnapshot(
        rates: null,
        timestamp: null,
        source: null,
        isStale: true,
      );
    }
    return CachedRateSnapshot(
      rates: _storedRates,
      timestamp: _storedTimestamp,
      source: _storedSource,
      isStale: _stale,
    );
  }

  @override
  Future<void> putRateSnapshot(
    String base,
    Map<String, double> rates,
    DateTime timestamp, {
    String? source,
  }) async {
    if (base.startsWith('history:')) {
      historicalSnapshots[base] = CachedRateSnapshot(
        rates: rates,
        timestamp: timestamp,
        source: source,
        isStale: true,
      );
      return;
    }
    _storedRates = rates;
    _storedTimestamp = timestamp;
    _storedSource = source;
    _stale = false;
  }
}

void main() {
  group('Historical conversion', () {
    test('isolates dates and latest cache, reuses past rates offline',
        () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92}
      });
      final cache = _StubCacheService(stale: false)
        .._storedRates = {'eur': 0.5}
        .._storedTimestamp = DateTime.now().toUtc()
        .._storedSource = 'frankfurter';
      final service = ConversionService(client: client, cache: cache);
      final date = DateTime(2026, 5, 10);
      final result = await service.convertHistorical(100, 'USD', 'EUR', date);
      expect(result.amount, 92);
      expect(result.fromCache, isFalse);
      expect(client.lastHistoricalDate, DateTime.utc(2026, 5, 10));
      expect(cache.getCachedRateSnapshot('usd').rates, {'eur': 0.5});
      client.historicalUnavailable = true;
      final offline = await service.convertHistorical(50, 'USD', 'EUR', date);
      expect(offline.amount, 46);
      expect(offline.fromCache, isTrue);
      expect(offline.rate.timestamp, DateTime.utc(2026, 5, 7));
      expect(client.historicalCalls, 1);
      await expectLater(
          service.convertHistorical(100, 'USD', 'EUR', DateTime(2026, 5, 11)),
          throwsA(isA<ExchangeApiException>()));
      await expectLater(service.convertHistorical(100, 'USD', 'GBP', date),
          throwsA(isA<ExchangeApiException>()));
    });

    test('refreshes selected date and falls back only to its cached quote',
        () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92}
      });
      final service =
          ConversionService(client: client, cache: _StubCacheService());
      final date = DateTime(2026, 5, 10);
      await service.convertHistorical(100, 'USD', 'EUR', date);
      final refreshed = await service.convertHistorical(100, 'USD', 'EUR', date,
          forceRefresh: true);
      expect(refreshed.fromCache, isFalse);
      client.historicalUnavailable = true;
      final offline = await service.convertHistorical(100, 'USD', 'EUR', date,
          forceRefresh: true);
      expect(offline.fromCache, isTrue);
      expect(client.historicalCalls, 3);
      service.setPreferredSource(ExchangeApiSource.exchangeApi);
      await expectLater(service.convertHistorical(100, 'USD', 'EUR', date),
          throwsA(isA<ExchangeApiException>()));
    });

    test('clear-data invalidation blocks historical cache writes', () async {
      final pending = Completer<ExchangeRateSnapshot>();
      final client = _FakeExchangeClient({})..pendingSnapshot = pending;
      final cache = _StubCacheService();
      final service = ConversionService(client: client, cache: cache);
      final request =
          service.convertHistorical(100, 'USD', 'EUR', DateTime(2026, 5, 10));
      service.invalidatePendingCacheWrites();
      pending.complete(ExchangeRateSnapshot(
        baseCurrency: 'usd',
        quotedAt: DateTime.utc(2026, 5, 8),
        sourceId: 'frankfurter',
        rates: {'eur': 0.92},
      ));
      await request;
      expect(cache.historicalSnapshots, isEmpty);
    });
  });

  group('ConversionService', () {
    for (final refresh in [false, true]) {
      test('invalidates pending ${refresh ? 'refresh' : 'conversion'} writes',
          () async {
        final pending = Completer<ExchangeRateSnapshot>();
        final client = _FakeExchangeClient({
          'usd': {'eur': 0.92},
        })
          ..pendingSnapshot = pending;
        final cache = _StubCacheService();
        final service = ConversionService(client: client, cache: cache);

        final request = refresh
            ? service.refreshRates('USD')
            : service.convert(100, 'USD', 'EUR');
        service.invalidatePendingCacheWrites();
        pending.complete(ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 7),
          sourceId: 'frankfurter',
          rates: {'eur': 0.92},
        ));
        await request;

        expect(cache.getCachedRateSnapshot('usd').rates, isNull);

        client.pendingSnapshot = null;
        await service.convert(100, 'USD', 'EUR');
        expect(cache.getCachedRateSnapshot('usd').rates, {'eur': 0.92});
      });
    }

    test('converts USD to EUR correctly using fresh rates', () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92, 'gbp': 0.79},
      });
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(100.0, 'USD', 'EUR');

      expect(result.amount, closeTo(92.0, 0.00001));
      expect(result.fromCache, isFalse);
      expect(result.rate.baseCurrency, 'usd');
      expect(result.rate.targetCurrency, 'eur');
    });

    test('returns cached result when cache is fresh', () async {
      final cache = _StubCacheService(stale: false)
        .._storedRates = {'eur': 0.90}
        .._storedTimestamp = DateTime.now().toUtc()
        .._storedSource = 'frankfurter';

      final client = _FakeExchangeClient({});
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(50.0, 'USD', 'EUR');

      expect(result.fromCache, isTrue);
      expect(client.calledFetch, isFalse);
      expect(result.amount, closeTo(45.0, 0.00001));
    });

    test('prefers live primary when fresh cache source is legacy', () async {
      final cache = _StubCacheService(stale: false)
        .._storedRates = {'eur': 0.90}
        .._storedTimestamp = DateTime.now().toUtc()
        .._storedSource = 'legacy';

      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92},
      });
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(50.0, 'USD', 'EUR');

      expect(result.fromCache, isFalse);
      expect(client.calledFetch, isTrue);
      expect(result.amount, closeTo(46.0, 0.00001));
      expect(result.rate.source, 'frankfurter');
    });

    test('uses fresh legacy cache when Exchange API is selected', () async {
      final cache = _StubCacheService(stale: false)
        .._storedRates = {'eur': 0.89}
        .._storedTimestamp = DateTime.now().toUtc()
        .._storedSource = 'legacy';

      final client = _FakeExchangeClient(
        {
          'usd': {'eur': 0.92},
        },
        fallbackRates: {
          'usd': {'eur': 0.90},
        },
      );
      final service = ConversionService(client: client, cache: cache)
        ..setPreferredSource(ExchangeApiSource.exchangeApi);

      final result = await service.convert(50.0, 'USD', 'EUR');

      expect(result.fromCache, isTrue);
      expect(client.calledFetch, isFalse);
      expect(result.amount, closeTo(44.5, 0.00001));
      expect(result.rate.source, 'legacy');
    });

    test('refreshes live rates when fresh Frankfurter cache lacks target',
        () async {
      final cache = _StubCacheService(stale: false)
        .._storedRates = {'eur': 0.90}
        .._storedTimestamp = DateTime.now().toUtc()
        .._storedSource = 'frankfurter';

      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92, 'gbp': 0.79},
      });
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(50.0, 'USD', 'GBP');

      expect(result.fromCache, isFalse);
      expect(client.calledFetch, isTrue);
      expect(result.amount, closeTo(39.5, 0.00001));
      expect(result.rate.source, 'frankfurter');
    });

    test('falls back to stale cache when network fails', () async {
      final cache = _StubCacheService(stale: true)
        .._storedRates = {'eur': 0.88}
        .._storedTimestamp =
            DateTime.now().toUtc().subtract(const Duration(hours: 24));

      final client = _FakeExchangeClient({});
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(10.0, 'USD', 'EUR');

      expect(result.fromCache, isTrue);
      expect(result.amount, closeTo(8.8, 0.00001));
    });

    test('throws when no cached or live rates available', () async {
      final client = _FakeExchangeClient({});
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      expect(
        () => service.convert(1.0, 'USD', 'EUR'),
        throwsA(isA<ExchangeApiException>()),
      );
    });

    test('handles zero amount', () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92}
      });
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(0.0, 'USD', 'EUR');
      expect(result.amount, 0.0);
    });

    test('uses snapshot source metadata for live results', () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92},
      });
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(100.0, 'USD', 'EUR');

      expect(result.fromCache, isFalse);
      expect(result.rate.source, 'frankfurter');
      expect(result.rate.timestamp, DateTime.utc(2026, 5, 7));
    });

    test('forwards selected Exchange API source to live conversions', () async {
      final client = _FakeExchangeClient(
        {
          'usd': {'eur': 0.92},
        },
        fallbackRates: {
          'usd': {'eur': 0.90},
        },
      );
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache)
        ..setPreferredSource(ExchangeApiSource.exchangeApi);

      final result = await service.convert(100.0, 'USD', 'EUR');

      expect(client.lastPreferredSource, ExchangeApiSource.exchangeApi);
      expect(result.fromCache, isFalse);
      expect(result.amount, closeTo(90.0, 0.00001));
      expect(result.rate.source, 'legacy');
    });

    test('preserves provider source when serving a cached result', () async {
      final client = _FakeExchangeClient({
        'usd': {'eur': 0.92},
      });
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      await service.convert(100.0, 'USD', 'EUR');

      final cachedService = ConversionService(
        client: _FakeExchangeClient({}),
        cache: cache,
      );
      final result = await cachedService.convert(100.0, 'USD', 'EUR');

      expect(result.fromCache, isTrue);
      expect(result.rate.source, 'frankfurter');
    });

    test('falls back when live primary rates miss the requested target',
        () async {
      final client = _FakeExchangeClient(
        {
          'usd': {'gbp': 0.79},
        },
        fallbackRates: {
          'usd': {'eur': 0.9},
        },
      );
      final cache = _StubCacheService(stale: true);
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(100.0, 'USD', 'EUR');

      expect(result.fromCache, isFalse);
      expect(result.amount, closeTo(90.0, 0.00001));
      expect(result.rate.source, 'legacy');
    });
  });

  group('ExchangeRate model', () {
    test('fromMap parses correctly', () {
      final rate = ExchangeRate.fromMap('usd', 'eur', {
        'rate': 0.92,
        'timestamp': '2026-03-09T00:00:00.000Z',
        'source': 'test',
      });

      expect(rate.baseCurrency, 'usd');
      expect(rate.targetCurrency, 'eur');
      expect(rate.rate, closeTo(0.92, 0.0001));
    });

    test('toMap round-trips correctly', () {
      final ts = DateTime.utc(2026, 3, 9);
      final rate = ExchangeRate(
        baseCurrency: 'usd',
        targetCurrency: 'eur',
        rate: 0.92,
        timestamp: ts,
        source: 'test',
      );

      final map = rate.toMap();
      expect(map['base_currency'], 'usd');
      expect(map['target_currency'], 'eur');
      expect(map['rate'], 0.92);
    });
  });
}
