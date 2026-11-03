# AI verification of the example

For repeatable regressions and the required release gate, use [Patrol](patrol.md).
This guide covers exploratory runtime inspection.

Use this guide with [AGENTS.md](../AGENTS.md). The example has two entrypoints:

- `example/lib/main.dart`: the ordinary demo, with no Marionette initialization.
- `example/tool/automation.dart`: the same demo with native **debug-only**
  inspection, log collection, and session reports. Web/profile/release runs use
  the ordinary entrypoint behavior and do not expose these automation extensions.

Marionette is an example development dependency. It does not change the
published library's Dart 2.19 / Flutter 3.7 compatibility. The unpublished example
requires Flutter 3.47 or newer; use Flutter **3.47.9** from `.fvmrc`
for the development checks below.

## Setup

Put the selected Flutter SDK's `bin` directory on PATH before starting the agent,
so `flutter`, `dart`, Dart MCP, and globally activated Dart tools use that SDK.
Also make the executable directory for Dart global packages available on PATH.
Verify with `flutter --version` and `dart --version`.

From the repository root:

```sh
flutter pub get
(cd example && flutter pub get)
dart pub global activate marionette_mcp 0.7.0
```

The checked-in `.mcp.json` configures Claude Code, and `.codex/config.toml`
configures Codex's `dart-mcp` and `marionette` servers. Dart MCP starts with
`dart mcp-server --enable flutter_app_lifecycle` to expose device discovery and
app lifecycle tools; confirm those tools are listed before choosing MCP startup.
Codex loads project MCP
configuration for trusted projects. Reload the agent after changing its PATH or
MCP configuration, then check its available server/tools list. See the
[official Codex MCP documentation](https://learn.chatgpt.com/codex/extend/mcp).
If a global executable reports an invalid SDK hash, reactivate the same package
version using the selected SDK.

## Start and connect with MCP

1. Discover devices with Dart MCP `list_devices` or `flutter devices`. Select an
   available native target supported by `example/`, such as a booted iOS
   simulator or Android emulator. Do not assume a saved device ID is valid.
2. Call Dart MCP `launch_app` with `root` set to the `example/` directory's file
   URI, for example `file:///absolute/path/to/checkout/example`,
   `target: "tool/automation.dart"`, and `device` set to the discovered ID.
   The directory must be inside a root allowed by the MCP client. Save the
   returned process ID for logs and cleanup.
3. Read `get_app_logs` for that process until startup completes. Obtain the
   `wsUri` from the `app.debugPort` event; do not reuse a URI from an older run.
4. Call Marionette `connect` with `uri` set to that exact WebSocket URI. The
   returned Dart Tooling Daemon `dtdUri` is a different endpoint; do not pass it
   to Marionette.
5. Call `get_interactive_elements` and confirm the demo title and its buttons.

Observe elements again after every meaningful action. Use a returned `key`
first, then a semantics identifier or visible text. If a target is off-screen,
scroll it into view and observe again before tapping. A successful tool call
alone is not proof that the expected UI appeared.

## Scenarios and expected outcomes

The initial result is `idle_result`, with text `Choose an example to begin.`.
Each operation runs for two seconds. While pending, the old result is replaced
by `pending_result`; inspect the dialog promptly, then wait for the visible
outcome. The outcome remains in the `demo_result` card until another operation
starts, so it does not depend on catching a transient snackbar.

| Action key | Pending dialog key | Final result key and exact text |
| --- | --- | --- |
| `success_button` | `loading_dialog` | `success_result`: `Success result: Hello` |
| `error_button` | `loading_dialog` | `error_result`: `Failed result: Exception: Error` |
| `custom_dialog_button` | `custom_loading_dialog` | `custom_result`: `Custom dialog result: World` |
| `result_wrapper_button` | `loading_dialog` | `wrapped_result`: `Result wrapper failure: Exception: Error` |

For each row, verify the dialog appears, remains while the Future is pending,
closes when it completes, and leaves the expected result. The custom dialog also
contains `custom_loading_message` with `Loading...`. Run success followed by
error to confirm an old success message does not remain during the next operation.
Expected error results are caught application outcomes; they must not become
uncaught runtime errors.

## CLI fallback

When the current agent session does not expose MCP tools, use the official
[Marionette CLI](https://marionette.leancode.co/docs/drive/) against the same
automation entrypoint:

```sh
dart pub global activate marionette_cli 0.7.0
marionette help-ai
```

Start this in a terminal and retain its process/session handle:

```sh
cd example
flutter run --machine -d '<device-id>' -t tool/automation.dart
```

Replace `<device-id>` with a discovered device. Copy the `app.debugPort` event's
`wsUri` into the variable below. In another terminal at the repository root:

```sh
EXAMPLE_VM_URI='<wsUri from app.debugPort>'
mkdir -p artifacts
marionette --uri "$EXAMPLE_VM_URI" get-interactive-elements
marionette --uri "$EXAMPLE_VM_URI" tap --key success_button
marionette --uri "$EXAMPLE_VM_URI" get-interactive-elements
```

Read CLI startup errors in the original terminal; Dart MCP `get_app_logs` only
collects processes started through its own `launch_app` tool.

Observe until the dialog closes and `Success result: Hello` is visible, then
collect evidence. Repeat with the other scenario keys:

```sh
marionette --uri "$EXAMPLE_VM_URI" get-logs
marionette --uri "$EXAMPLE_VM_URI" take-screenshots --output artifacts/dialog-success.png
```

Use `marionette <command> --help` for the installed CLI's options. For a narrow
viewport, `scroll-to --key result_wrapper_button` can reveal the last button;
always confirm the new element list before acting.

## Tests, evidence, and cleanup

The fast example checks are in
[`example/test/demo_smoke_test.dart`](../example/test/demo_smoke_test.dart):

```sh
(cd example && flutter test)
```

Use bounded `pump` calls while a loading spinner is active. An indeterminate
animation cannot satisfy `pumpAndSettle`; settle only after the Future has
completed. Widget tests verify the demo contract, while a native runtime run
verifies launch, connection, and actual on-device interaction.

Read Marionette `get_logs` and the launch logs for framework errors or uncaught
exceptions; use Dart MCP runtime-error inspection when available. Capture a
screenshot when checking layout or a final outcome. If screenshots are unavailable,
report that limit rather than treating an empty result as visual evidence.
Session reports and screenshots belong in ignored `.marionette/` and `artifacts/`
directories. Report the SDK/device, entrypoint, scenarios, outcomes, and any
unverified behavior. Keep VM-service authentication URIs out of committed files.

Finish with Marionette `disconnect` and Dart MCP `stop_app` for the saved process
ID. For a CLI launch, interrupt its original terminal/session. Stop only processes
started for this check; do not kill all Flutter processes or stop someone else's
simulator. Leave an app running only when a continued preview is requested.
