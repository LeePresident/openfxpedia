import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'exchange_api_exception.dart';

class ExchangeRateSnapshot {
  const ExchangeRateSnapshot({
    required this.baseCurrency,
    required this.quotedAt,
    required this.sourceId,
    required this.rates,
  });

  final String baseCurrency;
  final DateTime quotedAt;
  final String sourceId;
  final Map<String, double> rates;
}

abstract class ExchangeProvider {
  String get sourceId;

  Future<ExchangeRateSnapshot> fetchLatestRates(String base);

  Future<ExchangeRateSnapshot> fetchRateFor(String base, String target) async {
    final normalizedTarget = target.toLowerCase();
    final snapshot = await fetchLatestRates(base);
    final rate = snapshot.rates[normalizedTarget];
    if (rate == null) {
      throw ExchangeApiException('No rate found for target $normalizedTarget');
    }

    return ExchangeRateSnapshot(
      baseCurrency: snapshot.baseCurrency,
      quotedAt: snapshot.quotedAt,
      sourceId: snapshot.sourceId,
      rates: {normalizedTarget: rate},
    );
  }
}

class LegacyExchangeProvider implements ExchangeProvider {
  LegacyExchangeProvider({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  String get sourceId => 'legacy';

  @override
  Future<ExchangeRateSnapshot> fetchLatestRates(String base) async {
    final normalizedBase = base.toLowerCase();

    Map<String, dynamic> body;
    try {
      body = await _getJson(
        '${AppConfig.exchangeApiBase}/$normalizedBase.json',
      );
    } catch (_) {
      body = await _getJson(
        '${AppConfig.exchangeApiFallbackBase}/$normalizedBase.json',
      );
    }

    final rates = body[normalizedBase] as Map<String, dynamic>?;
    if (rates == null || rates.isEmpty) {
      throw ExchangeApiException(
        'Unexpected response shape for base $normalizedBase',
      );
    }

    return ExchangeRateSnapshot(
      baseCurrency: normalizedBase,
      quotedAt: DateTime.now().toUtc(),
      sourceId: sourceId,
      rates: rates.map(
        (key, value) => MapEntry(key.toLowerCase(), (value as num).toDouble()),
      ),
    );
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateFor(String base, String target) async {
    final normalizedTarget = target.toLowerCase();
    final snapshot = await fetchLatestRates(base);
    final rate = snapshot.rates[normalizedTarget];
    if (rate == null) {
      throw ExchangeApiException('No rate found for target $normalizedTarget');
    }

    return ExchangeRateSnapshot(
      baseCurrency: snapshot.baseCurrency,
      quotedAt: snapshot.quotedAt,
      sourceId: snapshot.sourceId,
      rates: {normalizedTarget: rate},
    );
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final response = await _httpClient.get(
      Uri.parse(url),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExchangeApiException('HTTP ${response.statusCode} fetching $url');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
