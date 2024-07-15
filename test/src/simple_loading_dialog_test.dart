import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

void main() {
  late String actualResult;
  late bool caughtError;

  setUp(() {
    actualResult = '';
    caughtError = false;
  });

  Widget buildTestApp({
    required void Function(BuildContext) onPressed,
    SimpleLoadingDialogTheme? themeExtension,
  }) {
    return MaterialApp(
      theme: themeExtension != null
          ? ThemeData(
              extensions: [
                themeExtension,
              ],
            )
          : ThemeData(),
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => onPressed(context),
                child: const Text('Show Dialog'),
              ),
            ),
          );
        },
      ),
    );
  }

  group('Standard Cases', () {
    testWidgets(
        'Given a future that completes successfully, when showSimpleLoadingDialog is called, then the dialog is shown and hides on future completion',
        (tester) async {
      // Given a future that completes successfully
      final completer = Completer<String>();

      // Given the widget is built
      await tester.pumpWidget(
        buildTestApp(
          onPressed: (context) async {
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

      // Given the widget is built
      await tester.pumpWidget(
        buildTestApp(
          onPressed: (context) async {
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
  });

  group('Custom DialogBuilder Cases', () {
    testWidgets(
        'Given a custom dialogBuilder, when showSimpleLoadingDialog is called, then the custom dialog is shown',
        (tester) async {
      // Given a future that completes after a short delay
      final completer = Completer<String>();

      // Custom dialog builder
      Widget customDialogBuilder(BuildContext context, String message) {
        return AlertDialog(
          content: Text('Custom Dialog: $message'),
        );
      }

      // Given the widget is built
      await tester.pumpWidget(
        buildTestApp(
          onPressed: (context) async {
            try {
              // When showSimpleLoadingDialog is called
              actualResult = await showSimpleLoadingDialog<String>(
                context: context,
                future: () => completer.future,
                dialogBuilder: customDialogBuilder,
              );
            } on Exception {
              caughtError = true;
            }
          },
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

      // Custom dialog builder provided through theme extension
      Widget customDialogBuilder(BuildContext context, String message) {
        return AlertDialog(
          content: Text('Theme Custom Dialog: $message'),
        );
      }

      // Given the widget with the theme extension is built
      await tester.pumpWidget(
        buildTestApp(
          onPressed: (context) async {
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
          themeExtension: SimpleLoadingDialogTheme(
            dialogBuilder: customDialogBuilder,
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
        buildTestApp(
          onPressed: (context) async {
            try {
              // When showSimpleLoadingDialog is called
              actualResult = await showSimpleLoadingDialog<String>(
                context: context,
                future: () => completer.future,
                dialogBuilder: argumentDialogBuilder,
              );
            } on Exception {
              caughtError = true;
            }
          },
          themeExtension: SimpleLoadingDialogTheme(
            dialogBuilder: themeDialogBuilder,
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
  });

  group('Nested Navigator Cases', () {
    Widget buildTestNestedApp({
      required void Function(BuildContext) onPressed,
      SimpleLoadingDialogTheme? themeExtension,
    }) {
      return MaterialApp(
        theme: themeExtension != null
            ? ThemeData(
                extensions: [
                  themeExtension,
                ],
              )
            : ThemeData(),
        home: _MyHomePage(onPressed: onPressed),
      );
    }

    testWidgets(
        'Given a future that completes successfully with nested Navigator, when showSimpleLoadingDialog is called, then the dialog is shown and hides on future completion',
        (tester) async {
      final completer = Completer<String>();
      var actualResult = '';

      await tester.pumpWidget(
        buildTestNestedApp(
          onPressed: (context) async {
            actualResult = await showSimpleLoadingDialog<String>(
              context: context,
              future: () => completer.future,
            );
          },
        ),
      );

      // Navigate to the second tab to create a nested navigator scenario
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pump(); // Start the dialog animation

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete('Success');
      await tester.pump(); // Give time for the completer to complete
      await tester.pumpAndSettle(); // Wait for all animations to finish

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(actualResult, 'Success');
    });

    testWidgets(
        'Given a future that completes with an error with nested Navigator, when showSimpleLoadingDialog is called, then the dialog is shown and hides on future error',
        (tester) async {
      final completer = Completer<String>();
      var actualResult = '';
      var caughtError = false;

      await tester.pumpWidget(
        buildTestNestedApp(
          onPressed: (context) async {
            try {
              actualResult = await showSimpleLoadingDialog<String>(
                context: context,
                future: () => completer.future,
              );
            } on Exception {
              caughtError = true;
            }
          },
        ),
      );

      // Navigate to the second tab to create a nested navigator scenario
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pump(); // Start the dialog animation

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.completeError(Exception('Error'));
      await tester.pump(); // Give time for the completer to complete
      await tester.pumpAndSettle(); // Wait for all animations to finish

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(actualResult, '');
      expect(caughtError, isTrue);
    });
  });
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({required void Function(BuildContext) onPressed})
      : _onPressed = onPressed;
  final void Function(BuildContext) _onPressed;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const Center(child: Text('Tab 1')),
      _NestedNavigatorScreen(
        onPressed: widget._onPressed,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Tab 2',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NestedNavigatorScreen extends StatelessWidget {
  const _NestedNavigatorScreen({required void Function(BuildContext) onPressed})
      : _onPressed = onPressed;
  final void Function(BuildContext) _onPressed;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Nested Navigator')),
            body: Center(
              child: ElevatedButton(
                onPressed: () => _onPressed(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );
      },
    );
  }
}
