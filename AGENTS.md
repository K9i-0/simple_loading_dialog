# Simple Loading Dialog

Flutter package wrapping a Future with a loading dialog. Public APIs are in `lib/`; `example/` demonstrates success, exceptions, custom dialogs, and a typed result wrapper.

## Setup and verification

Use Flutter 3.47.9 from `.fvmrc` for development. Preserve published Dart 2.19 / Flutter 3.7 compatibility. The unpublished example needs a newer SDK for its automation tools.

From the repository root:

```sh
flutter pub get
(cd example && flutter pub get)
flutter analyze --fatal-infos
dart format --output=none --set-exit-if-changed lib test example/lib example/tool example/test
flutter test
(cd example && flutter test)
```

CI also checks the library on Flutter 3.7 without resolving the newer example. Before release preparation, use `dart pub publish --dry-run` on a clean commit. Keep Marionette in the example's development dependencies.

Review dismissal, Future results/errors, mounted contexts, theme customization, and navigator behavior. Use bounded pumping while a loading spinner is active; `pumpAndSettle` cannot settle an indeterminate animation. Runtime checks must confirm both the dialog closing and the persistent result.

## Working agreements

- Inspect git status and continue the task's existing branch/PR; preserve other work.
- Choose verification for the change. Repeat passed checks only after relevant changes, failures, or unresolved concerns. Documentation-only edits need link and command checks.
- Keep public API and consumer SDK compatibility. Example developer tools may need a newer SDK.
- Publishing and merging are separate requested operations. Record actual commands, SDK/device, outcomes, and limitations in the PR.

## AI runtime verification

Follow [docs/ai-verification.md](docs/ai-verification.md) for startup, connection, stable keys, and scenarios. Use `example/tool/automation.dart` for native debug inspection; ordinary `example/lib/main.dart` has no Marionette initialization.

Observe the live element list before acting. Prefer keys/identifiers, confirm visible outcomes, check runtime errors, and capture relevant screenshots. Widget tests alone do not establish simulator E2E. Stop only apps/processes started by this task; do not stop other dev servers or simulators.

`.mcp.json` and `.codex/config.toml` configure Dart MCP and Marionette. Start the agent with the intended Flutter/Dart SDK on PATH. See the guide for optional CLI fallback when MCP is unavailable.
