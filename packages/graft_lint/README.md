# graft_lint 🌱

[![pub package](https://img.shields.io/pub/v/graft_lint.svg?color=blue)](https://pub.dev/packages/graft_lint)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)
[![custom_lint](https://img.shields.io/badge/custom__lint-compatible-blueviolet.svg)](https://pub.dev/packages/custom_lint)

The official analyzer plugin and lint rules for **[Graft](https://pub.dev/packages/graft)**, the self-optimizing state management engine for Flutter.

`graft_lint` continuously analyzes your AST in real time to catch architectural anti-patterns, guarantee leak-free route lifecycles, and enforce 0-GC CPU bitmask diffing contracts with IDE red squiggles.

---

## 📋 Rules Included

| Rule | Default Severity | Recommended Level | Description |
|---|:---:|:---:|---|
| [`avoid_nested_graft_slot`](#1-avoid_nested_graft_slot) | **Error** | 🔴 `error` | Flags illegal nesting of slots (`slot`, `slots`, `async`, `builder`) within the same `Graft` instance. |
| [`prefer_props_in_graft_state`](#2-prefer_props_in_graft_state) | **Info** | 🔴 `error` | Enforces overriding `GraftProps get props => propsOf(...)` in `GraftState` and `GraftModel` for CPU register diffing. |
| [`require_graft_route_observer`](#3-require_graft_route_observer) | **Info** | 🔴 `error` | Ensures `GraftRouteTracker.observer` is registered in `MaterialApp` to prevent controller memory leaks. |
| [`require_dry_contracts`](#4-require_dry_contracts) | **Error** | 🔴 `error` | Enforces mandatory `schemaVersion`, constructor hydration defaults, and `factory` tear-offs for Frame-0 persistent states (`Graft.dry`). |

---

## 🚀 Quick Setup

### 1. Add Dependencies

Add `custom_lint` and `graft_lint` as dev dependencies:

```bash
flutter pub add dev:custom_lint dev:graft_lint
```

Or manually in your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  graft_lint: ^1.0.0-alpha.4
```

### 2. Configure `analysis_options.yaml`

Activate the plugin in your root `analysis_options.yaml`. To show 🔴 **red error squiggles** in your IDE whenever rules are violated, promote their severity under `analyzer.errors`:

```yaml
analyzer:
  plugins:
    - custom_lint
  errors:
    avoid_nested_graft_slot: error       # 🔴 Flags illegal nested slots (default: error)
    prefer_props_in_graft_state: error   # 🔴 Promoted to error: flags missing propsOf(...)
    require_graft_route_observer: error  # 🔴 Promoted to error: flags missing route observer
    require_dry_schema_version: error    # 🔴 Mandatory: flags missing schemaVersion in dry states
```

> [!TIP]
> ### 🔄 Why don't squiggles appear immediately in my IDE?
> The Dart Analysis Server caches plugin processes. After saving `analysis_options.yaml`:
> - **VS Code**: Press `Cmd + Shift + P` (or `Ctrl + Shift + P`) and select **Dart: Restart Analysis Server**.
> - **Android Studio**: Open the bottom **Dart Analysis** tab and click the 🔄 **Restart Dart Analysis Server** icon.

---

## ⚙️ Advanced Configuration

### Selectively Toggling Rules
All rules are enabled by default. To disable or re-enable individual rules, configure the root `custom_lint` section in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - avoid_nested_graft_slot: true
    - prefer_props_in_graft_state: true
    - require_graft_route_observer: false # Disable if not using route-scoped auto-disposal
```

---

## 🔍 Rule Details & Examples

### 1. `avoid_nested_graft_slot`
* **Default Severity:** `Error` (🔴 Red squiggly line)
* **Rationale:** Graft slots (`graft.slot`, `graft(...)`, `graft.slots`, `graft.async`, `graft.builder`) are already isolated micro-diffing engines. Nesting a slot inside another slot of the same controller creates redundant reconciliation loops and subverts fine-grained rebuild insulation.

#### ❌ Bad
```dart
// ❌ Nesting a slot inside another slot of the same Graft instance
graft.slot(
  builder: (s) => Column(
    children: [
      Text('Title: ${s.title}'),
      graft((s) => Text('Name: ${s.name}')), // 🔴 avoid_nested_graft_slot error!
    ],
  ),
);
```

#### ✅ Good
```dart
// Option A: Use graft.slots for multi-child layouts
graft.slots(
  layout: Column(crossAxisAlignment: CrossAxisAlignment.start, children: slots),
  slots: (s) => [
    Text('Title: ${s.title}'),
    Text('Name: ${s.name}'),
  ],
);

// Option B: Use graft.compute for derived state
graft.compute<String>(
  compute: (s) => '${s.title}: ${s.name}',
  builder: (combined) => Text(combined),
);
```

---

### 2. `prefer_props_in_graft_state`
* **Default Severity:** `Info` (Promotable to `Error` via `analysis_options.yaml`)
* **Rationale:** Subclasses of `GraftState` that declare domain fields must override `GraftProps get props => propsOf(...)`. This contract allows Graft to compute dirty bitmasks directly in 64-bit CPU registers with 0 GC heap allocations during state mutations.

#### ❌ Bad
```dart
class UserState extends GraftState {
  String name = '';
  int score = 0;
  // 🔴 prefer_props_in_graft_state: missing props getter!
}
```

#### ✅ Good
```dart
class UserState extends GraftState {
  String name = '';
  int score = 0;

  @override
  GraftProps get props => propsOf(name, score); // ⚡ 64-bit CPU register diffing!
}
```

---

### 3. `require_graft_route_observer`
* **Default Severity:** `Info` (Promotable to `Error` via `analysis_options.yaml`)
* **Rationale:** Graft's zero-setup route injection (`context.use<T>()`) relies on route navigation hooks to track screen lifecycles. Registering the route observer ensures route-scoped controllers cleanly self-dispose when their owning screen pops from the Navigator stack.

#### ❌ Bad
```dart
MaterialApp(
  home: const HomeScreen(), // 🔴 require_graft_route_observer warning
);
```

#### ✅ Good
```dart
MaterialApp(
  navigatorObservers: [GraftRouteTracker.observer], // or GraftRouteObserver()
  home: const HomeScreen(),
);
```

---

### 4. `require_dry_contracts`
* **Default Severity:** `Error` (🔴 Red squiggly line)
* **Rationale:** Frame-0 dry state persistence requires deterministic schema fingerprinting across VM reboots, and relies on clean constructor hydration (`super.dry(State.new)`). Omitting `schemaVersion`, failing to provide zero-argument constructor defaults, or missing nested `GraftModel` factory tear-offs (`factory => Model.new`) leads to runtime state initialization crashes.

#### ❌ Bad
```dart
// ❌ Missing schemaVersion and required positional parameters without defaults
class SignUpState extends GraftState {
  String username;
  SignUpState(this.username); // 🔴 require_dry_default_constructor error!
  // 🔴 require_dry_schema_version error!
}
```

#### ✅ Good
```dart
class SignUpState extends GraftState {
  @override
  int get schemaVersion => 1;

  String username;
  SignUpState([this.username = '']);

  @override
  String get dryKey => 'signup_draft';

  @override
  GraftProps get props => propsOf(username);
}
```

---

## 🧪 Terminal & CI/CD Verification

Run `custom_lint` to verify all rules from your terminal or continuous integration pipeline:

```bash
dart run custom_lint
```

To fail CI pipelines with a non-zero exit code if any warning or error is detected:

```bash
dart run custom_lint --fatal-warnings
```

---

## 📄 License

MIT License. Copyright (c) 2026 KM Muzahid. Free to use in commercial and open-source applications.
