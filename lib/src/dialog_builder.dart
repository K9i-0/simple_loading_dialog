import 'package:flutter/material.dart';

/// A typedef for a custom dialog builder function.
///
/// DialogBuilder is a function that returns a custom loading widget when given
/// a BuildContext and a message string. It is used with the showSimpleLoadingDialog
/// function to customize the appearance of the loading dialog.
///
/// [context] is the BuildContext of the showDialog function's builder parameter.
/// [message] is a String that represents the message to be displayed in the loading dialog.
typedef DialogBuilder = Widget Function(BuildContext context, String message);
