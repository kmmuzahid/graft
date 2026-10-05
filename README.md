# Graft 🌱

**Graft is the first self-optimizing state management engine for Flutter: providing the clean domain architecture of BLoC, the micro-rebuild precision of Signals, and the register-level diffing speed of a hardware bitmask.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!IMPORTANT]
> ### 🚀 Graft is in Public Alpha (`0.1.2-alpha.1`) — Let's Have a Ride!
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
2. **Mandatory `props` Contract:** Domain properties are declared via `List<Object?> get props;`, an abstract compiler-enforced contract eliminating forgotten fields and ensuring 100% snapshot integrity.
3. **Unbounded Hardware-Aligned `GraftMask`:** State field modifications are mapped into an unbounded, 32-bit chunked word-based bitset (`GraftMask`). It diffs $\le 64$ fields in CPU registers and effortlessly scales to 128, 500, or 1000+ fields with 100% web JS compatibility and 0 GC heap allocations.
4. **Synchronous In-Place Mutation & Reset:** Direct synchronous updates via `state..field = val..update()` and complete baseline resets via `state.reset()`. No async coalescing delays, no fragmented `emit()` / `mutate()` / `produce()`.
5. **Two-Wrapper Architecture:**
   - **`GraftBoundary`**: High-level subtree rebuild barrier featuring **Ambient Auto-Discovery** (zero manual lists via `GraftScopeTracker`) and **Backward Adaptive Learning**.
   - **`graft((s) => ...)`**: Fine-grained surgical leaf slot with Depth-$N$ parent rebuild insulation.
6. **Automatic Route-Aware Lifecycle:** Controllers automatically inherit down predecessor routes and cleanly self-dispose when their owning route is popped from the Navigator stack.

---

## 🏗️ Architecture: Hardware-Aligned Pipeline

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      DEVELOPER CALL (ZERO BOILERPLATE)                 │
│                 state..tasks.add(item)..name = 'Bob'..update()         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          GRAFT CORE ENGINE                             │
│                  diffChanges(): Evaluate props against _baseline       │
│                                   │                                    │
│         ┌─────────────────────────┴────────────────────────┐           │
│         ▼                                                  ▼           │
│  [ Primitive Values ]                             [ Collections ]      │
│  (int, String, bool)                             (List, Set, Map)      │
│  1-Cycle Pointer Identity:                       Invisible Snapshot:   │
│  identical(prev, curr)                           length & items check  │
│         │                                                  │           │
│         └─────────────────────────┬────────────────────────┘           │
│                                   ▼                                    │
│            Compute 64-bit Integer dirtyMask in CPU registers           │
│                                   │                                    │
│                                   ▼                                    │
│                       notifyMask(dirtyMask)                            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        UI SLOT RECONCILIATION                          │
│                 GraftMultiChildDiffEngine / GraftBoundary              │
│                                   │                                    │
│                                   ▼                                    │
│                 Pre-Flight Check: slot.isDirty(dirtyMask)?             │
│                                   │                                    │
│                 ┌─────────────────┴─────────────────┐                  │
│                 ▼                                   ▼                  │
│          [ Clean Slot ]                      [ Dirty Slot ]            │
│       dirtyMask.intersects == 0           dirtyMask.intersects != 0    │
│                 │                                   │                  │
│                 ▼                                   ▼                  │
│        ⚡ 1 CPU Cycle Bypass               Surgical Leaf Update         │
│     0 Widget Allocs, 0 Rebuilds       ValueNotifier.value = newWidget  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Unified End-to-End Runtime Lifecycle

```text
Navigator / UI                 Graft Tracker & Context           Graft Controller & State          UI Slot Reconciliation            Remote API
      │                                   │                                  │                               │                           │
      │── 1. ROUTE SCOPING & INHERITANCE (context.use<T>()) ─────────────────│───────────────────────────────│───────────────────────────│
      │   Push Route A ──────────────────►│                                  │                               │                           │
      │   context.use<UserGraft>() ──────►│── Instantiate UserGraft() ──────►│                               │                           │
      │                                   │   Register & hook route.popped   │                               │                           │
      │                                   │                                  │                               │                           │
      │── 2. AMBIENT AUTO-DISCOVERY & LEAF MOUNTING ─────────────────────────│───────────────────────────────│───────────────────────────│
      │                                   │                                  │◄── Reads state property ──────┤ (via GraftScopeTracker)   │
      │                                   │                                  │◄── Subscribes mask listener ──┤ (Backward Learning)       │
      │                                   │                                  │                               │                           │
      │── 3. SYNCHRONOUS IN-PLACE MUTATION & 1-CYCLE HARDWARE DIFFING ───────│───────────────────────────────│───────────────────────────│
      │── state..name = 'Bob'..update() ──┼─────────────────────────────────►│                               │                           │
      │                                   │                                  │── diffChanges() vs baseline   │                           │
      │                                   │                                  │   Compute dirtyMask bitset    │                           │
      │                                   │                                  │── notifyMask(dirtyMask) ─────►│                           │
      │                                   │                                  │                               ├── [Clean Slot (mask == 0)]│
      │                                   │                                  │                               │   ⚡ 1-cycle bypass (0 bld)│
      │                                   │                                  │                               └── [Dirty Slot (mask != 0)]│
      │                                   │                                  │                                   🔄 Leaf rebuild only!   │
      │                                   │                                  │                                                           │
      │── 4. ASYNC CONCURRENCY & STALE RESPONSE GUARD ───────────────────────│───────────────────────────────│───────────────────────────│
      │── Keystroke 1 ("da") ─────────────┼─────────────────────────────────►│── runAsync() [Task #1] ───────┼──────────────────────────►│
      │── Keystroke 2 ("dart") ───────────┼─────────────────────────────────►│── runAsync() [Task #2] ───────┼──────────────────────────►│
      │                                   │                                  │                               │◄── Task #1 finishes late ─│
      │                                   │                                  │   TaskId #1 != current (#2)   │    (STALE: DROPPED!)      │
      │                                   │                                  │                               │◄── Task #2 finishes fresh │
      │                                   │                                  │   TaskId #2 == current (#2)   │    (FRESH: ACCEPTED)      │
      │                                   │                                  │── emit(data: resultDart) ────►│── Update leaf results ────►│
      │                                   │                                  │                               │                           │
      │── 5. ROUTE POP & AUTOMATIC LEAK-FREE DISPOSAL ───────────────────────│───────────────────────────────│───────────────────────────│
      │── Navigator pops Route A ────────►│                                  │                               │                           │
      │                                   │── Route A.popped fired ─────────►│── userGraft.dispose()         │                           │
      │                                   │   Clean registry entry           │   🧹 Auto-disposed cleanly!   │                           │
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

### 3. Large-Scale Virtualized Lists: 10,000+ Items (`test/large_list_benchmark_test.dart`)
Measuring virtualization, high-speed jumps, and 500 rapid surgical mutations on a 10,000-item collection with `graft.builder` and `graft.item`:

```
================================================================================
  GRAFT LARGE LIST BENCHMARK (10,000 Items, 500 Rapid Surgical Updates)
================================================================================
  Total Items in State:  10,000
  Updates / Frames:      500
  Total Item Builds:     500 (Strictly 1.0 build per update)
  Elapsed Time:          ~150 ms in Dart VM (~300 µs per update)
  Rebuilds per Update:   1.0
  Efficiency:            100% surgical isolation (9,999 items untouched)
================================================================================
```
- **Native Lazy Virtualization:** In an 800×600 viewport, only the visible ~14 items are built in the Element tree; 9,985+ offscreen items are never instantiated.
- **Surgical Mutation at Scale:** Modifying an item at index 4 triggers strictly 1 rebuild on item #4. All other 9,999 items and the parent `ListView` have **0 rebuilds**.
- **High-Speed Jump (0 to 5,000):** Jumping `ScrollController.jumpTo(250,000)` recycles offscreen elements cleanly with zero memory leaks.
- **Custom `GridView.builder` (5,000 items):** Using `graft.item` inside custom grid delegates isolates cell mutations to only the edited cell; all other grid cells have **0 rebuilds**.

### 4. 60fps / 120fps High-Frequency Animation Isolation (`test/animation_isolation_test.dart`)
Measuring ticker rebuild isolation during continuous 60fps / 120fps frame rendering with `AnimationController` and implicit animations:

- **60fps `AnimationController` inside `graft.slots`:** An `AnimatedBuilder` ticked 60 frames over 1,000 ms. An adjacent heavy static container (`HeavyPaintContainer`), a reactive text slot, and the parent layout experienced strictly **0 rebuilds** across all 60 animation frames.
- **Concurrent Animation + State Mutations:** While an animation runs at 60fps, mutating Graft state every 10 frames (6 state updates total) maintains 60fps smooth ticking, updates only the reactive slot (6 builds), and keeps heavy static containers at **0 rebuilds**.
- **`GraftBoundary` Ticker Containment:** Running a 60fps animation inside `GraftBoundary` completely traps redraws downwards—the outer parent widget tree above the boundary experiences **0 rebuilds**.
- **Implicit Animations (`AnimatedContainer`):** Triggering a 300ms size tween (18 frames at 60fps) isolates intermediate tween calculations to the animated slot; sibling slots experience **0 rebuilds** across all 18 frames.
- **Leak-Free Ticker Lifecycle:** Active tickers and controllers inside unmounted or navigated Graft slots dispose cleanly with zero memory leaks or unhandled ticker assertions.

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
```text
┌───────────────────────────────────────────────────────────┐
│        Parent Layout / Heavy Container (0 Rebuilds)       │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         GraftBoundary Element (0 Rebuilds)          │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │  Internal ValueNotifier (Subtree Rebuild Root)│  │  │
│  │  │  ┌─────────────────────────────────────────┐  │  │  │
│  │  │  │  Target Child Element (ONLY THIS BUILDS)│  │  │  │
│  │  │  │  Text('User: Bob')                      │  │  │  │
│  │  │  └─────────────────────────────────────────┘  │  │  │
│  │  └───────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
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
  List<Object?> get props => [name, isLoading, error];
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

  void reset() {
    state.reset(); // Restores baseline and updates UI synchronously
  }
}
```

### Pattern B: First-Class `GraftAsync` & `runAsync`
Eliminates boilerplate try/catch and loading flags with pattern matching:
```dart
class AuthState extends GraftState {
  GraftAsync<User> auth = const GraftAsync.initial();

  @override
  List<Object?> get props => [auth];

  @override
  void onReset() {
    auth = const GraftAsync.initial();
  }
}

class AuthGraft extends Graft<AuthState> {
  AuthGraft() : super(AuthState());

  Future<void> login(String email, String password) async {
    await runAsync(
      future: () => api.login(email, password),
      assign: (result) => state..auth = result..update(),
    );
  }

  void logout() {
    state.reset(); // Calls onReset() and updates UI synchronously
  }
}
```

UI consumes this with standard Dart pattern matching:
```dart
graft.slot(
  builder: (state) => state.auth.when(
    initial: () => const LoginForm(),
    loading: () => const CircularProgressIndicator(),
    data: (user) => Text('Welcome, ${user.name}'),
    error: (e, _) => Text('Error: $e'),
  ),
)
```

### 🛡️ Transparent Async Concurrency Guard (Zero Race Conditions)

When rapid sequential async tasks execute (e.g., live autocomplete search as the user types), an earlier request that resolves late can overwrite fresher state, causing race conditions and visual glitching.

Graft's `runAsync` engine contains an invisible, monotonically increasing internal task token guard (detailed in **Phase 4** of the master lifecycle diagram above):
- Each call to `runAsync` increments a private `_currentAsyncTaskId`.
- When an asynchronous future completes, it verifies that its task ID matches the active `_currentAsyncTaskId`.
- Out-of-order or stale responses from older in-flight requests are **automatically dropped** with zero state mutation and zero unhandled exceptions.

Verified in `test/async_concurrency_race_test.dart`: Older asynchronous responses are safely discarded without requiring manual cancellation tokens.

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
  List<Object?> get props => [name, email, isVerified];
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Synchronous hardware bitmask diff & leaf notification
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

  void reset() {
    state.reset(); // Restores baseline and updates UI synchronously
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

## 🧭 Zero-Boilerplate Route Scoping & Auto-Disposal: `context.use<T>()`

In traditional state management libraries:
- **BLoC** requires manual `BlocProvider(create: ...)` wrappers nested at the top of route trees and manual `BlocProvider.value` passing across dialogs or bottom sheets.
- **Riverpod** requires manual family parameters or overrides.
- **GetX** stores controllers in a global hash map, leading to memory leaks and cross-tab collision.

### The Route-Stack Scoping Lifecycle
Graft solves this with **Element-to-Route automatic binding** (illustrated in **Phases 1 & 5** of the master lifecycle diagram above). When you call `context.use<UserGraft>()`:
1. It checks the local subtree for an explicit `GraftScope` (if scoped locally).
2. It looks up the current route instance via `ModalRoute.of(context)` and `GraftRouteTracker`.
3. If not yet created, it instantiates the Graft and hooks directly into the Route's `popped` stream.
4. Downstream routes (dialogs, bottom sheets, child screens) automatically inherit the parent instance from the stack with 0 duplicate instantiations.
5. When the owning route is popped from the Navigator, the Graft and its state are **automatically disposed** with 0 memory leaks.

### 🔀 Nested Navigators & GoRouter Multi-Tab Isolation
Graft seamlessly isolates parallel navigator hierarchies (such as bottom navigation tabs or nested shell routes in GoRouter). Each navigator branch maintains its own scoped controller registry without cross-tab state pollution (verified in `test/nested_route_isolation_test.dart`).

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
  items: (s) => s.tasks,
  itemBuilder: (task, index) => TaskTile(task: task),
)
```

### 6. `GraftBoundary(builder: (context) => ...)` (Subtree Rebuild Firewall & Multi-Graft Auto-Discovery)
`GraftBoundary` acts as an Element-level rebuild firewall. When placed inside `graft.slots` or any layout, it ambiently auto-discovers all Grafts read inside its builder (via `GraftScopeTracker`), learns field dependency bitmasks backwards, and completely insulates the outer parent widget tree from rebuilding.

#### 📦 Real-World Example: Nested inside `graft.slots`
```dart
graft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    // -----------------------------------------------------------------
    // Slot 0: Static Header (Non-const! Diff engine achieves 0 rebuilds)
    // -----------------------------------------------------------------
    Text('Dashboard Header'), // ✅ 0 rebuilds (even WITHOUT const! Content fingerprint matches in < 5 ns)

    // -----------------------------------------------------------------
    // Slot 1: Container with state text (Rebuilds ONLY when s.title changes)
    // -----------------------------------------------------------------
    Container(
      padding: const EdgeInsets.all(8),
      child: Text('Section: ${s.title}'), // 🎯 Rebuilds ONLY if s.title changes
    ),

    // -----------------------------------------------------------------
    // Slot 2: Expensive container wrapping GraftBoundary
    // -----------------------------------------------------------------
    HeavyPaintContainer(
      child: GraftBoundary(
        builder: (context) {
          // ✨ FEATURE: Ambiently reads multiple Grafts (userGraft, themeGraft)
          // without manual lists. Even while accessing state properties here,
          // HeavyPaintContainer and all parent widgets ABOVE this boundary NEVER rebuild!
          return Row(
            children: [
              Text('User: ${userGraft.state.name}'),
              const SizedBox(width: 8),
              Text('Theme: ${themeGraft.state.accentColor}'),
            ],
          );
        },
      ),
    ),

    // -----------------------------------------------------------------
    // Slot 3: Static Footer (Non-const! 0 rebuilds)
    // -----------------------------------------------------------------
    Text('Dashboard Footer'), // ✅ 0 rebuilds (even WITHOUT const!)
  ],
)
```

#### 🔍 Rebuild Breakdown: Exactly What Rebuilds vs What Does NOT Rebuild

| State Mutation Event | `graft.slots` Parent & Other Slots (`Text`, `Container`) | `HeavyPaintContainer` (Above Boundary) | Inside `GraftBoundary` (`Row`, `Text`) |
| :--- | :---: | :---: | :---: |
| **`userGraft.state..name = 'Bob'..update()`** | **0 Rebuilds** (all other slots untouched) | **0 Rebuilds** (completely insulated) | 🔄 **1 Rebuild** (only the subtree inside boundary updates) |
| **`themeGraft.state..accentColor = red..update()`** | **0 Rebuilds** (all other slots untouched) | **0 Rebuilds** (completely insulated) | 🔄 **1 Rebuild** (boundary updates theme text) |
| **`userGraft.state..email = 'new'..update()`** *(Unused field!)* | **0 Rebuilds** | **0 Rebuilds** | **0 Rebuilds** (**Backward Adaptive Learning** detects boundary never accessed `email`) |
| **`s..title = 'Analytics'..update()`** | 🔄 **Slot 1 (`Container`) Rebuilds**; Slots 0, 2, 3 have **0 rebuilds** | **0 Rebuilds** | **0 Rebuilds** (`GraftBoundary` is untouched) |

#### 🛡️ Feature Deep Dive: Downward Rebuild Insulation

In standard state management approaches (Provider, Riverpod, BLoC), reading state inside a widget often causes intermediate parent containers to re-execute their `build()` methods. `GraftBoundary` eliminates this by anchoring rebuilds strictly at the Flutter Element level:

```text
graft.slots Element (DashboardGraft)
  ├── Slot 0 Element: Text('Dashboard Header')        ──> 0 Rebuilds
  ├── Slot 1 Element: Container(Text('Section: ...')) ──> Rebuilds only when s.title changes
  ├── Slot 2 Element: HeavyPaintContainer             ──> 0 REBUILDS (PERMANENTLY INSULATED!)
  │     └── GraftBoundary Element                     ──> 0 Rebuilds
  │           └── ValueListenableBuilder Element      ──> ONLY THIS SUBTREE REBUILDS!
  │                 └── Row Element
  │                       ├── Text('User: Bob')
  │                       └── Text('Theme: purple')
  └── Slot 3 Element: Text('Dashboard Footer')        ──> 0 Rebuilds
```

1. **Downwards Dirty Propagation:** Flutter elements only rebuild *downwards* into their children—dirtying a child element never marks its parent dirty. When state updates, `GraftBoundary` triggers an internal `ValueListenableBuilder`. `HeavyPaintContainer` above it is **never marked dirty**.
2. **0 Re-Paints & 0 Re-Layouts:** Because `HeavyPaintContainer`'s element is never dirtied, Flutter's render pipeline skips re-painting or re-layout for heavy outer shells.
3. **Parent Slot Immunity:** When the parent `dashboardGraft` updates, `graft.slots` checks equivalence. Since `GraftBoundary` implements `GraftEquivalent`, `HeavyPaintContainer` is not replaced, maintaining 0 rebuilds across parent state passes.


### 7. In-Place State Reset: `state.reset()`
Reverts domain state to its initial baseline values or invokes `onReset()`, immediately dispatching a surgical diff update to the UI with 0 GC allocations:
```dart
class CounterState extends GraftState {
  int count = 0;
  @override
  List<Object?> get props => [count];
  @override
  void onReset() => count = 0;
}

// In controller or UI:
state.reset(); // Restores baseline synchronously and notifies UI
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

## 🧪 Test Verification & Quality Assurance

Graft is validated by a comprehensive suite of unit, widget, and hardware benchmark tests checked directly into the repository. Every commit is verified against 100% clean passes and zero static analysis warnings:

```bash
fvm flutter test
# 00:06 +157: All tests passed!
```

```bash
fvm flutter analyze
# No issues found!
```

### 📋 Test Suite Breakdown (157 / 157 Tests Passing)

| Architectural Domain | Test Suite Files | What Is Verified |
| :--- | :--- | :--- |
| **State & Collections** | `test/graft_state_test.dart`<br>`test/collection_mutation_test.dart`<br>`test/graft_mask_test.dart`<br>`test/large_state_bitmask_test.dart` | In-place baseline mutations (`List`, `Set`, `Map`), 64-bit integer bitmasks, unbounded mask growth to 1,000+ fields, and synchronous reset. |
| **Rebuild Firewall & Diff Engine** | `test/bitmask_preflight_test.dart`<br>`test/safe_ast_context_test.dart`<br>`test/depth_n_isolation_test.dart`<br>`test/slot_engine_test.dart`<br>`test/slot_engine_deep_diff_test.dart`<br>`test/multi_field_slot_test.dart`<br>`test/disordering_test.dart`<br>`test/dynamic_branch_test.dart` | 1-cycle bitmask pre-flight bypass, safe AST widget diffing without out-of-band builds, Depth-$N$ parent container insulation, dynamic if/else branching, and multi-field bitmask accumulation. |
| **Auto-Discovery & Tickers** | `test/graft_boundary_test.dart`<br>`test/multi_graft_combinator_test.dart`<br>`test/animation_isolation_test.dart` | Ambient auto-discovery across multiple controllers, backward adaptive learning, 60fps/120fps continuous animation isolation, and ticker lifecycle safety. |
| **Routing & Lifecycle** | `test/graft_route_test.dart`<br>`test/graft_route_extended_test.dart`<br>`test/nested_route_isolation_test.dart`<br>`test/lifecycle_test.dart` | `context.use<T>()` route-stack borrowing, parallel navigator isolation (bottom navigation tabs & GoRouter `StatefulShellRoute`), and automatic leak-free disposal on `route.popped`. |
| **Async Concurrency** | `test/async_concurrency_race_test.dart`<br>`test/coalescing_test.dart` | Internal task token guard (`_currentAsyncTaskId`), automatic dropping of out-of-order stale responses, and synchronous microtask reentrancy coalescing. |
| **Benchmarks & Tooling** | `test/zero_allocation_benchmark_test.dart`<br>`test/benchmark/column_rebuild_benchmark_test.dart`<br>`test/large_list_benchmark_test.dart`<br>`test/graft_test_utils_test.dart`<br>`test/graft_observer_test.dart` | Sub-microsecond diff passes, 90.0% rebuild reduction in columns, 10,000-item virtualized list surgical diffing, and pure Dart `graftTest` harness. |

---

## 📄 License

MIT License. Free to use, modify, and distribute.
