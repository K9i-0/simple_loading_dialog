import 'dart:async';

import 'package:example/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() {
  if (!kDebugMode || kIsWeb) {
    app.main();
    return;
  }

  final collector = PrintLogCollector();
  runZoned<void>(
    () {
      // Initialize the binding and runApp in the same zone.
      MarionetteBinding.ensureInitialized(
        MarionetteConfiguration(
          logCollector: collector,
          enableSessionReports: true,
        ),
      );
      final previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        collector.addLog(
          'Flutter error: ${details.exceptionAsString()}\n${details.stack ?? ''}',
        );
        previousErrorHandler?.call(details);
      };
      collector.addLog('Simple Loading Dialog automation initialized.');
      app.main();
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        parent.print(zone, line);
        collector.addLog(line);
      },
      handleUncaughtError: (self, parent, zone, error, stack) {
        collector.addLog('Uncaught error: $error\n$stack');
        parent.handleUncaughtError(zone, error, stack);
      },
    ),
  );
}
