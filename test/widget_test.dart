import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfxpedia/widgets/theme_mode_button.dart';

void main() {
  testWidgets('theme mode button shows light, dark, and system options', (
    tester,
  ) async {
    ThemeMode? selectedMode;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              ThemeModeButton(
                themeMode: ThemeMode.system,
                onSelected: (mode) => selectedMode = mode,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Change theme'), findsOneWidget);

    await tester.tap(find.byTooltip('Change theme'));
    await tester.pumpAndSettle();

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(selectedMode, ThemeMode.dark);
  });
}
