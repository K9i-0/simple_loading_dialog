import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_loading_dialog/src/dialog_builder.dart';
import 'package:simple_loading_dialog/src/simple_loading_dialog_theme.dart';

/// Displays a simple loading dialog while waiting for a given Future to complete.
///
/// The loading dialog is shown using the provided context and can be customized with
/// the optional dialogBuilder function. The dialog can be dismissed by the user if
/// barrierDismissible is set to true (defaults to false).
///
/// [context] is the BuildContext of the current widget tree.
/// [future] is a Future<T> Function() that represents the task to be completed.
/// [dialogBuilder] is an optional Widget Function(BuildContext context, String message) that returns
/// [message] is an optional String that will be passed to the dialogBuilder.
/// [barrierDismissible] is a bool that determines whether the dialog can be
/// dismissed by the user or not.
///
/// Returns a Future<T> containing the result of the provided future function.
Future<T> showSimpleLoadingDialog<T>({
  required BuildContext context,
  required Future<T> Function() future,
  DialogBuilder? dialogBuilder,
  String message = 'Loading...',
  bool barrierDismissible = false,
}) async {
  final theme = Theme.of(context).extension<SimpleLoadingDialogTheme>();
  final builder = dialogBuilder ??
      theme?.dialogBuilder ??
      (dialogContext, message) => const Center(
            child: CircularProgressIndicator(),
          );

  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => builder(dialogContext, message),
  );

  try {
    final result = await future();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    return result;
  } catch (e) {
    Navigator.of(context).pop();
    rethrow;
  }
}
