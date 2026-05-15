import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/exchange_provider.dart';
import 'package:openfxpedia/services/exchange_observability.dart';

class _FakeProvider implements ExchangeProvider {
  _FakeProvider({
    required this.sourceId,
    this.snapshot,
    this.error,
  });

  @override
  final String sourceId;

  final ExchangeRateSnapshot? snapshot;
  final Exception? error;
  int calls = 0;

  @override
  Future<ExchangeRateSnapshot> fetchLatestRates(String base) async {
    calls += 1;
    if (error != null) {
      throw error!;
    }
    return snapshot!;
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateFor(String base, String target) async {
    return fetchLatestRates(base);
  }
}

void main() {
  group('ExchangeClient primary/fallback orchestration', () {
    setUp(ExchangeObservability.clear);

    test('returns primary snapshot when primary succeeds', () async {
      final primary = _FakeProvider(
        sourceId: 'frankfurter',
        snapshot: ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 7),
          sourceId: 'frankfurter',
          rates: const {'eur': 0.92},
        ),
      );
      final fallback = _FakeProvider(
        sourceId: 'legacy',
        snapshot: ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 6),
          sourceId: 'legacy',
          rates: const {'eur': 0.91},
        ),
      );

      final client = ExchangeClient(
        primaryProvider: primary,
        fallbackProvider: fallback,
      );

      final snapshot = await client.fetchRateSnapshot('usd');

      expect(snapshot.sourceId, 'frankfurter');
      expect(primary.calls, 1);
      expect(fallback.calls, 0);
      expect(ExchangeObservability.events, hasLength(1));
      expect(ExchangeObservability.events.single['status'], 'success');
    });

    test('falls back when primary provider fails', () async {
      final primary = _FakeProvider(
        sourceId: 'frankfurter',
        error: ExchangeApiException('timeout'),
      );
      final fallback = _FakeProvider(
        sourceId: 'legacy',
        snapshot: ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 7),
          sourceId: 'legacy',
          rates: const {'eur': 0.9},
        ),
      );

      final client = ExchangeClient(
        primaryProvider: primary,
        fallbackProvider: fallback,
      );

      final snapshot = await client.fetchRateSnapshot('usd');

      expect(snapshot.sourceId, 'legacy');
      expect(primary.calls, 1);
      expect(fallback.calls, 1);
      expect(ExchangeObservability.events, hasLength(2));
      expect(ExchangeObservability.events.first['status'], 'failed');
      expect(ExchangeObservability.events.last['status'], 'success');
      expect(ExchangeObservability.events.last['source'], 'legacy');
    });

    test('falls back when primary snapshot is missing the requested rate',
        () async {
      final primary = _FakeProvider(
        sourceId: 'frankfurter',
        snapshot: ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 7),
          sourceId: 'frankfurter',
          rates: const {'gbp': 0.79},
        ),
      );
      final fallback = _FakeProvider(
        sourceId: 'legacy',
        snapshot: ExchangeRateSnapshot(
          baseCurrency: 'usd',
          quotedAt: DateTime.utc(2026, 5, 7),
          sourceId: 'legacy',
          rates: const {'eur': 0.9},
        ),
      );

      final client = ExchangeClient(
        primaryProvider: primary,
        fallbackProvider: fallback,
      );

      final snapshot = await client.fetchRateSnapshotFor('usd', target: 'eur');

      expect(snapshot.sourceId, 'legacy');
      expect(primary.calls, 1);
      expect(fallback.calls, 1);
      expect(ExchangeObservability.events, hasLength(2));
      expect(ExchangeObservability.events.first['status'], 'missing-rate');
      expect(ExchangeObservability.events.last['source'], 'legacy');
    });
  });
}
