import 'package:example/demo_keys.dart';
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
              key: ValueKey(DemoKeys.loadingDialog),
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
  String _resultKey = DemoKeys.idleResult;

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
                  key: const ValueKey(DemoKeys.successButton),
                  onPressed: () async {
                    _showResult(
                      'Running success example...',
                      DemoKeys.pendingResult,
                    );
                    final result = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () async {
                        await Future<void>.delayed(const Duration(seconds: 2));
                        return 'Hello';
                      },
                    );
                    _showResult(
                      'Success result: $result',
                      DemoKeys.successResult,
                    );
                  },
                  child: const Text('Show loading dialog'),
                ),
                const SizedBox(height: 24),
                // Error case
                ElevatedButton(
                  key: const ValueKey(DemoKeys.errorButton),
                  onPressed: () async {
                    _showResult(
                      'Running error example...',
                      DemoKeys.pendingResult,
                    );
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
                      _showResult(
                        'Failed result: $error',
                        DemoKeys.errorResult,
                      );
                    }
                  },
                  child: const Text('Show loading dialog with error'),
                ),
                const SizedBox(height: 24),
                // A per-call builder overrides the theme's dialog builder.
                ElevatedButton(
                  key: const ValueKey(DemoKeys.customDialogButton),
                  onPressed: () async {
                    _showResult(
                      'Running custom dialog...',
                      DemoKeys.pendingResult,
                    );
                    final result = await showSimpleLoadingDialog<String>(
                      context: context,
                      future: () async {
                        await Future<void>.delayed(const Duration(seconds: 2));
                        return 'World';
                      },
                      dialogBuilder: (context, message) {
                        return AlertDialog(
                          key: const ValueKey(DemoKeys.customLoadingDialog),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                message,
                                key: const ValueKey(
                                  DemoKeys.customLoadingMessage,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                    _showResult(
                      'Custom dialog result: $result',
                      DemoKeys.customResult,
                    );
                  },
                  child: const Text('Show loading dialog with custom dialog'),
                ),
                const SizedBox(height: 24),
                // Optional: return a Result instead of throwing an exception.
                ElevatedButton(
                  key: const ValueKey(DemoKeys.resultWrapperButton),
                  onPressed: () async {
                    _showResult(
                      'Running Result wrapper...',
                      DemoKeys.pendingResult,
                    );
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
                          DemoKeys.wrappedResult,
                        );
                      case Failure():
                        _showResult(
                          'Result wrapper failure: ${result.error}',
                          DemoKeys.wrappedResult,
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
                    key: const ValueKey(DemoKeys.demoResult),
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
