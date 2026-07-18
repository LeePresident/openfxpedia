import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import 'exchange_api_exception.dart';
import 'exchange_api_source.dart';
import 'exchange_observability.dart';
import 'exchange_provider.dart';
import 'frankfurter_provider.dart';

export 'exchange_api_exception.dart';

class ExchangeClient {
  late final http.Client _httpClient;
  late final ExchangeProvider _primaryProvider;
  late final ExchangeProvider _fallbackProvider;

  ExchangeClient({
    http.Client? httpClient,
    ExchangeProvider? primaryProvider,
    ExchangeProvider? fallbackProvider,
  }) {
    final resolvedHttpClient = httpClient ?? http.Client();
    _httpClient = resolvedHttpClient;
    _primaryProvider =
        primaryProvider ?? FrankfurterProvider(httpClient: resolvedHttpClient);
    _fallbackProvider = fallbackProvider ??
        LegacyExchangeProvider(httpClient: resolvedHttpClient);
  }

  Future<ExchangeRateSnapshot> fetchRateSnapshot(String base) async {
    return fetchRateSnapshotFor(base);
  }

  Future<ExchangeRateSnapshot> fetchRateSnapshotFor(
    String base, {
    String? target,
    ExchangeApiSource preferredSource = ExchangeApiSource.auto,
  }) async {
    final normalizedBase = base.toLowerCase();
    final normalizedTarget = target?.toLowerCase();

    if (preferredSource == ExchangeApiSource.frankfurter) {
      return _fetchFromSingleProvider(
        provider: _primaryProvider,
        base: normalizedBase,
        target: normalizedTarget,
      );
    }

    if (preferredSource == ExchangeApiSource.exchangeApi) {
      return _fetchFromSingleProvider(
        provider: _fallbackProvider,
        base: normalizedBase,
        target: normalizedTarget,
      );
    }

    try {
      final snapshot = await _primaryProvider.fetchLatestRates(normalizedBase);
      if (normalizedTarget != null &&
          !snapshot.rates.containsKey(normalizedTarget)) {
        ExchangeObservability.recordAttempt(
          source: _primaryProvider.sourceId,
          status: 'missing-rate',
          base: normalizedBase,
          failureReason: 'Missing rate for $normalizedTarget',
        );
      } else {
        ExchangeObservability.recordAttempt(
          source: _primaryProvider.sourceId,
          status: 'success',
          base: normalizedBase,
        );
        return snapshot;
      }
    } catch (error) {
      ExchangeObservability.recordAttempt(
        source: _primaryProvider.sourceId,
        status: 'failed',
        base: normalizedBase,
        failureReason: error.toString(),
      );
    }

    try {
      final snapshot = await _fallbackProvider.fetchLatestRates(normalizedBase);
      if (normalizedTarget != null &&
          !snapshot.rates.containsKey(normalizedTarget)) {
        ExchangeObservability.recordAttempt(
          source: _fallbackProvider.sourceId,
          status: 'missing-rate',
          base: normalizedBase,
          failureReason: 'Missing rate for $normalizedTarget',
        );
        throw ExchangeApiException(
          'No rate found for target $normalizedTarget',
        );
      }
      ExchangeObservability.recordAttempt(
        source: _fallbackProvider.sourceId,
        status: 'success',
        base: normalizedBase,
      );
      return snapshot;
    } catch (error) {
      ExchangeObservability.recordAttempt(
        source: _fallbackProvider.sourceId,
        status: 'failed',
        base: normalizedBase,
        failureReason: error.toString(),
      );
      rethrow;
    }
  }

  Future<ExchangeRateSnapshot> _fetchFromSingleProvider({
    required ExchangeProvider provider,
    required String base,
    required String? target,
  }) async {
    try {
      final snapshot = await provider.fetchLatestRates(base);
      if (target != null && !snapshot.rates.containsKey(target)) {
        ExchangeObservability.recordAttempt(
          source: provider.sourceId,
          status: 'missing-rate',
          base: base,
          failureReason: 'Missing rate for $target',
        );
        throw ExchangeApiException('No rate found for target $target');
      }

      ExchangeObservability.recordAttempt(
        source: provider.sourceId,
        status: 'success',
        base: base,
      );
      return snapshot;
    } catch (error) {
      ExchangeObservability.recordAttempt(
        source: provider.sourceId,
        status: 'failed',
        base: base,
        failureReason: error.toString(),
      );
      rethrow;
    }
  }

  Future<Map<String, double>> fetchRatesFor(String base) async {
    final snapshot = await fetchRateSnapshot(base);
    return snapshot.rates;
  }

  Future<Map<String, String>> fetchCurrencyCatalog() async {
    final body = await _getJson(AppConfig.currencyListUrl);
    return body.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final uri = Uri.parse(url);
    final response = await _httpClient.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExchangeApiException(
        'HTTP ${response.statusCode} fetching $url',
      );
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
