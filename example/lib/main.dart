import 'package:flutter/material.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Loading Dialog Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        // Set default theme like this
        //   extensions: [
        //     SimpleLoadingDialogTheme(
        //       dialogBuilder: (context, message) {
        //         return AlertDialog(
        //           content: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               const SizedBox(height: 16),
        //               const CircularProgressIndicator(),
        //               const SizedBox(height: 16),
        //               Text(message),
        //               const SizedBox(height: 16),
        //             ],
        //           ),
        //         );
        //       },
        //     ),
        //   ],
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Loading Dialog Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success case
            ElevatedButton(
              onPressed: () async {
                final result = await showSimpleLoadingDialog<String>(
                  context: context,
                  future: () async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    return 'Hello';
                  },
                );

                if (context.mounted) {
                  context.showMessageSnackBar('Success result: $result');
                }
              },
              child: const Text('Show loading dialog'),
            ),
            const SizedBox(
              height: 32,
            ),
            // Error case
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await showSimpleLoadingDialog<String>(
                    context: context,
                    future: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      throw Exception('Error');
                    },
                  );

                  if (context.mounted) {
                    context.showMessageSnackBar('Success result: $result');
                  }
                } catch (e) {
                  context.showMessageSnackBar('Failed result: $e');
                }
              },
              child: const Text('Show loading dialog with error'),
            ),
            const SizedBox(
              height: 32,
            ),
            // Custom dialog
            ElevatedButton(
              onPressed: () async {
                final result = await showSimpleLoadingDialog<String>(
                  context: context,
                  future: () async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    return 'World';
                  },
                  // Custom dialog
                  dialogBuilder: (context, _) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 16),
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading...'),
                          SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );

                if (context.mounted) {
                  context.showMessageSnackBar('Success result: $result');
                }
              },
              child: const Text('Show loading dialog with custom dialog'),
            ),
          ],
        ),
      ),
    );
  }
}

// This function is used to display a snackbar at the bottom of the current screen.
// It is called by the following code: context.showMessageSnackBar("Hello World");
extension BuildContextX on BuildContext {
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}
