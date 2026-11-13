import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/l10n/localization_delegates.dart';
import 'package:openfxpedia/models/exchange_rate.dart';
import 'package:openfxpedia/widgets/rate_info.dart';

void main() {
  testWidgets('shows online status for non-cached rates', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
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

    expect(find.textContaining('Online'), findsOneWidget);
  });
}
