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
        // Set the default dialog builder with a theme extension.
        extensions: [
          SimpleLoadingDialogTheme(
            dialogBuilder: (context, message) => const Center(
              key: ValueKey('loading_dialog'),
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            ),
          ),
        ],
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  String _resultMessage = 'Choose an example to begin.';
  String _resultKey = 'idle_result';

  void _showResult(String message, String resultKey) {
    if (!mounted) {
      return;
    }
    setState(() {
      _resultMessage = message;
      _resultKey = resultKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Loading Dialog Demo')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success case
                ElevatedButton(
                  key: const ValueKey('success_button'),
                  onPressed: () async {
                    _showResult('Running success example...', 'pending_result');
                    final result = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () async {
                        await Future<void>.delayed(const Duration(seconds: 2));
                        return 'Hello';
                      },
                    );
                    _showResult('Success result: $result', 'success_result');
                  },
                  child: const Text('Show loading dialog'),
                ),
                const SizedBox(height: 24),
                // Error case
                ElevatedButton(
                  key: const ValueKey('error_button'),
                  onPressed: () async {
                    _showResult('Running error example...', 'pending_result');
                    try {
                      await showSimpleLoadingDialog<String>(
                        context: context,
                        future: () async {
                          await Future<void>.delayed(
                            const Duration(seconds: 2),
                          );
                          throw Exception('Error');
                        },
                      );
                    } catch (error) {
                      _showResult('Failed result: $error', 'error_result');
                    }
                  },
                  child: const Text('Show loading dialog with error'),
                ),
                const SizedBox(height: 24),
                // A per-call builder overrides the theme's dialog builder.
                ElevatedButton(
                  key: const ValueKey('custom_dialog_button'),
                  onPressed: () async {
                    _showResult('Running custom dialog...', 'pending_result');
                    final result = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () async {
                        await Future<void>.delayed(const Duration(seconds: 2));
                        return 'World';
                      },
                      dialogBuilder: (context, message) {
                        return AlertDialog(
                          key: const ValueKey('custom_loading_dialog'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                message,
                                key: const ValueKey('custom_loading_message'),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                    _showResult(
                      'Custom dialog result: $result',
                      'custom_result',
                    );
                  },
                  child: const Text('Show loading dialog with custom dialog'),
                ),
                const SizedBox(height: 24),
                // Optional: return a Result instead of throwing an exception.
                ElevatedButton(
                  key: const ValueKey('result_wrapper_button'),
                  onPressed: () async {
                    _showResult('Running Result wrapper...', 'pending_result');
                    final result =
                        await showSimpleLoadingDialogWithResult<String>(
                          context: context,
                          future: () async {
                            await Future<void>.delayed(
                              const Duration(seconds: 2),
                            );
                            throw Exception('Error');
                          },
                        );
                    switch (result) {
                      case Success():
                        _showResult(
                          'Result wrapper success: ${result.value}',
                          'wrapped_result',
                        );
                      case Failure():
                        _showResult(
                          'Result wrapper failure: ${result.error}',
                          'wrapped_result',
                        );
                    }
                  },
                  child: const Text(
                    'Optional: Show loading dialog with result',
                  ),
                ),
                const SizedBox(height: 32),
                // Keep the last outcome visible until the next example runs.
                Semantics(
                  liveRegion: true,
                  child: Card(
                    key: const ValueKey('demo_result'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _resultMessage,
                        key: ValueKey(_resultKey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Optional: You can define a wrapper function to show a loading dialog with a result.
///
/// Alternative to [showSimpleLoadingDialog] that returns a [Result] object
Future<Result<T>> showSimpleLoadingDialogWithResult<T>({
  required BuildContext context,
  required Future<T> Function() future,
  DialogBuilder? dialogBuilder,
  String message = 'Loading...',
  bool barrierDismissible = false,
}) async {
  try {
    final res = await showSimpleLoadingDialog(
      context: context,
      future: future,
      dialogBuilder: dialogBuilder,
      message: message,
      barrierDismissible: barrierDismissible,
    );

    return Success(value: res);
    // ignore: avoid_catches_without_on_clauses
  } catch (err, stack) {
    return Failure(error: err, stackTrace: stack);
  }
}

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success({required this.value});

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;
}
