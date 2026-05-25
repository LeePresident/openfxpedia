import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/frankfurter_provider.dart';

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http.Response> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

void main() {
  group('FrankfurterProvider', () {
    test('parses v2 rates response into a normalized snapshot', () async {
      final client = _FakeHttpClient((request) async {
        expect(request.url.path, '/v2/rates');
        expect(request.url.queryParameters['base'], 'USD');
        return http.Response(
          jsonEncode([
            {
              'date': '2026-05-07',
              'base': 'USD',
              'quote': 'EUR',
              'rate': 0.92,
            },
            {
              'date': '2026-05-08',
              'base': 'USD',
              'quote': 'GBP',
              'rate': 0.79,
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = FrankfurterProvider(httpClient: client);
      final snapshot = await provider.fetchLatestRates('usd');

      expect(snapshot.sourceId, 'frankfurter');
      expect(snapshot.baseCurrency, 'usd');
      expect(snapshot.rates['eur'], closeTo(0.92, 0.00001));
      expect(snapshot.rates['gbp'], closeTo(0.79, 0.00001));
      expect(snapshot.quotedAt, DateTime.utc(2026, 5, 8));
    });

    test('uses v2 pair endpoint for target-aware lookups', () async {
      final client = _FakeHttpClient((request) async {
        expect(request.url.path, '/v2/rate/USD/EUR');
        return http.Response(
          jsonEncode({
            'date': '2026-05-09',
            'base': 'USD',
            'quote': 'EUR',
            'rate': 0.93,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = FrankfurterProvider(httpClient: client);
      final snapshot = await provider.fetchRateFor('usd', 'eur');

      expect(snapshot.sourceId, 'frankfurter');
      expect(snapshot.baseCurrency, 'usd');
      expect(snapshot.rates, {'eur': 0.93});
      expect(snapshot.quotedAt, DateTime.utc(2026, 5, 9));
    });

    test('throws ExchangeApiException when rates are missing', () async {
      final client = _FakeHttpClient(
        (_) async => http.Response(
          jsonEncode([]),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      final provider = FrankfurterProvider(httpClient: client);

      await expectLater(
        () => provider.fetchLatestRates('usd'),
        throwsA(isA<ExchangeApiException>()),
      );
    });
  });
}
