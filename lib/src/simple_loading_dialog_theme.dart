import 'package:flutter/material.dart';

class SimpleLoadingDialogTheme
    extends ThemeExtension<SimpleLoadingDialogTheme> {
  SimpleLoadingDialogTheme({
    this.dialogBuilder,
  });
  final Widget Function(BuildContext context)? dialogBuilder;

  @override
  ThemeExtension<SimpleLoadingDialogTheme> copyWith({
    Widget Function(BuildContext context)? dialogBuilder,
  }) {
    return SimpleLoadingDialogTheme(
      dialogBuilder: dialogBuilder,
    );
  }

  @override
  ThemeExtension<SimpleLoadingDialogTheme> lerp(
      covariant ThemeExtension<SimpleLoadingDialogTheme>? other, double t) {
    return this;
  }
}
