import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openfxpedia/services/exchange_api_source.dart';
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
  group('Historical requests', () {
    test('fallback keeps the date and never calls latest endpoints', () async {
      final requests = <Uri>[];
      final client = ExchangeClient(httpClient: MockClient((request) async {
        requests.add(request.url);
        if (request.url.host == 'api.frankfurter.dev') {
          expect(request.url.queryParameters['date'], '2024-03-10');
          return http.Response('{}', 404);
        }
        if (request.url.host == 'cdn.jsdelivr.net') {
          expect(request.url.path, contains('@2024-03-10/'));
          return http.Response('{}', 503);
        }
        expect(request.url.host, '2024-03-10.currency-api.pages.dev');
        return http.Response(
            jsonEncode({
              'date': '2024-03-10',
              'usd': {'eur': 0.91},
            }),
            200);
      }));
      final snapshot = await client.fetchHistoricalRateSnapshotFor(
        'USD',
        target: 'EUR',
        date: DateTime(2024, 3, 10),
      );
      expect(snapshot.sourceId, 'legacy');
      expect(snapshot.quotedAt, DateTime.utc(2024, 3, 10));
      expect(snapshot.rates, {'eur': 0.91});
      expect(requests, hasLength(3));
      expect(requests.any((uri) => uri.toString().contains('latest')), isFalse);
    });

    test('forced Frankfurter failure does not fall back', () async {
      final client = ExchangeClient(httpClient: MockClient((request) async {
        expect(request.url.host, 'api.frankfurter.dev');
        return http.Response('{}', 404);
      }));
      await expectLater(
          client.fetchHistoricalRateSnapshotFor(
            'usd',
            target: 'eur',
            date: DateTime(2024, 3, 10),
            preferredSource: ExchangeApiSource.frankfurter,
          ),
          throwsA(isA<ExchangeApiException>()));
    });

    test('forced Exchange API rejects future-dated or missing quotes',
        () async {
      for (final body in [
        {
          'date': '2024-03-11',
          'usd': {'eur': 0.91}
        },
        {
          'usd': {'eur': 0.91}
        },
        {
          'date': '2024-03-10',
          'usd': {'gbp': 0.8}
        },
      ]) {
        final client = ExchangeClient(httpClient: MockClient((request) async {
          expect(request.url.host, 'cdn.jsdelivr.net');
          return http.Response(jsonEncode(body), 200);
        }));
        await expectLater(
            client.fetchHistoricalRateSnapshotFor(
              'usd',
              target: 'eur',
              date: DateTime(2024, 3, 10),
              preferredSource: ExchangeApiSource.exchangeApi,
            ),
            throwsA(isA<ExchangeApiException>()));
      }
    });
  });

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

    test('uses fallback provider only when Exchange API is selected', () async {
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
          rates: const {'eur': 0.90},
        ),
      );

      final client = ExchangeClient(
        primaryProvider: primary,
        fallbackProvider: fallback,
      );

      final snapshot = await client.fetchRateSnapshotFor(
        'usd',
        target: 'eur',
        preferredSource: ExchangeApiSource.exchangeApi,
      );

      expect(snapshot.sourceId, 'legacy');
      expect(primary.calls, 0);
      expect(fallback.calls, 1);
      expect(ExchangeObservability.events, hasLength(1));
      expect(ExchangeObservability.events.single['source'], 'legacy');
      expect(ExchangeObservability.events.single['status'], 'success');
    });

    test('does not fall back when Frankfurter is selected', () async {
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
          quotedAt: DateTime.utc(2026, 5, 6),
          sourceId: 'legacy',
          rates: const {'eur': 0.90},
        ),
      );

      final client = ExchangeClient(
        primaryProvider: primary,
        fallbackProvider: fallback,
      );

      await expectLater(
        () => client.fetchRateSnapshotFor(
          'usd',
          target: 'eur',
          preferredSource: ExchangeApiSource.frankfurter,
        ),
        throwsA(isA<ExchangeApiException>()),
      );
      expect(primary.calls, 1);
      expect(fallback.calls, 0);
      expect(ExchangeObservability.events, hasLength(2));
      expect(ExchangeObservability.events.first['status'], 'missing-rate');
      expect(ExchangeObservability.events.last['status'], 'failed');
    });
  });
}
