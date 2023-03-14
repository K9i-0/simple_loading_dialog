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

                // TODO(K9i-0): check context.mounted
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Success result: $result'),
                    duration: const Duration(milliseconds: 500),
                  ),
                );
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

                  // TODO(K9i-0): check context.mounted
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Success result: $result'),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                } catch (e) {
                  // TODO(K9i-0): check context.mounted
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed result: $e'),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
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
                  dialogBuilder: (context) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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

                // TODO(K9i-0): check context.mounted
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Success result: $result'),
                    duration: const Duration(milliseconds: 500),
                  ),
                );
              },
              child: const Text('Show loading dialog with custom dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
