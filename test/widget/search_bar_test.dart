import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/l10n/app_localizations.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/widgets/search_bar.dart' as app_search;

final _currencies = [
  Currency(isoCode: 'USD', isoNumeric: '840', name: 'US Dollar'),
  Currency(isoCode: 'EUR', isoNumeric: '978', name: 'Euro'),
  Currency(isoCode: 'GBP', isoNumeric: '826', name: 'British Pound'),
  Currency(isoCode: 'JPY', isoNumeric: '392', name: 'Japanese Yen'),
];

Widget _buildWidget({
  Currency? selected,
  required ValueChanged<Currency> onSelected,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: app_search.CurrencySearchBar(
        currencies: _currencies,
        onSelected: onSelected,
        selectedCurrency: selected,
      ),
    ),
  );
}

void main() {
  group('CurrencySearchBar', () {
    testWidgets('shows compact selector with no dialog initially',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onSelected: (_) {}));

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Pick'), findsOneWidget);
    });

    testWidgets('opens selector dialog with search field on tap',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onSelected: (_) {}));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byKey(const Key('currency_search_field')), findsOneWidget);
      for (final c in _currencies) {
        expect(find.text(c.isoCode), findsOneWidget);
      }
    });

    testWidgets('filters list as the user types a query', (tester) async {
      await tester.pumpWidget(_buildWidget(onSelected: (_) {}));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('currency_search_field')), 'eu');
      await tester.pump();

      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
      expect(find.text('GBP'), findsNothing);
      expect(find.text('JPY'), findsNothing);
    });

    testWidgets('filters list by ISO numeric code', (tester) async {
      await tester.pumpWidget(_buildWidget(onSelected: (_) {}));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('currency_search_field')), '392');
      await tester.pump();

      expect(find.text('JPY'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
      expect(find.text('EUR'), findsNothing);
      expect(find.text('GBP'), findsNothing);
    });

    testWidgets('clears the search query and restores all currencies',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onSelected: (_) {}));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('currency_search_field')), '392');
      await tester.pump();

      expect(find.byKey(const Key('currency_search_clear')), findsOneWidget);
      expect(find.text('JPY'), findsOneWidget);
      expect(find.text('USD'), findsNothing);

      await tester.tap(find.byKey(const Key('currency_search_clear')));
      await tester.pump();

      expect(find.byKey(const Key('currency_search_clear')), findsNothing);
      for (final c in _currencies) {
        expect(find.text(c.isoCode), findsOneWidget);
      }
    });

    testWidgets('calls onSelected and closes dialog when item is tapped',
        (tester) async {
      Currency? selected;
      await tester.pumpWidget(_buildWidget(onSelected: (c) => selected = c));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('currency_search_field')), 'eu');
      await tester.pump();

      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(selected?.isoCode, 'EUR');
    });

    testWidgets('closes dialog without selecting when barrier tapped',
        (tester) async {
      Currency? selected;
      await tester.pumpWidget(_buildWidget(onSelected: (c) => selected = c));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(selected, isNull);
    });

    testWidgets('compact selector shows selected currency label',
        (tester) async {
      final eur = Currency(isoCode: 'EUR', name: 'Euro');
      await tester.pumpWidget(_buildWidget(selected: eur, onSelected: (_) {}));

      expect(find.text('EUR — Euro'), findsOneWidget);
      expect(find.text('Pick'), findsNothing);
    });
  });
}
