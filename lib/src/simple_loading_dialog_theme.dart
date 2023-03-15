import 'package:flutter/material.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

/// A theme extension class for customizing the appearance of a SimpleLoadingDialog.
///
/// The SimpleLoadingDialogTheme allows you to provide a custom dialogBuilder function
/// to create a custom loading dialog widget when using showSimpleLoadingDialog.
///
/// The dialog builder function is chosen based on the following priority order:
/// 1. The dialogBuilder passed directly to the showSimpleLoadingDialog function.
/// 2. The dialogBuilder provided in the SimpleLoadingDialogTheme.
/// 3. The default Center widget with a CircularProgressIndicator.
///
/// Example usage:
///
/// MaterialApp(
///   title: 'Simple Loading Dialog Demo',
///   theme: ThemeData(
///     useMaterial3: true,
///     colorSchemeSeed: Colors.blue,
///     extensions: [
///       SimpleLoadingDialogTheme(
///         dialogBuilder: (context, message) {
///           return AlertDialog(
///             content: Column(
///               mainAxisSize: MainAxisSize.min,
///               children: [
///                 const SizedBox(height: 16),
///                 const CircularProgressIndicator(),
///                 const SizedBox(height: 16),
///                 Text(message),
///                 const SizedBox(height: 16),
///               ],
///             ),
///           );
///         },
///       ),
///     ],
///   ),
///   home: const MyHomePage(),
///  );
///
/// [dialogBuilder] is an optional Widget Function(BuildContext context) that returns
/// a custom loading widget.
class SimpleLoadingDialogTheme
    extends ThemeExtension<SimpleLoadingDialogTheme> {
  SimpleLoadingDialogTheme({
    this.dialogBuilder,
  });
  final DialogBuilder? dialogBuilder;

  @override
  ThemeExtension<SimpleLoadingDialogTheme> copyWith({
    DialogBuilder? dialogBuilder,
  }) {
    return SimpleLoadingDialogTheme(
      dialogBuilder: dialogBuilder ?? this.dialogBuilder,
    );
  }

  @override
  ThemeExtension<SimpleLoadingDialogTheme> lerp(
      covariant ThemeExtension<SimpleLoadingDialogTheme>? other, double t) {
    return this;
  }
}
