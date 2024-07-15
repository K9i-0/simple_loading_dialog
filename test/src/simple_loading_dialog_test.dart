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

  testWidgets(
      'Given a custom dialogBuilder, when showSimpleLoadingDialog is called, then the custom dialog is shown',
      (tester) async {
    // Given a future that completes after a short delay
    final completer = Completer<String>();
    var actualResult = '';

    // Custom dialog builder
    Widget customDialogBuilder(BuildContext context, String message) {
      return AlertDialog(
        content: Text('Custom Dialog: $message'),
      );
    }

    // Given the widget is built
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // When showSimpleLoadingDialog is called
                    actualResult = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () => completer.future,
                      dialogBuilder: customDialogBuilder,
                    );
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

    // Then the custom dialog is shown
    expect(find.text('Custom Dialog: Loading...'), findsOneWidget);

    // Complete the future
    completer.complete('Success');
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Then the dialog is hidden
    expect(find.text('Custom Dialog: Loading...'), findsNothing);

    // And the result is returned
    expect(actualResult, 'Success');
  });

  testWidgets(
      'Given a dialogBuilder in SimpleLoadingDialogTheme, when showSimpleLoadingDialog is called, then the custom dialog from theme is shown',
      (tester) async {
    // Given a future that completes after a short delay
    final completer = Completer<String>();
    var actualResult = '';

    // Custom dialog builder provided through theme extension
    Widget customDialogBuilder(BuildContext context, String message) {
      return AlertDialog(
        content: Text('Theme Custom Dialog: $message'),
      );
    }

    // Given the widget with the theme extension is built
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            SimpleLoadingDialogTheme(
              dialogBuilder: customDialogBuilder,
            ),
          ],
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // When showSimpleLoadingDialog is called
                    actualResult = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () => completer.future,
                    );
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

    // Then the custom dialog from the theme is shown
    expect(find.text('Theme Custom Dialog: Loading...'), findsOneWidget);

    // Complete the future
    completer.complete('Success');
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Then the dialog is hidden
    expect(find.text('Theme Custom Dialog: Loading...'), findsNothing);

    // And the result is returned
    expect(actualResult, 'Success');
  });

  testWidgets(
      'Given both a dialogBuilder in SimpleLoadingDialogTheme and a dialogBuilder as an argument, when showSimpleLoadingDialog is called, then the argument dialogBuilder is used',
      (tester) async {
    // Given a future that completes after a short delay
    final completer = Completer<String>();
    var actualResult = '';

    // Custom dialog builder provided through theme extension
    Widget themeDialogBuilder(BuildContext context, String message) {
      return AlertDialog(
        content: Text('Theme Custom Dialog: $message'),
      );
    }

    // Custom dialog builder provided through argument
    Widget argumentDialogBuilder(BuildContext context, String message) {
      return AlertDialog(
        content: Text('Argument Custom Dialog: $message'),
      );
    }

    // Given the widget with the theme extension is built
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            SimpleLoadingDialogTheme(
              dialogBuilder: themeDialogBuilder,
            ),
          ],
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // When showSimpleLoadingDialog is called
                    actualResult = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () => completer.future,
                      dialogBuilder: argumentDialogBuilder,
                    );
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

    // Then the custom dialog from the argument is shown
    expect(find.text('Argument Custom Dialog: Loading...'), findsOneWidget);

    // Verify the theme dialog is not shown
    expect(find.text('Theme Custom Dialog: Loading...'), findsNothing);

    // Complete the future
    completer.complete('Success');
    await tester.pumpAndSettle(); // Wait for all animations to finish

    // Then the dialog is hidden
    expect(find.text('Argument Custom Dialog: Loading...'), findsNothing);

    // And the result is returned
    expect(actualResult, 'Success');
  });
}
