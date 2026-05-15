import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import 'exchange_api_exception.dart';
import 'exchange_provider.dart';

class FrankfurterProvider implements ExchangeProvider {
  FrankfurterProvider({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  String get sourceId => 'frankfurter';

  @override
  Future<ExchangeRateSnapshot> fetchLatestRates(String base) async {
    final normalizedBase = base.toLowerCase();
    final response = await _httpClient.get(
      Uri.parse(
        '${AppConfig.frankfurterApiBase}/rates?base=${normalizedBase.toUpperCase()}',
      ),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExchangeApiException(
        'HTTP ${response.statusCode} fetching Frankfurter latest rates',
      );
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    if (body.isEmpty) {
      throw ExchangeApiException(
        'Unexpected Frankfurter response shape for base $normalizedBase',
      );
    }

    final rates = <String, double>{};
    DateTime? latestDate;
    for (final entry in body) {
      final row = entry as Map<String, dynamic>;
      final quote = row['quote'] as String?;
      final rate = row['rate'];
      final rawDate = row['date'] as String?;
      if (quote == null || quote.isEmpty || rate is! num || rawDate == null) {
        throw ExchangeApiException(
          'Unexpected Frankfurter response shape for base $normalizedBase',
        );
      }

      final parsedDate = DateTime.parse(rawDate);
      if (latestDate == null || parsedDate.isAfter(latestDate)) {
        latestDate = parsedDate;
      }
      rates[quote.toLowerCase()] = rate.toDouble();
    }

    if (latestDate == null || rates.isEmpty) {
      throw ExchangeApiException(
        'Unexpected Frankfurter response shape for base $normalizedBase',
      );
    }

    return ExchangeRateSnapshot(
      baseCurrency: normalizedBase,
      quotedAt: DateTime.utc(
        latestDate.year,
        latestDate.month,
        latestDate.day,
      ),
      sourceId: sourceId,
      rates: rates,
    );
  }

  @override
  Future<ExchangeRateSnapshot> fetchRateFor(String base, String target) async {
    final normalizedBase = base.toLowerCase();
    final normalizedTarget = target.toLowerCase();
    final response = await _httpClient.get(
      Uri.parse(
        '${AppConfig.frankfurterApiBase}/rate/${normalizedBase.toUpperCase()}/${normalizedTarget.toUpperCase()}',
      ),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExchangeApiException(
        'HTTP ${response.statusCode} fetching Frankfurter rate',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final quote = body['quote'] as String?;
    final rate = body['rate'];
    final rawDate = body['date'] as String?;
    if (quote == null || quote.isEmpty || rate is! num || rawDate == null) {
      throw ExchangeApiException(
        'Unexpected Frankfurter pair response shape for $normalizedBase/$normalizedTarget',
      );
    }

    final parsedDate = DateTime.parse(rawDate);
    return ExchangeRateSnapshot(
      baseCurrency: normalizedBase,
      quotedAt: DateTime.utc(parsedDate.year, parsedDate.month, parsedDate.day),
      sourceId: sourceId,
      rates: {quote.toLowerCase(): rate.toDouble()},
    );
  }
}
