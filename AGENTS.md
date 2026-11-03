# Simple Loading Dialog

Flutter package wrapping a Future with a loading dialog. Public APIs are in `lib/`; `example/` demonstrates success, exceptions, custom dialogs, and a typed result wrapper.

## Setup and verification

Use Flutter 3.47.9 from `.fvmrc` for development. Preserve published Dart 2.19 / Flutter 3.7 compatibility. The unpublished example needs a newer SDK for its automation tools.

From the repository root:

```sh
flutter pub get
(cd example && flutter pub get)
flutter analyze --fatal-infos
sh tool/check_format.sh
flutter test
(cd example && flutter test)
```

CI also checks the library on Flutter 3.7 without resolving the newer example. Before release preparation, use `dart pub publish --dry-run` on a clean commit. Keep Marionette in the example's development dependencies.

Review dismissal, Future results/errors, mounted contexts, theme customization, and navigator behavior. Use bounded pumping while a loading spinner is active; `pumpAndSettle` cannot settle an indeterminate animation. Runtime checks must confirm both the dialog closing and the persistent result.

## Working agreements

- Maintainers work and commit directly on `main`, then push without a separate PR. Preserve unrelated local work. Pull requests are for outside contributions and dependency bots.
- Use Conventional Commits. A `main` push runs checks and does not publish.
- Publish only when a release is requested, by pushing `<package>-v<version>` after all release checks pass. Follow [doc/releasing.md](doc/releasing.md); do not run a manual publish command.
- Choose verification for the change. Repeat passed checks only after relevant changes, failures, or unresolved concerns. Documentation-only edits need link and command checks.
- Keep public API and consumer SDK compatibility. Example developer tools may need a newer SDK.
- Record actual verification commands, SDK/device, outcomes, and limitations. Release tags are separate from a maintenance request.

## AI runtime verification

Follow [doc/ai-verification.md](doc/ai-verification.md) for startup, connection, stable keys, and scenarios. Use `example/tool/automation.dart` for native debug inspection; ordinary `example/lib/main.dart` has no Marionette initialization.

Observe the live element list before acting. Prefer keys/identifiers, confirm visible outcomes, check runtime errors, and capture relevant screenshots. Widget tests alone do not establish simulator E2E. Stop only apps/processes started by this task; do not stop other dev servers or simulators.

`.mcp.json` and `.codex/config.toml` configure Dart MCP and Marionette. Start the agent with the intended Flutter/Dart SDK on PATH. See the guide for optional CLI fallback when MCP is unavailable.

## Regression and release gate

The maintained regression suite is `example/patrol_test/`. Before a release,
run `PATROL_DEVICE=<ios-simulator-id> bash tool/patrol_ios.sh` and require every
Patrol case to pass. CI repeats the suite on the exact tagged commit before
publishing. Widget tests and manual Marionette checks do not replace this gate.
Patrol MCP runs the saved tests during development; keep exploratory Marionette
inspection available for debugging. See [doc/patrol.md](doc/patrol.md).
