# simple_loading_dialog
A simple full-screen loading dialog for Flutter.

## Features
- A very simple full-screen loading dialog.
- Can block user input while waiting for a Future to complete.
- Rethrows exceptions on error.
- Customizable dialog appearance.
- Returns the result of the Future.

## Usage
To use this package, add simple_loading_dialog as a dependency in your pubspec.yaml file.

### Showing the dialog
To show the dialog, use the showSimpleLoadingDialog function.

```dart
final result = showSimpleLoadingDialog<String>(
  context: context,
  future: myFutureFunction,
);
```
This will show a full-screen progress dialog while waiting for the myFutureFunction to complete. Once the Future completes, the result will be returned and the dialog will be dismissed.

### Customizing the appearance
The appearance of the dialog can be customized by passing a dialogBuilder.

```dart
showSimpleLoadingDialog<void>(
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
#### Using SimpleLoadingDialogTheme (recommended)
To customize the appearance of the dialog using the SimpleLoadingDialogTheme extension, define a theme in your app and pass it to the showSimpleProgressDialog function.
```dart
MaterialApp(
  title: 'My App',
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    // Set default theme like this
    extensions: [
      SimpleLoadingDialogTheme(
        dialogBuilder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 16),
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    ],
  ),
  home: MyHomePage(),
);
```

### Handling errors
If an error occurs while waiting for the Future to complete, the exception will be rethrown. To handle the error, use a try-catch block.

```dart
try {
  await showSimpleLoadingDialog<void>(
    context: context,
    future: myFutureFunction,
  );
} catch (e) {
  // Handle the error.
}
```

## License
This package is licensed under the MIT License. See the [LICENSE](https://github.com/K9i-0/simple_loading_dialog/blob/main/LICENSE) file for details.
