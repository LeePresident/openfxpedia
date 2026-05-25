import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/widgets/rate_info.dart';

void main() {
  testWidgets('shows provider source for live rates', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RateInfoWidget(
            rate: ExchangeRate(
              baseCurrency: 'usd',
              targetCurrency: 'eur',
              rate: 0.92,
              timestamp: DateTime.utc(2026, 5, 7, 12),
              source: 'frankfurter',
            ),
            fromCache: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('frankfurter'), findsOneWidget);
  });
}
