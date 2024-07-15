import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

void main() {
  testWidgets(
      'Given a future that completes successfully, when showSimpleLoadingDialog is called, then the dialog is shown and hides on future completion',
      (tester) async {
    // Given a future that completes successfully
    final completer = Completer<String>();
    var actualResult = '';
    var caughtError = false;

    // Given the widget is built
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // When showSimpleLoadingDialog is called
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

    // When the button is tapped
    await tester.tap(find.text('Show Dialog'));
    await tester.pump(); // Start the dialog animation

    // Then the dialog is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // When the future completes
    completer.complete('Success');
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Then the dialog is hidden
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // And the result is returned
    expect(actualResult, 'Success');

    // And no error is caught
    expect(caughtError, isFalse);
  });

  testWidgets(
      'Given a future that completes with an error, when showSimpleLoadingDialog is called, then the dialog is shown and hides on future error',
      (tester) async {
    // Given a future that completes with an error
    final completer = Completer<String>();
    var actualResult = '';
    var caughtError = false;

    // Given the widget is built
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // When showSimpleLoadingDialog is called
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

    // When the button is tapped
    await tester.tap(find.text('Show Dialog'));
    await tester.pump(); // Start the dialog animation

    // Then the dialog is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // When the future completes with an error
    completer.completeError(Exception('Error'));
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Then the dialog is hidden
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // And the result is not set
    expect(actualResult, '');

    // And the error is caught
    expect(caughtError, isTrue);
  });
}
