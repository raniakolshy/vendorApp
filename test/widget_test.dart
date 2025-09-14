import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolshy_vendor/main.dart';
import 'package:kolshy_vendor/state_management/locale_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await tester.pumpWidget(MyApp(
      localeProvider: localeProvider,
    ));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
