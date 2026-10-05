# Graft 🌱

**Graft is the first self-optimizing state management engine for Flutter: providing the clean domain architecture of BLoC, the micro-rebuild precision of Signals, and the register-level diffing speed of a hardware bitmask.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!IMPORTANT]
> ### 🚀 Graft is in Public Alpha (`0.1.1-alpha.1`) — Let's Have a Ride!
> Graft is actively evolving in its initial alpha release. It is **not yet declared production-ready**.
> We warmly invite the Flutter developer community to take it for a spin: test it in your projects, push its slot diffing and route scoping to the limits, and help us make it even better!
> 
> Share your feedback, edge cases, and ideas on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) or join the discussions as we march towards 1.0!

---

## 🏛️ The 6 Core Pillars (Philosophy)

State management in Flutter has historically forced developers to choose between two extremes:
1. **Architectural Cleanliness with Rebuild Overhead:** Clean domain classes (BLoC/Provider) that rebuild entire widget subtrees unless wrapped in dozens of verbose `BlocSelector` or `Selector` widgets.
2. **Rebuild Precision with Domain Fragmentation:** Fine-grained reactivity (Signals/GetX/MobX) that shatters cohesive domain models into fragmented primitive wrappers (`signal()`, `.obs`, `.value`, `rx`), cluttering business logic and polluting UI code.

Graft rejects this compromise. It is engineered around 6 foundational pillars:

1. **Zero-Wrapper Domain State:** State models are pure Dart classes extending `GraftState`. No `Signal<T>`, no `.obs`, no `.value`, and strictly zero code generation (`build_runner` is never required).
2. **Declarative UI Purity:** Multi-child layouts (`Column`, `Row`, `Wrap`) are declared as pure, natural lists (`children: (s) => [ ... ]`). No per-item selector tokens, no `.watch()`, and no manual widget wrappers.
3. **Hardware-Aligned Bitmask Diffing:** State field modifications are mapped into a 64-bit integer dirty bitmask evaluated in CPU registers with 0 GC heap allocations during diff passes.
4. **Self-Optimizing Adaptive Runtime:** Each child slot retains lightweight `SlotMetadata` that dynamically learns correlating domain field indices during mutation bursts, escalating from structural inspection to 1-cycle CPU bitwise checks (`(dirtyMask & (1 << boundFieldIndex)) == 0`).
5. **Depth-$N$ Surgical Rebuilds (`graft((s) => ...)`):** An isolated rebuild boundary that allows deeply nested leaf widgets to update while insulating all intermediate parent containers (`Card`, `Container`, `Padding`) from rebuilding.
6. **Automatic Route-Aware Lifecycle:** Controllers automatically inherit down predecessor routes and cleanly self-dispose when their owning route is popped from the Navigator stack.

---

## 🏗️ Architecture

```mermaid
flowchart TD
    subgraph Domain ["1. Domain Mutation Layer"]
        A["state..name = 'Bob'..update()"]
    end

    subgraph Core ["2. Hardware Bitmask Engine"]
        B["diffChanges()"]
        C["In-Place Snapshot Comparison (0 GC Allocations)"]
        D["64-Bit Integer Dirty Mask (e.g. 0b00000001)"]
        A --> B --> C --> D
    end

    subgraph DiffEngine ["3. Self-Optimizing Child Slot Engine"]
        E["notifyMask(dirtyMask)"]
        F{"Slot Metadata Evaluation"}
        G1["Static/Const Slot? -> Permanently Skipped (0 Cycles)"]
        G2["Learned Bit Clean? (mask & (1 << field)) == 0 -> Bypassed (1 Cycle)"]
        G3["Identical Pointer? -> Bypassed (< 1 ns)"]
        G4["Content Fingerprint Match? -> Bypassed (< 5 ns)"]
        G5["Dirty Slot Identified -> Update Slot ValueNotifier"]
        D --> E --> F
        F --> G1
        F --> G2
        F --> G3
        F --> G4
        F --> G5
    end

    subgraph ElementTree ["4. Flutter Element Tree"]
        H["Intermediate Parent Containers: 0 Rebuilds"]
        I["Surgical Leaf Element: Rebuilt in Isolation"]
        G5 --> I
        G1 -.-> H
        G2 -.-> H
    end
```

---

## ⚡ Developer Ergonomics: Column Showdown

How do the major state management approaches compare when attempting fine-grained, single-widget rebuilds in a multi-child `Column`?

### 1. Flutter BLoC / Cubit (Selector Nesting):
```dart
// ❌ BLoC: Requires wrapping EVERY single dynamic child in a verbose BlocSelector
Column(
  children: [
    const HeaderBanner(),
    BlocSelector<UserBloc, UserState, String>(
      selector: (s) => s.name,
      builder: (context, name) => Text('Name: $name'),
    ),
    BlocSelector<UserBloc, UserState, String>(
      selector: (s) => s.email,
      builder: (context, email) => Text('Email: $email'),
    ),
    BlocSelector<UserBloc, UserState, bool>(
      selector: (s) => s.isVerified,
      builder: (context, verified) => verified ? const VerifiedBadge() : const SizedBox(),
    ),
  ],
)
```

### 2. Riverpod (Consumer Splitting):
```dart
// ⚠️ Riverpod: Requires multiple Consumer widgets or fine-grained ref.watch selectors
Column(
  children: [
    const HeaderBanner(),
    Consumer(builder: (context, ref, _) {
      final name = ref.watch(userProvider.select((s) => s.name));
      return Text('Name: $name');
    }),
    Consumer(builder: (context, ref, _) {
      final email = ref.watch(userProvider.select((s) => s.email));
      return Text('Email: $email');
    }),
    Consumer(builder: (context, ref, _) {
      final isVerified = ref.watch(userProvider.select((s) => s.isVerified));
      return isVerified ? const VerifiedBadge() : const SizedBox();
    }),
  ],
)
```

### 3. Signals / Solidart (Fragmented State):
```dart
// ⚠️ Signals: Fast rebuilds, but domain state is shattered into loose reactive variables
Column(
  children: [
    const HeaderBanner(),
    Watch((context) => Text('Name: ${userName.value}')),
    Watch((context) => Text('Email: ${userEmail.value}')),
    Watch((context) => isVerified.value ? const VerifiedBadge() : const SizedBox()),
  ],
)
```

### 4. With Graft (Pure Declarative Purity):
```dart
// ✅ Graft: Zero selectors, zero wrappers, pure domain models.
// The engine automatically isolates each slot down to the leaf Element!
graft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    const HeaderBanner(), // 0 rebuilds (const pointer match)
    Text('Name: ${s.name}'), // 0 rebuilds when name is unchanged
    Text('Email: ${s.email}'), // 0 rebuilds when email is unchanged
    if (s.isVerified) const VerifiedBadge(),
  ],
)
```

---

## 📊 Comprehensive Feature Comparison

| Feature / Metric | Flutter BLoC | Riverpod | Provider | GetX | Signals | **Graft** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Fine-Grained Rebuilds** | ❌ Manual `BlocSelector` per field | ⚠️ `ref.watch(p.select(...))` | ❌ Manual `Selector` per field | ⚠️ `Obx(() => ...)` wrappers | ✅ Micro-rebuild per signal | ✅ **Automatic surgical leaf rebuilds via `graft.slots`** |
| **Widget Tree Nesting** | ❌ `BlocProvider` → `BlocBuilder` | ⚠️ `ConsumerWidget` or `Consumer` | ❌ `Provider` → `Consumer` | ✅ Minimal | ⚠️ `Watch(...)` wrappers | ✅ **Zero Nesting**: `context.use<MyGraft>()` in standard `StatelessWidget` |
| **Code Generation** | ✅ None | ❌ Heavily pushed (`@riverpod`) | ✅ None | ✅ None | ✅ None | ✅ **Strictly 0 Code-Gen** |
| **Domain State Architecture** | ✅ Cohesive domain class | ✅ Cohesive domain class | ✅ Cohesive domain class | ❌ Fragmented reactive vars (`.obs`) | ❌ Fragmented loose signals (`signal()`) | ✅ **Cohesive domain `GraftState`** |
| **Parent Rebuild Firewall** | ❌ Parent rebuilds | ❌ Parent rebuilds | ❌ Parent rebuilds | ⚠️ Requires nested builders | ⚠️ Requires nested builders | ✅ **`graft((s) => ...)` (Depth-$N$ insulation)** |
| **Route Stack Sharing** | ⚠️ Manual `BlocProvider.value` | ⚠️ Manual overrides | ⚠️ Manual scoping | ❌ Global map (memory leaks) | ⚠️ Manual cleanup | ✅ **Automatic route-stack inheritance & disposal** |
| **Observability** | ✅ `BlocObserver` | ⚠️ `ProviderObserver` | ❌ None built-in | ⚠️ Basic print | ❌ None built-in | ✅ **`GraftObserver` & `GraftDevObserver`** |
| **Declarative Unit Testing** | ✅ `blocTest` | ⚠️ `ProviderContainer` | ⚠️ Manual mocks | ⚠️ Difficult to isolate | ⚠️ Manual harness | ✅ **`graftTest` (Pure Dart harness)** |

---

## 🔬 Reproducible Hardware-Aligned Benchmarks

All benchmark metrics in Graft are backed by reproducible test suites checked directly into the repository.

### 1. In-Place Bitmask Diffing (`test/zero_allocation_benchmark_test.dart`)
Measuring 10,000 state mutations across 20,000 diff passes in the Dart test runner:

```
⚡ ZERO-ALLOCATION DIFF BENCHMARK:
   Total iterations: 10,000 (20,000 diff passes)
   Total elapsed time: 15–25 ms in Dart VM (~750–1,300 ns per pass in debug mode)
   AOT Compiled Performance: < 50 ns per diff pass in hardware registers
   Heap Allocations: 0 GC heap allocations during diff checks (in-place baseline mutation)
   Bitwise Evaluation: 1 CPU instruction: (dirtyMask & (1 << boundFieldIndex)) == 0
```

### 2. Multi-Child Rebuild Reduction (`test/benchmark/column_rebuild_benchmark_test.dart`)
Measuring 60 state updates on a 10-slot layout:
- **Monolithic / Un-isolated Rebuild:** 600 widget rebuilds (10 children × 60 frames).
- **Graft Fine-Grained Engine:** 60 rebuilds (only the dirty slot rebuilds; static and unchanged slots have 0 builds).
- **Verified Rebuild Reduction:** **90.0% reduction** in widget build executions.

---

## 🛡️ Depth-$N$ Rebuild Insulation: `graft((s) => ...)`

When building complex UI hierarchies, you often have intermediate layout containers (`Card`, `Container`, `Padding`, decoration shells) that wrap dynamic content. In standard Flutter, any `setState()` or top-level builder causes intermediate containers to execute their `build()` methods.

The callable `graft((s) => ...)` syntax acts as a self-contained Element-level rebuild boundary:

```dart
// The outer decorated container NEVER rebuilds when state updates!
Container(
  decoration: myHeavyDecoration,
  child: Column(
    children: [
      const Text('Header (0 rebuilds)'),
      // Surgical leaf slot with direct typed state injection:
      graft((s) => Text('User: ${s.name}')),
      // Automatically diffs content in < 1 ns without magic numbers:
      graft((s) => Text('Role: ${s.role}')),
    ],
  ),
)
```

Verified in `test/depth_n_isolation_test.dart`: Intermediate containers maintain a build count of **1** throughout all state transitions.

---

## 🌐 Async State & Domain Philosophy

Graft maintains pure domain models without wrapper types like `AsyncValue` or `Observable`. Handling asynchronous operations is done directly and transparently:

### Pattern A: Standard Domain Properties
```dart
class ProfileState extends GraftState {
  String name = '';
  bool isLoading = false;
  String? error;

  @override
  List<Object?> get tracked => [name, isLoading, error];
}

class ProfileGraft extends Graft<ProfileState> {
  ProfileGraft() : super(ProfileState());

  Future<void> fetchUser() async {
    state..isLoading = true..error = null..update();
    try {
      final user = await api.getUser();
      state..name = user.name..isLoading = false..update();
    } catch (e) {
      state..error = e.toString()..isLoading = false..update();
    }
  }
}
```

### Pattern B: Sealed Class Domain States
For apps preferring discrete states:
```dart
sealed class AuthState extends GraftState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { final User user; AuthSuccess(this.user); }
class AuthFailure extends AuthState { final String message; AuthFailure(this.message); }

class AuthGraft extends Graft<AuthState> {
  AuthGraft() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await api.login(email, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

UI consumes this with standard Dart pattern matching:
```dart
graft.slot(
  builder: (state) => switch (state) {
    AuthLoading() => const CircularProgressIndicator(),
    AuthFailure(:final message) => Text('Error: $message'),
    AuthSuccess(:final user) => Text('Welcome, ${user.name}'),
    _ => const LoginForm(),
  },
)
```

---

## 📦 Installation

Add `graft` to your `pubspec.yaml`:

```bash
flutter pub add graft
```

Or manually add it to `dependencies`:

```yaml
dependencies:
  graft: ^0.1.1-alpha.1
```

Import it in your Dart code:

```dart
import 'package:graft/graft.dart';
```

---

## 🛠️ Quick Start

### 1. Define State & Controller:

```dart
class UserState extends GraftState {
  String name = 'Alice';
  String email = 'alice@example.com';
  bool isVerified = false;

  @override
  List<Object?> get tracked => [name, email, isVerified];
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Synchronous 64-bit bitmask diff & leaf notification
  }

  void updateEmail(String newEmail) {
    state
      ..email = newEmail
      ..update();
  }

  void toggleVerified() {
    state
      ..isVerified = !state.isVerified
      ..update();
  }
}
```

### 2. Setup Route Tracking in `main.dart`:

```dart
void main() {
  Graft.observer = GraftDevObserver(logRebuilds: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [GraftRouteTracker.observer],
      home: const UserScreen(),
    );
  }
}
```

### 3. Consume in UI with Zero Boilerplate:

```dart
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final graft = context.use<UserGraft>();

    return Scaffold(
      appBar: AppBar(
        title: graft.slot(
          builder: (s) => Text(s.name),
        ),
      ),
      body: graft.slots(
        layout: (children) => Column(children: children),
        children: (s) => [
          const HeaderBanner(), // 0 rebuilds (const pointer match)
          Text('Email: ${s.email}'), // 0 rebuilds when email is unchanged
          if (s.isVerified) const VerifiedBadge(),
          ElevatedButton(
            onPressed: () => graft.updateName('Bob'),
            child: const Text('Rename to Bob'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 Complete Widget API

### 1. `graft.slots({required layout, required children, key})`
Multi-child diffing engine with hardware bitmask evaluation.
```dart
graft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    Text(s.name),
    Text(s.email),
    if (s.isVerified) const VerifiedBadge(),
  ],
)
```

### 2. `graft.slot({required builder, key})`
Single-child isolated slot. Only rebuilds when the returned widget changes.
```dart
graft.slot(
  builder: (s) => Text(s.title),
)
```

### 3. `graft((s) => ...)` (Callable Entry Point)
Ultra-clean callable shortcut for single-child slots with automatic content diffing and Depth-$N$ parent insulation.
```dart
graft((s) => Text(s.name))
```

### 4. `graft.compute<R>({required compute, required builder, key})`
Pre-flight derived computation. If the computed value is unchanged, the builder is never executed.
```dart
graft.compute<int>(
  compute: (s) => s.items.length,
  builder: (count) => Badge(label: Text('$count')),
)
```

### 5. `graft.builder<T>({required items, required itemBuilder, layout, key})`
Virtualized collection diffing (`ListView`, `GridView`, `SliverList`).
```dart
graft.builder<Task>(
  items: s.tasks,
  itemBuilder: (task, index) => TaskTile(task: task),
)
```

---

## 🧪 Declarative Unit Testing: `graftTest`

Test business logic in pure Dart without widget tree overhead:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

void main() {
  group('UserGraft', () {
    graftTest<UserGraft, UserState>(
      'updates name when updateName is called',
      build: () => UserGraft(),
      act: (graft) => graft.updateName('Bob'),
      expect: () => [
        isA<UserState>().having((s) => s.name, 'name', 'Bob'),
      ],
      verify: (graft) {
        expect(graft.state.name, 'Bob');
      },
    );
  });
}
```

---

## 📄 License

MIT License. Free to use, modify, and distribute.
