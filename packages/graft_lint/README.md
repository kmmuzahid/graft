# graft_lint 🌱

[![pub package](https://img.shields.io/pub/v/graft_lint.svg?color=blue)](https://pub.dev/packages/graft_lint)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)

Official analyzer plugin and custom lint rules for the [Graft](https://pub.dev/packages/graft) fine-grained reactive state management library.

---

## 📋 Rules Included

| Rule | Severity | Description |
|---|---|---|
| [`avoid_nested_graft_slot`](#1-avoid_nested_graft_slot) | **Error** | Flags illegal nesting of `graft.slot()`, `slots()`, or `boundary()` inside another slot of the same Graft instance. |
| [`prefer_tracked_in_graft_state`](#2-prefer_tracked_in_graft_state) | **Info** | Recommends overriding `List<Object?> get tracked => [...]` in `GraftState` subclasses for 1-cycle hardware bitmask diffing. |
| [`require_graft_route_observer`](#3-require_graft_route_observer) | **Info** | Recommends registering `GraftRouteTracker.observer` in `MaterialApp.navigatorObservers` for automatic route scoping. |

---

## 🚀 Quick Setup

### 1. Add Dependencies
Run in your terminal:
```bash
flutter pub add dev:custom_lint dev:graft_lint
```

Or manually add them to your `pubspec.yaml`:
```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  graft_lint: ^0.1.1-alpha.1
```

### 2. Enable in `analysis_options.yaml`
Add `custom_lint` to your analyzer plugins list:

```yaml
analyzer:
  plugins:
    - custom_lint
```

> **Note:** Once enabled, all `graft_lint` rules are active by default. You do not need to list them under `linter: rules:` (doing so will trigger an unrecognized rule warning from Dart).

---

## ⚙️ Configuring Rules

You can adjust rule severities or toggle specific rules directly in `analysis_options.yaml`:

### Adjusting Severity (Error / Warning / Info / Ignore)
Use `analyzer.errors` to set your desired diagnostic level:

```yaml
analyzer:
  plugins:
    - custom_lint
  errors:
    avoid_nested_graft_slot: error       # error | warning | info | ignore
    require_graft_route_observer: info   # info | warning | error | ignore
```

### Selectively Toggling Rules
To explicitly disable or enable specific rules, use the root-level `custom_lint` section:

```yaml
custom_lint:
  rules:
    - avoid_nested_graft_slot: true
    - require_graft_route_observer: false # Disable if your app doesn't use route-scoped auto-disposal
```

---

## 🔍 Rule Details & Examples

### 1. `avoid_nested_graft_slot`
* **Severity:** `Error`
* **Why:** Graft slots are already isolated micro-diffing engines. Nesting a slot inside another slot of the same Graft instance creates redundant diffing passes and subverts fine-grained widget reconciliation.

#### ❌ Bad
```dart
graft.slot((context, state) {
  return Column(
    children: [
      // ❌ Nested slot of the same graft instance
      graft.slot((context, state) => Text(state.name)),
    ],
  );
});
```

#### ✅ Good
```dart
graft.slots(
  layout: (context, slots) => Column(children: slots),
  children: [
    (state) => Text(state.title),
    (state) => Text(state.name),
  ],
);
```

---

### 2. `prefer_tracked_in_graft_state`
* **Severity:** `Info`
* **Why:** Subclasses of `GraftState` that declare domain fields should override `List<Object?> get tracked => [...]`. This enables Graft's hardware-aligned 64-bit integer dirty bitmask, evaluated in CPU registers with 0 GC heap allocations during diff passes.

#### ❌ Bad
```dart
class UserState extends GraftState {
  String name = '';
  int score = 0;
  // Missing tracked getter: falls back to dynamic structural diffing
}
```

#### ✅ Good
```dart
class UserState extends GraftState {
  String name = '';
  int score = 0;

  @override
  List<Object?> get tracked => [name, score]; // ⚡ 1-cycle bitmask enabled!
}
```

---

### 3. `require_graft_route_observer`
* **Severity:** `Info`
* **Why:** Graft uses route tracking to automatically clean up and dispose route-scoped Grafts when screens pop from the navigation stack.

#### ❌ Bad
```dart
MaterialApp(
  home: const HomeScreen(),
);
```

#### ✅ Good
```dart
MaterialApp(
  navigatorObservers: [GraftRouteTracker.observer],
  home: const HomeScreen(),
);
```

---

## 🧪 Running in CI / Terminal

To verify lint rules from your CLI or in CI/CD pipelines without launching the IDE:

```bash
dart run custom_lint
```

To fail CI when any warning or error is found:
```bash
dart run custom_lint --fatal-warnings
```
