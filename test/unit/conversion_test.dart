import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/services/conversion_service.dart';
import 'package:openfxpedia/services/exchange_client.dart';
import 'package:openfxpedia/services/cache_service.dart';

class _FakeExchangeClient extends ExchangeClient {
  final Map<String, Map<String, double>> _rates;
  bool calledFetch = false;

  _FakeExchangeClient(this._rates);

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
  Future<Map<String, String>> fetchCurrencyCatalog() async => {};
}

class _StubCacheService extends CacheService {
  Map<String, double>? _storedRates;
  DateTime? _storedTimestamp;
  bool _stale;

  _StubCacheService({bool stale = true}) : _stale = stale;

  @override
  Future<void> init() async {}

  @override
  ({Map<String, double>? rates, DateTime? timestamp, bool stale})
      getCachedRates(
    String base, {
    int ttlHours = 12,
  }) {
    if (_storedRates == null) {
      return (rates: null, timestamp: null, stale: true);
    }
    return (rates: _storedRates, timestamp: _storedTimestamp, stale: _stale);
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
}

void main() {
  group('ConversionService', () {
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
        .._storedTimestamp = DateTime.now().toUtc();

      final client = _FakeExchangeClient({});
      final service = ConversionService(client: client, cache: cache);

      final result = await service.convert(50.0, 'USD', 'EUR');

      expect(result.fromCache, isTrue);
      expect(client.calledFetch, isFalse);
      expect(result.amount, closeTo(45.0, 0.00001));
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
