import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_loading_dialog/src/simple_loading_dialog_theme.dart';

Future<T> showSimpleLoadingDialog<T>({
  required BuildContext context,
  required Future<T> Function() future,
  Widget Function(BuildContext context)? dialogBuilder,
  bool barrierDismissible = false,
}) async {
  final theme = Theme.of(context).extension<SimpleLoadingDialogTheme>();
  final builder = dialogBuilder ??
      theme?.dialogBuilder ??
      (BuildContext context) => const Center(
            child: CircularProgressIndicator(),
          );

  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );

  try {
    final result = await future();
    // TODO(K9i-0): check context.mounted
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    return result;
  } catch (e) {
    Navigator.of(context).pop();
    rethrow;
  }
}
