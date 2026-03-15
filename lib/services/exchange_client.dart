import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class ExchangeApiException implements Exception {
  final String message;
  ExchangeApiException(this.message);

  @override
  String toString() => 'ExchangeApiException: $message';
}

class ExchangeClient {
  final http.Client _httpClient;

  ExchangeClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<Map<String, double>> fetchRatesFor(String base) async {
    final primaryUrl =
        '${AppConfig.exchangeApiBase}/${base.toLowerCase()}.json';
    final fallbackUrl =
        '${AppConfig.exchangeApiFallbackBase}/${base.toLowerCase()}.json';

    Map<String, dynamic> body;
    try {
      body = await _getJson(primaryUrl);
    } catch (_) {
      body = await _getJson(fallbackUrl);
    }

    final rates = body[base.toLowerCase()] as Map<String, dynamic>?;
    if (rates == null) {
      throw ExchangeApiException('Unexpected response shape for base $base');
    }
    return rates.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
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
