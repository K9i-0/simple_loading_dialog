import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

void main() {
  testWidgets(
      'showSimpleLoadingDialog shows and hides dialog on future completion',
      (tester) async {
    // Setup a future that completes after a short delay
    final completer = Completer<String>();
    var actualResult = '';
    var caughtError = false;

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      actualResult = await showSimpleLoadingDialog<String>(
                        context: context,
                        future: () => completer.future,
                      );
                    } on Exception {
                      caughtError = true;
                    }
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pump(); // Start the dialog animation

    // Verify the dialog is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future
    completer.complete('Success');
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Verify the dialog is hidden
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify the result
    expect(actualResult, 'Success');

    // Verify the error was not caught
    expect(caughtError, isFalse);
  });

  testWidgets(
      'showSimpleLoadingDialog hides dialog and rethrows exception on future error',
      (tester) async {
    // Setup a future that completes with an error
    final completer = Completer<String>();
    var actualResult = '';
    var caughtError = false;

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      actualResult = await showSimpleLoadingDialog<String>(
                        context: context,
                        future: () => completer.future,
                      );
                    } on Exception {
                      caughtError = true;
                    }
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pump(); // Start the dialog animation

    // Verify the dialog is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future with an error
    completer.completeError(Exception('Error'));
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Verify the dialog is hidden
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Verify the result is not set due to error
    expect(actualResult, '');

    // Verify the error was caught
    expect(caughtError, isTrue);
  });
}
