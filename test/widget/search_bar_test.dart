import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/models/currency.dart';
import 'package:openfxpedia/widgets/search_bar.dart' as app_search;

final _currencies = [
  Currency(isoCode: 'USD', name: 'US Dollar'),
  Currency(isoCode: 'EUR', name: 'Euro'),
  Currency(isoCode: 'GBP', name: 'British Pound'),
  Currency(isoCode: 'JPY', name: 'Japanese Yen'),
];

Widget _buildWidget({
  Currency? selected,
  required ValueChanged<Currency> onSelected,
}) {
  return MaterialApp(
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

    testWidgets('closes dialog without selecting when close button tapped',
        (tester) async {
      Currency? selected;
      await tester.pumpWidget(_buildWidget(onSelected: (c) => selected = c));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
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
