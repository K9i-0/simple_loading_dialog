import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scenarios = [
    (
      name: 'success',
      button: 'success_button',
      dialog: 'loading_dialog',
      resultKey: 'success_result',
      result: 'Success result: Hello',
    ),
    (
      name: 'exception',
      button: 'error_button',
      dialog: 'loading_dialog',
      resultKey: 'error_result',
      result: 'Failed result: Exception: Error',
    ),
    (
      name: 'custom dialog',
      button: 'custom_dialog_button',
      dialog: 'custom_loading_dialog',
      resultKey: 'custom_result',
      result: 'Custom dialog result: World',
    ),
    (
      name: 'Result wrapper',
      button: 'result_wrapper_button',
      dialog: 'loading_dialog',
      resultKey: 'wrapped_result',
      result: 'Result wrapper failure: Exception: Error',
    ),
  ];

  for (final scenario in scenarios) {
    testWidgets('${scenario.name} shows its dialog and a persistent outcome', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byKey(const ValueKey('idle_result')), findsOneWidget);

      await tester.tap(find.byKey(ValueKey(scenario.button)));
      await tester.pump();
      expect(find.byKey(ValueKey(scenario.dialog)), findsOneWidget);
      expect(find.byKey(const ValueKey('pending_result')), findsOneWidget);
      expect(find.byKey(ValueKey(scenario.resultKey)), findsNothing);

      // The dialog remains visible while the asynchronous operation is pending.
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(ValueKey(scenario.dialog)), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey(scenario.dialog)), findsNothing);
      expect(find.byKey(const ValueKey('pending_result')), findsNothing);
      expect(find.byKey(ValueKey(scenario.resultKey)), findsOneWidget);
      expect(find.text(scenario.result), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Outcomes must remain observable even after an automation round trip.
      await tester.pump(const Duration(seconds: 10));
      expect(find.text(scenario.result), findsOneWidget);
    });
  }

  testWidgets('a new operation clears the previous outcome', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byKey(const ValueKey('success_button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Success result: Hello'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('error_button')));
    await tester.pump();
    expect(find.text('Success result: Hello'), findsNothing);
    expect(find.byKey(const ValueKey('pending_result')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Failed result: Exception: Error'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
