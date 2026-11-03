import 'package:example/demo_keys.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

void main() {
  const scenarios = [
    (
      name: 'success',
      button: DemoKeys.successButton,
      dialog: DemoKeys.loadingDialog,
      result: DemoKeys.successResult,
      text: 'Success result: Hello',
    ),
    (
      name: 'exception',
      button: DemoKeys.errorButton,
      dialog: DemoKeys.loadingDialog,
      result: DemoKeys.errorResult,
      text: 'Failed result: Exception: Error',
    ),
    (
      name: 'custom dialog',
      button: DemoKeys.customDialogButton,
      dialog: DemoKeys.customLoadingDialog,
      result: DemoKeys.customResult,
      text: 'Custom dialog result: World',
    ),
    (
      name: 'Result wrapper',
      button: DemoKeys.resultWrapperButton,
      dialog: DemoKeys.loadingDialog,
      result: DemoKeys.wrappedResult,
      text: 'Result wrapper failure: Exception: Error',
    ),
  ];

  for (final scenario in scenarios) {
    patrolTest(
      '${scenario.name}: dismisses, preserves its result, and allows another operation',
      ($) => Future<void>(() async {
        // Patrol owns the binding. Do not call the Marionette entrypoint.
        await $.pumpWidget(const MyApp());
        await $(Key(scenario.button)).tap();
        final loadingWasVisible = $(Key(scenario.dialog)).visible;
        final pendingWasVisible = $(const Key(DemoKeys.pendingResult)).exists;

        // Wait for the outcome, not for an indeterminate spinner to settle.
        final result = await $(Key(scenario.result)).waitUntilVisible();
        // The result appears before the dialog route finishes its exit animation.
        // Its Future has completed now, so a short, bounded settle is safe.
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        if (!loadingWasVisible || !pendingWasVisible) {
          throw StateError('${scenario.name} did not show its loading state');
        }
        if (result.text != scenario.text || $(Key(scenario.dialog)).exists) {
          throw StateError('${scenario.name} did not dismiss with its result');
        }

        // This checks persistence beyond the old 500 ms snackbar lifetime.
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!result.visible || result.text != scenario.text) {
          throw StateError('${scenario.name} lost its completed result');
        }

        // A second operation proves no modal barrier or route was left behind.
        await $(const Key(DemoKeys.successButton)).tap();
        final resetToPending = $(const Key(DemoKeys.pendingResult)).exists;
        final nextResult = await $(
          const Key(DemoKeys.successResult),
        ).waitUntilVisible();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        if (!resetToPending || nextResult.text != 'Success result: Hello') {
          throw StateError('The next operation did not replace the old result');
        }
        if ($(const Key(DemoKeys.loadingDialog)).exists ||
            $(const Key(DemoKeys.customLoadingDialog)).exists) {
          throw StateError('A loading dialog remained after completion');
        }
      }).timeout(const Duration(seconds: 45)),
      config: const PatrolTesterConfig(
        visibleTimeout: Duration(seconds: 10),
        existsTimeout: Duration(seconds: 10),
        settleTimeout: Duration(seconds: 3),
        settlePolicy: SettlePolicy.noSettle,
        printLogs: true,
      ),
    );
  }
}
