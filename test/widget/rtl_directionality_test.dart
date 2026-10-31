import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in const [Locale('ar'), Locale('he')]) {
    testWidgets('locale $locale uses right-to-left direction', (tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          locale: locale,
          supportedLocales: [locale],
          localizationsDelegates: const [GlobalWidgetsLocalizations.delegate],
          builder: (context, child) {
            return DirectionalityProbe(
              textDirection: Directionality.of(context),
            );
          },
        ),
      );

      expect(
        tester
            .widget<DirectionalityProbe>(find.byType(DirectionalityProbe))
            .textDirection,
        TextDirection.rtl,
      );
    });
  }
}

class DirectionalityProbe extends StatelessWidget {
  const DirectionalityProbe({required this.textDirection, super.key});

  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
