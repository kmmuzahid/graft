# Graft

A self-optimizing state management and dependency injection library for Flutter that combines structured domain models with fine-grained UI rebuilds — with zero code generation.

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![graft_lint](https://img.shields.io/pub/v/graft_lint.svg?include_prereleases&label=graft_lint&color=blue)](https://pub.dev/packages/graft_lint)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![tests](https://img.shields.io/badge/tests-315%20passed-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

---

## Why Graft?

In Flutter development, teams usually have to choose between two fundamentally different state management styles:

1. **Cohesive Domain Models (BLoC, Cubit):** State is kept in structured, self-contained objects. This makes domain logic clean, readable, and easy to test. However, updating state typically requires immutable `copyWith` methods, code generation (`freezed`), and rebuilds entire widget subtrees unless you manually write granular `buildWhen` or `select` conditions across your widgets.
2. **Atomic Reactivity (Signals, ValueNotifier):** State is split into individual reactive primitives. This allows surgical widget rebuilds without re-rendering parent layouts. However, domain logic often fragments into dozens of separate reactive variables, making multi-field transactional updates, persistence, and clean domain modeling difficult.

**Graft combines the best of both approaches.**

You write clean, structured domain models using plain mutable fields. When you update fields using standard Dart cascade operations (`state..name = 'Alice'..update()`), Graft automatically computes which specific fields changed and notifies only the widgets subscribed to those exact properties.

Parent layouts, sibling widgets, and unaccessed fields never rebuild—without code generation, and without boilerplate.

---

## Key Benefits

- **Clean Domain Models with Zero Boilerplate:** Write standard Dart classes. No `copyWith` methods, no `@freezed`, and no `build_runner` code generation required.
- **Targeted UI Rebuilds:** Widgets rebuild only when the specific properties they access change. Sibling widgets and parent layouts remain untouched.
- **Wrapper-Free Navigation Lifecycle:** Share and borrow controllers across screens, tabs, and dialogs using `context.use<T>()`. Controllers auto-dispose when their owner screen pops, with zero `MultiProvider` or `BlocProvider` wrappers in your widget tree.
- **Flicker-Free Frame-0 Persistence:** Hydrate state synchronously from in-memory cache upon app launch with `Graft.dry`, eliminating blank forms and loading spinners before the first frame renders.
- **100% Lazy Universal Dependency Injection:** A unified `bind<T>()` and `use<T>()` container with type-safe enum scoping and topological reverse-order disposal.
- **Idiomatic Dart Async:** No specialized async state wrappers or complex state machines. Use standard Dart `async/await` and update your state naturally.

---

## Quick Start

### 1. Add Dependencies & Linter

Add `graft` to your app, along with the official analyzer linter `graft_lint`:

```bash
flutter pub add graft
flutter pub add dev:custom_lint dev:graft_lint
```

Enable `custom_lint` in your `analysis_options.yaml` to receive real-time IDE diagnostics and error squiggles:

```yaml
analyzer:
  plugins:
    - custom_lint
```

### 2. Define State & Controller

Create your state by extending `GraftState` and declaring its properties in `props` using `propsOf(...)`:

```dart
import 'package:graft/graft.dart';

class UserState extends GraftState {
  String name = 'Alice';
  int points = 0;

  @override
  GraftProps get props => propsOf(name, points);
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Evaluates diff and notifies subscribed slots
  }

  void addPoint() {
    state
      ..points += 1
      ..update();
  }
}
```

### 3. Connect to the UI

Use `context.use` to resolve the controller, and `user.slot(...)` to isolate widgets so only the affected fields rebuild:

```dart
import 'package:flutter/material.dart';
import 'package:graft/graft.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolves or borrows the controller across this navigation flow
    final user = context.use(UserGraft.new);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Rebuilds ONLY when state.name changes:
            user.slot((s) => Text('Name: ${s.name}', style: const TextStyle(fontSize: 18))),

            // Rebuilds ONLY when state.points changes:
            user.slot((s) => Text('Points: ${s.points}', style: const TextStyle(fontSize: 18))),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: user.addPoint,
              child: const Text('Add Point'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Core Concepts

### 1. State Definition (`GraftState` & `propsOf`)

A `GraftState` contains your domain fields and an overridden `props` getter:

```dart
class CartState extends GraftState {
  final List<String> items = [];
  double discount = 0.0;
  bool isCheckingOut = false;

  @override
  GraftProps get props => propsOf(items, discount, isCheckingOut);
}
```

- **`propsOf(...)`**: Accepts up to 16 positional fields. Collections like `List<String> items` are treated as individual domain properties and diffed efficiently.

### 2. Controller & Cascade Mutations (`Graft<S>`)

`Graft<S>` manages your business logic and state transitions:

```dart
class CartGraft extends Graft<CartState> {
  CartGraft() : super(CartState());

  void addItem(String item) {
    state
      ..items.add(item)
      ..update();
  }

  Future<void> checkout() async {
    state
      ..isCheckingOut = true
      ..update();

    try {
      await api.submitOrder(state.items);
      state
        ..items.clear()
        ..isCheckingOut = false
        ..update();
    } catch (e) {
      state
        ..isCheckingOut = false
        ..update();
      addError(e);
    }
  }
}
```

- **In-place Cascade Updates:** Modify properties directly and call `..update()`.
- **Flutter `Listenable` Support:** `Graft<S>` implements `Listenable` directly, allowing it to work with Flutter's standard `ListenableBuilder` and `AnimatedBuilder` with zero adapter allocations.

### 3. Targeted UI Slots

Graft provides dedicated slot widgets so you never have to manually rebuild whole screens:

#### Single Leaf Slot (`graft.slot`)
Binds an isolated widget to the controller. The builder executes only when fields accessed inside it change:
```dart
cart.slot((s) => Text('Items: ${s.items.length}'))
```

#### Multi-Child Layout Engine (`graft.slots`)
Insulates multiple children inside layouts like `Column`, `Row`, or `Wrap`. Only the specific child slot that changed rebuilds; sibling slots and the parent layout remain completely static:
```dart
cart.slots(
  layout: Column(children: slots),
  slots: (s) => [
    Text('Discount: ${s.discount}%'),
    const Divider(), // Static widget: 0 rebuilds
    if (s.isCheckingOut) const CircularProgressIndicator(),
  ],
)
```

#### Virtualized Lists (`graft.builder` & `graft.item`)
For lists and collections with per-item rebuild isolation:
```dart
cart.builder<String>(
  items: (s) => s.items,
  itemBuilder: (item, index) => ListTile(title: Text(item)),
)
```

#### Multi-Controller Rebuild Firewall (`GraftBoundary`)
When a widget needs to listen to multiple controllers simultaneously, `GraftBoundary` discovers and listens to all accessed controllers without parent rebuild churn:
```dart
GraftBoundary(
  builder: (context) {
    return Row(
      children: [
        Text(userGraft.state.name),
        Icon(Icons.circle, color: themeGraft.state.primaryColor),
      ],
    );
  },
)
```

### 4. Ambient Route Lifecycle (`context.use` vs `context.create`)

Graft eliminates the need to wrap your widget tree in `Provider` or `BlocProvider`:

- **`context.use(Controller.new)` (Shared Flow):** Borrows an existing controller instance across the current navigation flow, or creates one if it does not yet exist. When the route that originally created the controller is popped from the `Navigator`, Graft automatically disposes it.
- **`context.create(Controller.new)` (Isolated Instance):** Always creates a brand-new, isolated instance owned exclusively by the current widget.
- **Dialog & Bottom Sheet Safety:** Modal routes like `showDialog` and `showModalBottomSheet` borrow the host route's controller safely without accidentally disposing it when dismissed.

```dart
// Screen A: Creates the controller (becomes the owner)
final checkout = context.use(CheckoutGraft.new);

// Screen B (pushed from Screen A): Borrows the same checkout instance
final checkout = context.use(CheckoutGraft.new);

// When Screen A pops: checkout is automatically disposed
```

### 5. Dependency Injection (`bind`, `use`, & `GraftScope`)

Graft includes a lightweight, 100% lazy dependency injection container:

```dart
// 1. Register dependencies (stored as function pointers, instantiated on first use)
bind<ApiClient>(() => ApiClient());
bind<DatabaseService>(() => DatabaseService());

// 2. Resolve anywhere in pure Dart or Flutter
final client = use<ApiClient>();

// 3. Group related services under type-safe enum scopes
enum AppScope with GraftScope { auth, checkout }

scope(AppScope.checkout, () {
  bind<CartDao>(() => CartDao());
  bind<CheckoutCoordinator>(() => CheckoutCoordinator(use<CartDao>()));
});

// 4. Drop entire scopes cleanly in reverse topological order (consumers dispose before dependencies)
AppScope.checkout.drop();
```

### 6. Instant Frame-0 Persistence (`Graft.dry`)

Traditional local persistence requires asynchronous reads that cause input fields to flicker or show loading states when the screen first mounts.

With Graft's **Dry Persistence**, state is hydrated synchronously from an L1 in-memory cache before the very first frame renders:

```dart
class ProfileState extends GraftState {
  @override
  int get schemaVersion => 1;

  String username;
  String bio;

  ProfileState([this.username = '', this.bio = '']);

  @override
  GraftProps get props => propsOf(username, bio);
}

class ProfileGraft extends Graft<ProfileState> {
  // Uses super.dry with the state constructor tear-off
  ProfileGraft() : super.dry(ProfileState.new, key: 'user_profile');
}
```

- **Synchronous L1 RAM Cache:** State is restored in memory before widget layout.
- **Coalescing Background Writes:** Changes are written to disk through an automated 300ms debounced queue.
- **Zero-Controller Form Binding:** Form fields bind directly to `graft.state.username` without requiring separate `TextEditingController` instances or `initState` boilerplate.

---

## 📚 Complete Public API Reference

Graft exports a strictly curated, minimal public API surface from `package:graft/graft.dart`. Every element has a dedicated purpose:

### 1. Core State & Controllers

| API | Type | What It's Used For |
|---|:---:|---|
| **`Graft<S>`** | `class` | Base controller class (`implements Listenable`). Holds business logic, manages `state`, triggers notifications via `..update()`, dispatches errors via `addError()`, and handles Frame-0 persistence via `super.dry()`. |
| **`GraftState`** | `class` | Base class for domain state models. Holds fields, declares `GraftProps get props => propsOf(...)` for 64-bit bitmask diffing, and specifies `schemaVersion` for migrations. |
| **`propsOf(...)`** | `method` | Packs up to 16 state fields into an allocation-free 64-bit diffing representation. Domain collections (`List`, `Set`, `Map`) are handled zero-copy without flattening. |
| **`ValueGraft<T>`** | `class` | Lightweight reactive controller for simple primitive values (`int`, `String`, `bool`) without needing a dedicated `GraftState` subclass. Mutate via `.value = ...`. |

### 2. UI Slots & Selective Rebuilds

| API | Type | What It's Used For |
|---|:---:|---|
| **`graft((s) => Widget)`** | `callable` | Callable syntax shortcut on `Graft` instances. Creates an isolated leaf slot that rebuilds *only* when properties accessed inside its builder change. |
| **`graft.slot((s) => Widget)`** | `method` | Explicit isolated single-child slot. Traps rebuilds strictly inside its element boundary; parent layouts never rebuild. |
| **`graft.slots(...)`** | `method` | Multi-child layout engine. Insulates children inside layouts (`Column`, `Row`, `Wrap`, etc.) using the `slots` sentinel. Only modified children rebuild; static children remain untouched. |
| **`graft.builder<T>(...)`** | `method` | Virtualized list builder. Diffs collections and updates only items whose fields have actually changed. |
| **`graft.item<T>(...)`** | `method` | Isolated single-item slot within a custom list or collection. |
| **`graft.compute<T>(...)`** | `method` | Synchronously derives and caches computed state values from the controller, rebuilding only when the derived output changes. |
| **`GraftBoundary`** | `widget` | Rebuild firewall for multi-controller widgets. Automatically discovers and subscribes to all `Graft` instances accessed inside its builder. |
| **`slots`** | `const` | Sentinel identifier passed to layout widgets in `graft.slots(layout: Column(children: slots))` to designate slot insertion positions. |
| **`GraftEquivalent`** | `interface` | Interface for custom widgets to implement structural equality checks, allowing the slot engine to bypass unnecessary widget instantiation. |

### 3. Context Lifecycle & Navigation

| API | Type | What It's Used For |
|---|:---:|---|
| **`context.use<T>([factory, key])`** | `extension` | Resolves or borrows an ambient `Graft` across navigation flows (`Navigator`, dialogs, bottom sheets). Auto-promotes to permanent singleton at app root (`route == null`), and auto-disposes when the owning screen pops. |
| **`context.create<T>([factory, key])`** | `extension` | Force-creates a brand-new, private `Graft` controller owned exclusively by the current screen, bypassing the ambient borrowing pool. |

### 4. Dependency Injection & Scopes

| API | Type | What It's Used For |
|---|:---:|---|
| **`bind<T>(factory)`** | `function` | Registers a 100% lazy dependency in the DI container. Stores a function pointer; instantiation occurs strictly on first access via `use<T>()`. |
| **`use<T>()`** | `function` | Synchronously resolves a dependency from the DI container with $< 0.8\text{ ns}$ hot lookup speed. |
| **`scope(GraftScope, () => ...)`** | `function` | Groups related dependency registrations under a type-safe enum scope. |
| **`GraftScope`** | `mixin` | Applied to user-defined enums (`enum AppScope with GraftScope { auth, cart }`). Provides `.drop()` (reverse topological disposal) and `.invalidateDry()`. |
| **`GraftService`** | `class` | Base class for injectable application services with automated DI lifecycle hooks (`onInit()` and `onDispose()`). |

### 5. Frame-0 Persistence & Models

| API | Type | What It's Used For |
|---|:---:|---|
| **`super.dry(State.new, ...)`** | `constructor` | Constructor on `Graft` enabling Frame-0 persistence. Synchronously restores state from L1 RAM cache before the first frame mounts, with debounced (300ms) background disk writes. |
| **`GraftDryConfig`** | `interface` | Pure storage contract defining 5 storage I/O methods (`readAllSync`, `read`, `write`, `delete`, `close`). Pass to `Graft.config(dryConfig: ...)` to back persistence with any engine (e.g. SQLite, SharedPreferences). |
| **`GraftModel`** | `class` | Base class for nested domain sub-models inside a `GraftState`. Supports `propsOf(...)` diffing and binary serialization. |

### 6. App Configuration & Telemetry

| API | Type | What It's Used For |
|---|:---:|---|
| **`Graft.config(...)`** | `static method` | Centralized startup configuration. Configures `dryConfig`, `observer`, initial `di: () => ...` bindings, and direct logging flags (`debugLogging`, `logChanges`, `logRebuilds`, `logState`, `logDI`, `logDry`, `logBindings`, `logErrors`, `enableTimeline`). |
| **`GraftObserver`** | `class` | Base observer class for monitoring global lifecycle events (`onCreate`, `onDispose`), state mutations (`onStateChanged`), and dispatched errors (`onError`). |

### 7. Declarative Testing Suite (`package:graft/testing.dart`)

For hermetic unit and widget testing, import `package:graft/testing.dart`:

| API | Type | What It's Used For |
|---|:---:|---|
| **`graftTest(...)`** | `function` | Declarative controller test runner with structured phases (`overrides`, `build`, `setUp`, `seed`, `act`, `wait`, `expect`, `errors`, `verify`). |
| **`GraftTesting.resetAll()`** | `static method` | 1-line hermetic isolation for test `setUp()`. Wipes all active DI scopes, ambient route caches, persistence queues, and observers. |
| **`GraftTesting.override<T>(mock)`** | `static method` | Injects mock DI dependencies into the ambient container. |
| **`GraftTesting.overrideController<G>(mock)`** | `static method` | Pre-seeds mock controllers for `context.use<G>()` in widget tests with zero widget tree wrappers. |
| **`GraftTesting.flushPersistence()`** | `static method` | Synchronously flushes debounced Frame-0 persistence disk writes without wall-clock delays. |
| **`GraftTesting.recordChanges(graft, fn)`** | `static method` | Captures controller transition history and dirty bitmasks (`change.isDirty(i)`). |
| **`MemoryStateConfig`** | `class` | In-memory `GraftDryConfig` driver for testing Frame-0 persistence with zero disk I/O. |

---

## 🛡️ Official Linter (`graft_lint`)

Graft provides an official analyzer plugin, **[`graft_lint`](https://pub.dev/packages/graft_lint)**, that runs directly in your IDE to catch architectural anti-patterns, guarantee slot safety, and enforce zero-allocation 64-bit diffing contracts in real time.

### Rules Included:

| Rule | Severity | What It Catches & Enforces |
|---|:---:|---|
| **`avoid_nested_graft_slot`** | 🔴 `error` | Flags illegal nesting of slots (`slot`, `slots`, `builder`) within the same controller, preventing duplicate evaluation overhead. |
| **`prefer_props_in_graft_state`** | 🔴 `error` | Enforces overriding `GraftProps get props => propsOf(...)` in `GraftState` and `GraftModel` classes for hardware CPU bitmask diffing. |
| **`require_dry_config`** | 🔴 `error` | Warns when a controller declares `super.dry(...)` persistence but `Graft.config()` is missing a configured `dryConfig`. |
| **`require_dry_contracts`** | 🔴 `error` | Enforces mandatory `schemaVersion`, constructor hydration defaults, and `factory` tear-offs for persistent Frame-0 states. |

### Setup:

```yaml
# pubspec.yaml
dev_dependencies:
  custom_lint: ^0.8.1
  graft_lint: ^1.0.0-alpha.10

# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

---

## When to Use Graft

### Graft is a great fit for:
- **Medium to Large Production Applications:** Apps with multi-step workflows, complex domain models, and shared navigation flows.
- **Forms and Settings Screens:** Forms with multiple fields where you want automatic local persistence without writing manual serialization for every keystroke.
- **Dense or Frequently Updating Lists:** Feeds, dashboards, and virtualized lists where minimizing rebuild churn is critical to maintaining 60/120 FPS.
- **Clean Architecture & Domain-Driven Design:** Projects that benefit from separating UI from business logic without incurring boilerplate or code-generation overhead.

### Simpler alternatives might suffice when:
- **Trivial or Small Apps:** If your app only needs to toggle a theme or track a single counter, standard Flutter primitives like `ValueNotifier` or `InheritedWidget` may be all you need.
- **Strict Event-Driven Pipelines:** If your team requires immutable event streams for every single user interaction, an event-sourced library like `bloc` may better match your architecture.

---

## Project Status

Graft is currently in **public alpha (`1.0.0-alpha.10`)**.

The core reactive engine, slot diffing, ambient route tracking, dependency injection, and persistence systems are fully implemented and verified against **315 tests** covering unit, widget, and stress scenarios.

We actively welcome community feedback, issue reports, and suggestions on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) as we progress toward a stable 1.0 release.

---

## Deep Documentation

For in-depth architectural guides, benchmarks, and API documentation, explore the companion documents:

- 🚀 **[graft_template](https://github.com/kmmuzahid/graft_template):** Production starter template integrating Graft with CoreKit, featuring auto-scoped route controllers, Frame-0 persistence, and dark/light theming.
- 🏛️ **[ARCHITECTURE.md](https://github.com/kmmuzahid/graft/blob/main/ARCHITECTURE.md):** Deep technical dive into the runtime architecture, memory model, bitmask diffing, and dependency graph.
- 💾 **[GRAFT_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md):** Comprehensive guide to state management, UI slots, and Frame-0 persistence.
- 💉 **[DI_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md):** Guide to the dependency injection engine, enum scoping, reverse DAG teardown, and route leasing.
- 🧪 **[GRAFT_TESTING_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_TESTING_GUIDE.md):** Complete guide to testing Graft apps: declarative `graftTest` unit tests, mock DI overrides, widget test controller injection, and transition verification.
- 🛡️ **[packages/graft_lint](https://github.com/kmmuzahid/graft/tree/main/packages/graft_lint):** Official analyzer plugin and linter rules enforcing bitmask contracts, slot safety, and dry persistence at edit time.
- 📊 **[BENCHMARK_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** Empirical benchmark comparisons and methodology across native and web platforms.
- 📋 **[TEST_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Full test suite verification matrix across all test files.

---

## License

MIT License. Free for commercial and open-source use.
