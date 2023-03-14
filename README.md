# simple_progress_dialog
A simple full-screen progress dialog for Flutter.

## Features
- A very simple full-screen progress dialog.
- Can block user input while waiting for a Future to complete.
- Rethrows exceptions on error.
- Customizable dialog appearance.
- Returns the result of the Future.

## Usage
To use this package, add simple_progress_dialog as a dependency in your pubspec.yaml file.

### Showing the dialog
To show the dialog, use the showSimpleProgressDialog function.

```dart
final result = showSimpleProgressDialog<String>(
  context: context,
  future: myFutureFunction,
);
```
This will show a full-screen progress dialog while waiting for the myFutureFunction to complete.

### Customizing the appearance
The appearance of the dialog can be customized by passing a dialogBuilder.

```dart
showSimpleProgressDialog<void>(
  context: context,
  future: myFutureFunction,
  dialogBuilder: (context) => AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Custom message'),
      ],
    ),
  ),
);
```

### Handling errors
If an error occurs while waiting for the Future to complete, the exception will be rethrown. To handle the error, use a try-catch block.

```dart
try {
  await showSimpleProgressDialog<void>(
    context: context,
    future: myFutureFunction,
  );
} catch (e) {
  // Handle the error.
}
```

## License
This package is licensed under the MIT License. See the [LICENSE](https://github.com/K9i-0/simple_progress_dialog/blob/main/LICENSE) file for details.
