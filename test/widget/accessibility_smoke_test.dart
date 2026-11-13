import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/l10n/localization_delegates.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/widgets/search_bar.dart' as app_search;

void main() {
  testWidgets('currency selector dialog exposes accessible controls', (
    tester,
  ) async {
    Currency? selected;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: app_search.CurrencySearchBar(
            currencies: [
              Currency(isoCode: 'USD', name: 'US Dollar'),
              Currency(isoCode: 'EUR', name: 'Euro'),
            ],
            onSelected: (c) => selected = c,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('currency_search_field')), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);

    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();

    expect(selected?.isoCode, 'USD');
  });
}
