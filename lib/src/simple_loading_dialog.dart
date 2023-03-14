import 'dart:async';

import 'package:flutter/material.dart';

Future<T> showSimpleLoadingDialog<T>({
  required BuildContext context,
  required Future<T> Function() future,
  Widget Function(BuildContext context)? dialogBuilder,
  bool barrierDismissible = false,
}) async {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return dialogBuilder != null
          ? dialogBuilder(context)
          : const Center(
              child: CircularProgressIndicator(),
            );
    },
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
