# Graft

A self-optimizing state management and dependency injection library for Flutter that combines structured domain models with fine-grained UI rebuilds — with zero code generation.

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![tests](https://img.shields.io/badge/tests-313%20passed-brightgreen.svg)](https://github.com/kmmuzahid/graft)
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

### 1. Add Dependency

```bash
flutter pub add graft
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

- **`propsOf(...)`**: Accepts up to 16 positional fields. Collections like `List<String> items` are treated as individual properties and diffed efficiently.
- **`propsOfCollection(...)`**: For large state models or dynamically generated property lists (> 16 fields).

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

The core reactive engine, slot diffing, ambient route tracking, dependency injection, and persistence systems are fully implemented and verified against **313 tests** covering unit, widget, and stress scenarios.

We actively welcome community feedback, issue reports, and suggestions on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) as we progress toward a stable 1.0 release.

---

## Deep Documentation

For in-depth architectural guides, benchmarks, and API documentation, explore the companion documents:

- 🚀 **[graft_template](https://github.com/kmmuzahid/graft_template):** Production starter template integrating Graft with CoreKit, featuring auto-scoped route controllers, Frame-0 persistence, and dark/light theming.
- 🏛️ **[ARCHITECTURE.md](https://github.com/kmmuzahid/graft/blob/main/ARCHITECTURE.md):** Deep technical dive into the runtime architecture, memory model, bitmask diffing, and dependency graph.
- 💾 **[GRAFT_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md):** Comprehensive guide to state management, UI slots, and Frame-0 persistence.
- 💉 **[DI_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md):** Guide to the dependency injection engine, enum scoping, reverse DAG teardown, and route leasing.
- 🧪 **[GRAFT_TESTING_GUIED.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_TESTING_GUIED.md):** Complete guide to testing Graft apps: declarative `graftTest` unit tests, mock DI overrides, widget test controller injection, and transition verification.
- 📊 **[BENCHMARK_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** Empirical benchmark comparisons and methodology across native and web platforms.
- 📋 **[TEST_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Full test suite verification matrix across all test files.

---

## License

MIT License. Free for commercial and open-source use.
