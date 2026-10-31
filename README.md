# Graft 🌱

**Graft is a self-optimizing state management engine for Flutter: combining BLoC-style domain models, Signals-level micro-rebuild precision, and register-level CPU bitmask diffing — with strictly zero code generation.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![graft_lint](https://img.shields.io/pub/v/graft_lint.svg?label=graft_lint&color=blue)](https://pub.dev/packages/graft_lint)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![tests](https://img.shields.io/badge/tests-304%20passed-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!NOTE]
> ### 🚀 Graft v1.0.0-alpha.7 — Public Alpha Release
> Graft is currently in active public alpha across iOS, Android, Web (JS & WASM), macOS, Windows, Linux, and Embedded targets.
> We invite developers to take it for a spin, test its slot diffing, DI engine, and Frame-0 persistence across diverse architectures, and help us discover edge cases, ideas, and feedback on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) as we march toward 1.0!

---

## 📚 Dedicated Technical Guides & Documentation Hub

For deep dives into specific subsystems, architecture philosophy, empirical benchmarks, and test matrices:
- 🚀 **[graft_template](https://github.com/kmmuzahid/graft_template):** Official production-ready starter template integrating **Graft** with **CoreKit** (`core_kit`), featuring route scoping, Frame-0 dry persistence, responsive UI, Dio HTTP, and dark/light theming.
- 🏛️ **[ARCHITECTURE.md](https://github.com/kmmuzahid/graft/blob/main/ARCHITECTURE.md):** Deep dive into the 7 Core Engineering Pillars, bitmask diffing, native `ComponentElement` slots, monotonic TypeId, DAG teardowns, automated async gates, and dry persistence.
- 💉 **[DI_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md):** Major dedicated guide for the DI engine (developer enum scopes, zero-scope boot, singleton lock, non-blocking async DB/network, route leasing).
- 💾 **[GRAFT_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md):** Major dedicated guide for State Management & Frame-0 Persistence (propsOf, surgical slots, zero-controller forms, Option B GraftModel, Frame-0 dry state).
- 📊 **[BENCHMARK_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** Empirical benchmark methodology, hardware specs, and full logs across all 21 benchmark scenarios.
- 🧪 **[TEST_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Comprehensive test verification report across 304 passing tests.

---

## 📑 Table of Contents
- [📦 Installation & Linter Setup](#-installation--linter-setup)
- [🛠️ Quick Start](#️-quick-start)
- [🏛️ The 7 Core Architectural Pillars](#️-the-7-core-architectural-pillars)
- [📊 Empirical Benchmarks](#-empirical-benchmarks)
- [📚 Complete Public API Reference](#-complete-public-api-reference)
- [📋 Complete Public API Cheat Sheet](#-complete-public-api-cheat-sheet)
- [🏗️ High-Performance Architecture](#️-high-performance-architecture)
- [🧪 Test Verification Summary](#-test-verification--quality-assurance)
- [📄 License](#-license)

---

## 📦 Installation & Linter Setup

### 1. Add Dependencies

Add `graft` along with the official analyzer plugin, **[`graft_lint`](https://pub.dev/packages/graft_lint)**:

```bash
flutter pub add graft
flutter pub add dev:custom_lint dev:graft_lint
```

### 2. Configure `analysis_options.yaml`

Activate the plugin in your root `analysis_options.yaml`. To display 🔴 **red error squiggles** in your IDE whenever `propsOf(...)` is forgotten or slots are illegally nested, configure the rules under `errors`:

```yaml
analyzer:
  plugins:
    - custom_lint
  errors:
    avoid_nested_graft_slot: error       # 🔴 Flags illegal nested slot builders
    prefer_props_in_graft_state: error   # 🔴 Flags GraftState missing propsOf(...)
    require_graft_route_observer: error  # 🔴 Flags MaterialApp missing route observer
```

> [!TIP]
> If squiggles do not appear immediately in your IDE after saving `analysis_options.yaml`:
> - **VS Code**: Press `Cmd + Shift + P` (or `Ctrl + Shift + P`) and select **Dart: Restart Analysis Server**.
> - **Android Studio**: In the bottom **Dart Analysis** window, click the **Restart Dart Analysis Server** icon.

### 3. Verify in Terminal / CI

```bash
dart run custom_lint --fatal-warnings
```

---

## 🛠️ Quick Start

> [!TIP]
> ### 🚀 Official Starter Template with CoreKit
> Want to jump straight into a production setup? Clone **[`graft_template`](https://github.com/kmmuzahid/graft_template)** — the official production template featuring Graft with [CoreKit](https://pub.dev/packages/core_kit), complete with auto-scoped route controllers, Frame-0 dry form persistence, responsive layout scaling, and JWT authentication.

### 1. Define State & Controller
Extend `GraftState` and declare domain properties in `props` using `propsOf(...)`. No `copyWith` or code-gen needed:

```dart
class UserState extends GraftState {
  String name = 'Alice';
  String email = 'alice@example.com';
  int points = 0;

  @override
  GraftProps get props => propsOf(name, email, points);

  @override
  void onReset() {
    name = 'Alice';
    email = 'alice@example.com';
    points = 0;
  }
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  // Option A: Fluent cascade mutation
  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Synchronous 1-cycle bitmask diff & surgical UI dispatch
  }

  // Option B: Functional lambda mutation
  void addPoints(int amount) {
    mutate((s) => s.points += amount);
  }

  void reset() {
    state.reset(); // Restores initial baseline values via onReset() synchronously
  }
}
```

### 2. The Core Innovations: `slot`, `slots`, `builder`, & `GraftBoundary`

Graft eliminates wasteful Flutter subtree rebuilds using 4 dedicated UI primitives:

#### A. Single-Child Leaf Slot (`graft.slot` or callable `graft(...)`)
Isolates individual dynamic widgets with **Depth-$N$ parent rebuild insulation**. Outer containers (`Card`, `Padding`, `AppBar`) experience **0 rebuilds**:

```dart
// The Card, Padding, and outer layout NEVER rebuild!
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: graft((s) => Text('Points: ${s.points}')), // 🔄 Rebuilds ONLY when points change
  ),
)
```

#### B. Multi-Child Layout Diff Engine (`graft.slots(...)`)
Universal layout diffing (`Column`, `Row`, `Wrap`, `Stack`, `Flex`). Each child becomes an independent diff slot. Unchanged slots, `const` widgets, and conditional branches evaluate with **0 rebuilds**:

```dart
graft.slots(
  layout: Column(crossAxisAlignment: CrossAxisAlignment.start, children: slots),
  slots: (s) => [
    ProfileHeader(), // 0 rebuilds (even though it is not const)
    Text('Name: ${s.name}'), // 0 rebuilds when name is unchanged
    Text('Email: ${s.email}'), // 0 rebuilds when email is unchanged
    if (s.points > 100) const VipBadge(), // Dynamic branch
  ],
)
```

#### C. Virtualized Lazy Lists (`graft.builder(...)`)
100% lazy collections (`ListView.builder`, `GridView.builder`) with per-item slot isolation. Modifying one item triggers **1 rebuild** only for that item, while all other items experience **0 rebuilds**:

```dart
// Zero-plumbing: automatically creates an optimized ListView.builder
graft.builder<TaskItem>(
  items: (s) => s.tasks,
  itemBuilder: (task, index) => ListTile(
    title: Text(task.title),
    trailing: Checkbox(
      value: task.isDone,
      onChanged: (_) => graft.toggleTask(index),
    ),
  ),
)
```

#### D. Multi-Graft Rebuild Firewall (`GraftBoundary`)
An Element-level rebuild barrier with **Ambient Auto-Discovery** and **Backward Adaptive Learning**. 

When placed inside heavy layout containers or inside `graft.slots(...)`, it auto-discovers and listens to multiple controllers simultaneously, completely preventing expensive parent containers and sibling slots from rebuilding:

```dart
dashboardGraft.slots(
  layout: Column(children: slots),
  slots: (s) => [
    const HeaderBanner(), // 0 rebuilds (const pointer match)
    Text('Section: ${s.title}'), // Slot 1: Diffed by dashboardGraft

    // 🛡️ Heavy layout container wrapping a multi-controller GraftBoundary:
    // Parent container and sibling slots do NOT rebuild when inner boundary states update.
    HeavyContainer(
      child: GraftBoundary(
        builder: (context) {
          // Ambiently discovers and listens to userGraft & themeGraft:
          return Row(
            children: [
              Text(userGraft.state.name),
              const SizedBox(width: 8),
              Text(themeGraft.state.accentColor),
            ],
          );
        },
      ),
    ),

    const FooterBanner(), // 0 rebuilds (const pointer match)
  ],
)
```

##### 🔍 Rebuild Breakdown: Why `GraftBoundary` Inside Slots is Essential
Without `GraftBoundary`, updating `userGraft` or `themeGraft` inside a complex slot would force the surrounding container or parent layout to rebuild. With `GraftBoundary`:

| State Mutation Event | `HeavyContainer` (Above Boundary) | Sibling Slots (`s.title`, Header, Footer) | Inside `GraftBoundary` (`Row`) |
| :--- | :---: | :---: | :---: |
| `userGraft.state..name = 'Bob'..update()` | **0 Rebuilds** (Insulated) | **0 Rebuilds** (Diff engine bypass) | 🔄 **1 Rebuild** |
| `themeGraft.state..accentColor = 'red'..update()` | **0 Rebuilds** (Insulated) | **0 Rebuilds** (Diff engine bypass) | 🔄 **1 Rebuild** |
| `dashboardGraft.state..title = 'Reports'..update()` | **0 Rebuilds** (`GraftEquivalent`) | 🔄 **1 Rebuild** (`s.title` slot only) | **0 Rebuilds** |
| `userGraft.state..email = 'new'..update()` *(Unused)* | **0 Rebuilds** | **0 Rebuilds** | **0 Rebuilds** (Adaptive bypass) |

---

### 3. Route-Stack Lifecycle & Zero-Setup Injection (`context.use`)
Attach `GraftRouteTracker.observer` to your `MaterialApp` in `main.dart`, and borrow controllers on-demand anywhere in your widget tree:

```dart
void main() {
  Graft.observer = GraftDevObserver(logRebuilds: true); // Colorized terminal logs
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [GraftRouteTracker.observer], // or GraftRouteObserver()
      home: const UserScreen(),
    );
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolves or inherits UserGraft across the route stack with zero boilerplate:
    final graft = context.use(UserGraft.new);

    return Scaffold(
      appBar: AppBar(
        title: graft((s) => Text(s.name)), // Surgical leaf title
      ),
      body: graft.slots(
        layout: Column(children: slots),
        slots: (s) => [
          const ProfileHeader(),
          Text('Email: ${s.email}'),
          Text('Points: ${s.points}'),
          ElevatedButton(
            onPressed: () => graft.addPoints(10),
            child: const Text('Add 10 Points'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🏛️ The 7 Core Architectural Pillars

State management in Flutter has historically forced developers to choose between two extremes:
1. **Architectural Cleanliness with Rebuild Overhead:** Clean domain classes (BLoC/Provider) that rebuild entire widget subtrees unless wrapped in dozens of verbose `BlocSelector` or `Selector` widgets.
2. **Rebuild Precision with Domain Fragmentation:** Fine-grained reactivity (Signals/GetX/MobX) that shatters cohesive domain models into fragmented primitive wrappers (`signal()`, `.obs`, `.value`, `rx`), cluttering business logic and polluting UI code.

Graft rejects this compromise through 7 foundational architectural pillars:

1. **Zero-Wrapper Domain State:** State models are pure Dart classes extending `GraftState`. No `Signal<T>`, no `.obs`, no `.value`, and strictly zero code generation (`build_runner` is never required).
2. **Mandatory `props` & Recursive Snapshot Contract:** Domain properties are declared via `GraftProps get props => propsOf(...)`, an abstract compiler-enforced contract. Graft uses recursive deep snapshotting for nested `GraftState` sub-states and collections, eliminating forgotten fields and ensuring 100% snapshot integrity during in-place cascade mutations.
3. **Unbounded Hardware-Aligned `GraftMask`:** State field modifications are mapped into an unbounded, 32-bit chunked word-based bitset (`GraftMask`). It diffs ≤ 64 fields in CPU registers in $< 50\text{ ns}$ and effortlessly scales to 128, 500, or 1,000+ fields with 100% web JS compatibility and 0 GC heap allocations.
4. **Synchronous In-Place Cascade Mutation & In-Place Reset:** Direct synchronous updates via `state..field = val..update()` and complete baseline resets via `state.reset()`. Primitives, nested models, and collection items are accurately diffed without requiring immutable `copyWith` methods.
5. **Native `ComponentElement` Slots & Surgical Rebuild Firewall:**
   - **`graft((s) => ...)` / `graft.slot(...)`**: Fine-grained surgical leaf slot subclassing Flutter's native `ComponentElement` directly with zero `ValueNotifier` wrappers and direct C-level pointer dispatch (`GraftFastReceiver`). Features Depth-$N$ parent rebuild insulation and runs inside `NoSubscriptionContext` to prevent `Theme`/`MediaQuery` subscription bleeding.
   - **`graft.slots(...)`**: Universal multi-child layout slot diffing (`Column`, `Row`, `Wrap`, `Flex`) with Level-0 `_commonIgnoredMask` pre-flight bypass and self-optimizing learned `_ignoredMask`.
   - **`GraftBoundary`**: Subtree-level rebuild barrier featuring **Ambient Auto-Discovery** (zero manual lists via `GraftScopeTracker`) and **Backward Adaptive Learning** with multi-field bitwise union accumulation.
6. **Frame-0 Dry State & Coalescing Background Persistence:** Synchronous L1 RAM cache restores persistent states in $< 50\text{ ns}$ on Frame 0 before initial paint, eliminating blank frames and flash. Zero-controller forms bind directly to restored state, while disk writes coalesce into a 300ms debounced queue.
7. **Ref-Counted Ambient Engine (Zero-Wrapper Architecture):** 100% wrapper-free state management. No `GraftScope` or `MultiProvider` widgets. `context.use<T>()` borrows ambient instances across navigation flows with App-Root permanent auto-promotion (`route == null`), while `context.create<T>()` provides isolated route ownership. Disposes via topological reverse DAG teardown with tombstone-deferred exit transition safety.

---

## 📊 Empirical Benchmarks

Graft is empirically evaluated against the primary Flutter state management frameworks (**Riverpod**, **flutter_bloc / Cubit**, **signals_flutter**, **GetX**, and **Provider**) across 21 rigorous benchmark scenarios spanning micro-mutations, high-density layouts, 20k virtualized lists, reactive DAGs, and navigation lifecycles on both Native IO (macOS/ARM64) and Web (Chromium/WASM).

> 📊 **Full Benchmark Report & Methodology:**  
> For the complete statistical breakdown (Mean, Median, p95, Min, Max, StdDev, Rebuild Containment, Glitch Elimination, and GC Object Churn), consult the dedicated benchmark document:  
> 👉 **[`BENCHMARK_REPORT.md`](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md)**

---

## 📚 Complete Public API Reference

Graft exposes a focused, cohesive API surface designed to remain orthogonal to Flutter's native layout engine.

---

### A. Reactive Slots & Rebuild Boundaries (The Core Innovations)

Extension methods on `Graft<S>` and isolated boundary widgets that eliminate unnecessary Flutter renders:

#### 1. `graft((s) => Widget)` (Callable Shortcut) & `graft.slot(...)`
The signature entry point for fine-grained leaf reactions. Provides **Depth-$N$ parent rebuild insulation**:

```dart
// The outer Card and Padding NEVER rebuild:
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: graft((s) => Text('Balance: \$${s.balance}')),
  ),
)
```

Or use explicit named syntax:
```dart
AppBar(
  title: graft.slot(
    builder: (s) => Text(s.title),
  ),
)
```

#### 2. `graft.slots({required layout, required slots})`
The universal multi-child slot diffing engine. Evaluates child widgets against learned `fieldDependenciesMask` and `ignoredMask`, bypassing unchanged slots with 0 element rebuilds:

```dart
graft.slots(
  layout: Column(children: slots),
  slots: (s) => [
    const HeaderBanner(), // 0 rebuilds (const pointer match)
    Text('Name: ${s.name}'), // 0 rebuilds when name is unchanged
    Text('Email: ${s.email}'), // 0 rebuilds when email is unchanged
    if (s.isVerified) const VerifiedBadge(),
  ],
)
```

#### 3. `GraftBoundary({required builder, key})`
An Element-level rebuild firewall that isolates multi-controller subscriptions.

* **Ambient Auto-Discovery**: Automatically discovers and subscribes to any `Graft` controller whose `.state` is read within `builder`—no manual listener registration required.
* **Backward Adaptive Learning**: Traps state mutations within the boundary. When inner controllers update, outer containers, parent widgets, and sibling slots experience **0 rebuilds**.
* **Zero Subscription Bleed**: Evaluates through `NoSubscriptionContext` to prevent ambient `Theme` or `MediaQuery` subscriptions from leaking into parent layouts.

```dart
// Isolates multiple controllers inside any subtree without parent rebuilds:
GraftBoundary(
  builder: (context) {
    // Ambiently discovers and listens to userGraft & themeGraft:
    return Row(
      children: [
        Text(userGraft.state.name),
        const SizedBox(width: 8),
        Icon(Icons.circle, color: themeGraft.state.accentColor),
      ],
    );
  },
)
```

#### 4. `graft.compute<R>({required compute, required builder, key})`
Pre-flight derived selector computation. Checks the computed value before executing `builder`:

```dart
graft.compute<int>(
  compute: (s) => s.unreadMessages.length,
  builder: (unreadCount) => Badge(
    label: Text('$unreadCount'),
    child: const Icon(Icons.mail),
  ),
)
```

#### 5. `graft.builder<T>({required items, required itemBuilder, layout, key})`
Virtualized lazy collections with per-item slot isolation (`ListView.builder`, `GridView.builder`):

```dart
graft.builder<TaskItem>(
  items: (s) => s.tasks,
  itemBuilder: (task, index) => TaskListTile(task: task),
)
```

#### 6. `graft.async<T>({required selector, required data, required loading, required error, idle, key})`
Declarative, pattern-matched reactive slot for asynchronous domain states:

```dart
graft.async<UserProfile>(
  selector: (s) => s.profileState,
  data: (profile) => ProfileCard(profile),
  loading: () => const ShimmerCard(),
  error: (err, st) => ErrorBanner(error: err),
  idle: () => const PlaceholderCard(),
)
```

#### 7. Zero-Wrapper Ambient Lifecycle (`context.use` vs `context.create`)
100% wrapper-free state management across screens, tabs, and modals:

- **`context.use<T>([factory, key])`**: Borrows an existing ambient instance across the navigation flow, or creates one if absent. Automatically promoted to an app-wide permanent singleton when called at the App Root (`route == null`). Auto-disposes when all borrower screens pop.
- **`context.create<T>([factory, key])`**: Always forces a brand-new, isolated instance owned exclusively by the current screen.
- **Parameterized Keys (`key: id`)**: Supports entity-specific controller instances (e.g. `context.use(() => ProductGraft(id), key: id)`).
- **Multi-Controller Resolution**: Ergonomic Dart 3 record unpacking via `final (user, cart) = context.use2(UserGraft.new, CartGraft.new);` and `context.use3(...)`.

```dart
// Shared across the flow:
final checkout = context.use(CheckoutGraft.new);

// Parameterized by entity ID:
final product = context.use(() => ProductGraft(productId), key: productId);

// Isolated to this screen only:
final form = context.create(TempFormGraft.new);
```

#### 8. `GraftEquivalent`
Interface allowing custom widgets to declare fine-grained content equivalence without triggering `@nonVirtual` operator warnings:

```dart
class UserAvatar extends StatelessWidget implements GraftEquivalent {
  final String url;
  const UserAvatar(this.url);

  @override
  bool isEquivalentTo(Widget other) => other is UserAvatar && other.url == url;

  @override
  Widget build(BuildContext context) => Image.network(url);
}
```

---

### B. Domain State & Business Logic Controllers

#### 1. `GraftState`
The base class for domain models. Enables direct cascade mutations without immutable `copyWith` methods:

```dart
class CartState extends GraftState {
  final List<String> items = [];
  double discount = 0.0;

  @override
  GraftProps get props => propsOf(items, discount);

  @override
  void onReset() {
    items.clear();
    discount = 0.0;
  }
}
```

* **`GraftProps get props`**: Mandatory abstract contract declaring properties for diffing via `propsOf(...)` or `propsOfMany(...)`.
* **`state.update()`**: Computes dirty bitmask against in-place baseline snapshot and triggers UI notification.
* **`state.reset()`**: Calls `onReset()` and flushes baseline changes synchronously with 0 GC allocations.
* **`GraftMask get dirtyMask`**: Read-only bitmask from the last diff evaluation.

#### 2. `Graft<S extends GraftState>`
The business logic controller managing domain state of type `S`:

```dart
class CartGraft extends Graft<CartState> {
  CartGraft() : super(CartState());

  void addItem(String item) {
    state
      ..items.add(item)
      ..update();
  }

  Future<void> checkout() async {
    await runAsync<OrderConfirmation>(
      task: () => api.checkout(state.items),
      onUpdate: (asyncState) => state..confirmation = asyncState..update(),
    );
  }
}
```

* **`S get state`**: The current state snapshot. Automatically records dependency inside `GraftBoundary`.
* **`ValueListenable<S> get listenable`**: Direct interop with standard Flutter `ValueListenableBuilder`.
* **`Future<T?> runAsync<T>({required task, required onUpdate})`**: Executes an asynchronous task with an internal monotonically increasing task token guard that **automatically discards out-of-order stale responses**.
* **`void addError(Object error, [StackTrace? stackTrace])`**: Dispatches unhandled errors to `GraftObserver`.
* **`void reset()`**: Resets state and flushes baseline synchronously.
* **`void dispose()`**: Releases listeners and notifies global observer.

#### 3. `ValueGraft<T>`
Specialized lightweight controller for single primitive or enum values without writing a state class:

```dart
class CounterGraft extends ValueGraft<int> {
  CounterGraft() : super(0);

  void increment() => value++;
  void decrement() => value--;
}

class ThemeGraft extends ValueGraft<ThemeMode> {
  ThemeGraft() : super(ThemeMode.system);

  void toggleDark() => value = ThemeMode.dark;
}
```

* **`T get value`** / **`set value(T newValue)`**: Direct read/write property. Mutating triggers slot updates.

#### 4. `GraftAsync<T>`
Sealed algebraic data type representing asynchronous lifecycles:

```dart
// Sealed constructors:
const GraftAsync<User>.idle()
const GraftAsync<User>.loading()
const GraftAsync<User>.data(User user)
const GraftAsync<User>.error(Object error, [StackTrace? stackTrace])

// Pattern-matching with .when():
asyncValue.when(
  idle: () => const Text('Press to load'),
  loading: () => const CircularProgressIndicator(),
  data: (user) => Text('Hello, ${user.name}'),
  error: (err, st) => Text('Error: $err'),
);
```

* **Properties**: `isIdle`, `isLoading`, `hasData`, `hasError`, `dataOrNull`, `errorOrNull`.

---

### C. Dependency Injection & Scope Management

> 📘 For the comprehensive DI deep dive, see **[`DI_GUIDE.md`](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md)**.

#### 1. `bind<T>()` & `bindAsync<T>()`
Registers synchronous and non-blocking asynchronous dependencies into the active scope:
```dart
// Singleton by default (cached in scope, instantiated on first access)
bind<ApiClient>(() => ApiClient(baseUrl: 'https://api.example.com'));

// Non-blocking async: Frame-0 safe, auto-awaits without blocking app startup
bindAsync<Database>(() async => await openDatabase('app.db'));
```

#### 2. `use<T>()` & `useAsync<T>()`
Resolves dependencies ambiently with $< 0.8\text{ ns}$ hot lookup:
```dart
final client = use<ApiClient>();
final db = await useAsync<Database>(); // Self-healing Frame-0 gate!
```

#### 3. `scope(Enum, () { ... })` & `Enum.drop()`
Declaratively binds dependencies to developer-defined enums, and drops them in reverse topological DAG order:
```dart
enum AppScope { auth, checkout }

scope(AppScope.checkout, () {
  bind<CartRepo>(() => CartRepo());
  bind<CheckoutCoordinator>(() => CheckoutCoordinator(use<CartRepo>()));
});

// Drop flow-wide on order completion:
AppScope.checkout.drop(); // Disposes CheckoutCoordinator THEN CartRepo!
```

#### 4. `context.use<T extends Graft>([factory])`
Resolves an active controller across the navigation stack, or creates one if not found:
* **Route Stack Sharing**: Borrows existing instance from ancestor routes.
* **Automatic Route Disposal**: The screen that initializes a controller owns its lifecycle and auto-disposes it when the route pops.
* **Transient PopupRoute Protection**: Dialogs and sheets borrow safely without killing host controllers.

```dart
class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Borrows existing ProfileGraft from HomeScreen in route stack:
    final graft = context.use(ProfileGraft.new);
    return Scaffold(...);
  }
}
```

---

### D. Observability & DevTools

#### 1. `GraftDevObserver` & `GraftObserver`
`Graft` features a centralized observability engine for monitoring state transitions, DI scope lifecycles, Frame-0 Dry persistence, slot rebuilds, and Flutter DevTools Timeline profiling:

```dart
void main() {
  if (kDebugMode) {
    Graft.observer = GraftDevObserver(
      logDI: true,          // 📦 DI scope creation & member teardown (default: true)
      logDry: true,         // 💾 Dry state badges, hydration & invalidation (default: true)
      logState: false,      // 🌱 State creation & disposal (default: false)
      logChanges: false,    // ⚡ State change transitions & diffs (default: false)
      logBindings: false,   // 🔗 Individual dependency registrations (default: false)
      logRebuilds: false,   // 🔄 Fine-grained slot widget rebuilds (default: false)
      logErrors: true,      // 💥 Unhandled errors and stack traces (default: true)
      asyncLog: true,       // ⚡ Non-blocking async queue (zero frame budget impact) (default: true)
      enableTimeline: false // ⏱️ Flutter DevTools Performance Timeline slices (default: false)
    );
  }

  runApp(const MyApp());
}
```

#### 2. Smart Visual Terminal Telemetry

##### 📦 DI Scopes & Active Member Teardown
Logs scope creation with lifecycle tier (transient vs preserved), and inspects which active concrete dependency instances were living inside that scope upon disposal:

```text
[📦 GRAFT DI SCOPE CREATED] | AppScope.signup (transient)

[💥 GRAFT DI SCOPE DESTROYED] | AppScope.signup
   Disposed Members (2):
  • AuthService
  • SignupGraft
```

##### 💾 Frame-0 Dry Persistence Badges
Any state utilizing Frame-0 dry persistence is automatically badged across creation, transition, and disposal:

```text
[🌱 GRAFT CREATED] | SignupGraft 💾 [DRY: signup_draft]

[⚡ GRAFT CHANGE] | SignupGraft 💾 [DRY: signup_draft]
  SignupState(name: "", email: "")
  ➡️ SignupState(name: "Alice", email: "alice@example.com")

[🗑️ GRAFT DISPOSED] | SignupGraft 💾 [DRY: signup_draft]
```

##### ❄️ Frame-0 Dry Hydration & Invalidation
Logs synchronous L1 RAM cache restorations (< 50ns) and tracks state or scope prefix invalidations:

```text
[❄️ GRAFT DRY HYDRATED] | SignupState 💾 [key: signup_draft] | restored from L1 RAM in <50ns

[🧹 GRAFT DRY INVALIDATED] | SignupState 💾 [key: signup_draft] | persistence cleared for session

[🧹 GRAFT DRY SCOPE PURGED] | AppScope.signup 💾 [prefix: signup] | L1 RAM & disk cache cleared
```

#### 3. Non-Blocking Asynchronous Microtask Queue
Console writes and system log daemon calls (OSLog/Logcat) can consume valuable milliseconds during rapid state bursts or animations. When `asyncLog: true` (default):
* Log events are queued in-memory in **< 5 nanoseconds** ($O(1)$ list push).
* State mutations and widget rebuilds return **immediately with zero delay**.
* Queued logs are flushed asynchronously in a microtask, preserving 60/120fps frame budgets.

#### 4. Production Telemetry & Custom Observers
Implement `GraftObserver` for production diagnostics (Sentry, Firebase Crashlytics, Datadog):

```dart
class ProductionObserver extends GraftObserver {
  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  @override
  void onScopeDropped(Object scopeId, {List<Type> members = const [], List<Type> registeredTypes = const []}) {
    // Track DI graph health and memory reclamation
  }
}
```

* **Zero Release Overhead**: `GraftDevObserver` completely bypasses console I/O and timeline emission in release mode (`kReleaseMode`).
* **DevTools Performance Trace**: When `enableTimeline: true`, every transition (`Graft: MyGraft.update()`), DI event, and slot rebuild appears as an inspectable slice in Flutter DevTools.

---

### E. Declarative Unit Testing (`graft/testing.dart`)

#### 1. `graftTest`
Pure Dart declarative state testing modeled after `blocTest`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

void main() {
  group('UserGraft', () {
    graftTest<UserGraft, UserState>(
      'updates profile name and notifies listeners',
      build: () => UserGraft(),
      act: (graft) => graft.updateName('Alice'),
      expect: () => [
        isA<UserState>().having((s) => s.name, 'name', 'Alice'),
      ],
      verify: (graft) {
        expect(graft.state.name, 'Alice');
      },
    );
  });
}
```

---

### F. Frame-0 Dry State Persistence & Cascaded Models

> 💾 For the comprehensive state and persistence deep dive, see **[`GRAFT_GUIDE.md`](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md)**.

> [!NOTE]
> ### 💡 Frame-0 Dry Persistence Architecture (Alpha)
> Graft features zero-magic-string, constructor-driven persistence. States declare constructor parameters with defaults once, override `schemaVersion => 1`, and instantiate via `super.dry(State.new)`. Restorations complete from L1 RAM in $< 50\text{ ns}$ on Frame 0 before initial paint!

#### 1. Ultra-Clean Constructor Hydration (`super.dry(State.new)`)
Zero `onDry()`, zero manual index casting, and zero magic strings. Declare constructor defaults once, provide `@override int get schemaVersion => 1;`, and pass the constructor tear-off:
```dart
class FormState extends GraftState {
  @override
  int get schemaVersion => 1;

  String notes;
  bool isSubmitting; // Transient UI field: starts fresh on launch!

  FormState([
    this.notes = 'Initial note',
    this.isSubmitting = false,
  ]);

  @override
  GraftProps get props => propsOf(notes, isSubmitting);
}

class FormGraft extends Graft<FormState> {
  // ⚡ Directly hydrates from binary L1 RAM on Frame 0 into constructor arguments!
  FormGraft() : super.dry(FormState.new);
}
```

#### 2. Ultra-Clean Cascaded Sub-Models (`GraftModel`)
Cascaded domain sub-models with plain mutable fields, `propsOf`, and a 1-line constructor tear-off (`factory => Model.new`). Sub-models are restored automatically with zero index casting:
```dart
class AddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String street;
  String city;

  AddressModel([this.street = '', this.city = '']);

  @override
  GraftProps get props => propsOf(street, city);

  @override
  Function get factory => AddressModel.new; // ✨ 1-line constructor tear-off!
}
```

#### 3. Two-Tier Contract Enforcement (Static Lints & Runtime Guards)
To guarantee 100% deterministic persistence and safe schema evolutions across app restarts:
- **Static Analysis (`graft_lint`)**: The `RequireDryContractsRule` analyzer rule automatically flags any class used with `super.dry` lacking `schemaVersion`, or any nested model lacking `factory`.
- **Runtime Guard**: Throws a fail-fast, actionable `StateError` on launch if contracts are missing.

#### 4. Controller Lifecycle Hooks (`onInit()` & `onDispose()`)
`onInit()` runs immediately after Frame-0 hydration:
```dart
class FormGraft extends Graft<FormState> {
  FormGraft() : super.dry(FormState.new);
  final controller = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    controller.text = state.notes; // Restored on Frame 0!
  }

  @override
  void onDispose() {
    controller.dispose();
    super.onDispose();
  }
}
```

#### 5. Micro-State Persistence (`ValueGraft.dry`)
Standalone persistent micro-state with zero boilerplate:
```dart
final theme = ValueGraft<String>.dry('dark', key: 'app_theme');
theme.value = 'light'; // Synchronous L1 save + debounced disk write!
```

#### 6. Purging Dry State (`invalidateDry`)
Purges dry state from L1 RAM, cancels pending writes, and deletes from storage:
```dart
// State-level purge:
graft.invalidateDry();

// Scope-level (flow-wide) purge:
AppScope.checkout.invalidateDry();
```

#### 7. Permanent Storage Configuration & Abstraction (`configurePersistence`)
By default, Graft operates in RAM via an internal `MemoryStateConfig()`. To persist state permanently across app restarts, configure a storage driver in `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Option A: Built-in binary file driver (.bin)
  final dir = await getApplicationDocumentsDirectory();
  configurePersistence(FileStateConfig(dir));

  // Option B: Or implement a custom GraftStateConfig (e.g. SharedPreferences):
  // final prefs = await SharedPreferences.getInstance();
  // configurePersistence(SharedPrefsStateConfig(prefs));

  runApp(const MyApp());
}
```

---

## 📋 Complete Public API Cheat Sheet

Every public API in Graft listed with a practical 2–3 line usage example:

### 🧩 1. Core State & Domain Models
```dart
// 1. GraftState: Base domain state with propsOf contract
class UserState extends GraftState {
  String name = '';
  @override
  GraftProps get props => propsOf(name);
}

// 2. propsOf: Declares tracked domain properties for diffing & persistence
@override
GraftProps get props => propsOf(name, email, age);

// 3. state.update(): Synchronous in-place cascade mutation & leaf dispatch
state..name = 'Alice'..age = 25..update();

// 4. state.reset(): Restores initial domain values via onReset()
state.reset();

// 5. GraftModel: Cascaded mutable sub-model with auto-hydration tear-off
class AddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;
  String street;
  AddressModel([this.street = '']);
  @override
  GraftProps get props => propsOf(street);
  @override
  Function get factory => AddressModel.new;
}
```

### 🎮 2. Controllers & Lifecycles
```dart
// 6. Graft<S>: Business logic controller
class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());
}

// 7. Graft.init(): Optional main() bootstrap for custom persistence / setup
Graft.init(config: FileStateConfig(dir), setup: () => bind<Api>(() => Api()));

// 8. graft.mutate(): Functional lambda mutation with automatic update
graft.mutate((s) => s.points += 10);

// 9. onInit(): Lifecycle hook executed after Frame-0 hydration
@override
void onInit() => myController.text = state.name;

// 10. onDispose(): Lifecycle hook executed when controller unmounts
@override
void onDispose() => myController.dispose();

// 11. ValueGraft<T>: Lightweight controller for single values
final count = ValueGraft<int>(0);
count.value++;

// 12. GraftAsync<T>: Algebraic asynchronous state container
state.user = const GraftAsync.loading();
state.user = GraftAsync.data(loadedUser);
```

### 🎯 3. UI Slots & Layouts
```dart
// 13. graft((s) => ...): Signature callable leaf slot (0 parent rebuilds)
graft((s) => Text(s.name))

// 14. graft.slot(): Named isolated leaf slot
graft.slot((s) => Text(s.name))

// 15. graft.slots(): Multi-child layout diffing engine (Column, Row, Wrap)
graft.slots(layout: Column(children: slots), slots: (s) => [Text(s.name), Text(s.email)])

// 16. graft.builder(): Virtualized lazy list with per-item slot isolation
graft.builder(items: (s) => s.items, itemBuilder: (item, idx) => ItemTile(item))

// 17. graft.async(): Declarative async pattern-matching slot
graft.async(selector: (s) => s.user, data: (u) => Text(u.name), loading: () => Spinner(), error: (e, s) => Text('Err'))

// 18. GraftBoundary: Multi-controller rebuild barrier with auto-discovery
GraftBoundary(builder: (context) => Row(children: [Text(u.state.name), Text(t.state.theme)]))

// 19. context.create<T>(): Isolated controller owned exclusively by current route
final form = context.create(TempFormGraft.new);
```

### 💉 4. Dependency Injection Engine
```dart
// 20. bind<T>(): Synchronous dependency factory (singleton by default)
bind<ApiClient>(() => ApiClient());

// 21. bindAsync<T>(): Non-blocking async dependency (Frame-0 safe)
bindAsync<Database>(() async => await openDatabase('app.db'));

// 22. use<T>(): Ambient dependency lookup (< 0.8 ns hot lookup)
final api = use<ApiClient>();

// 23. useAsync<T>(): Self-healing Frame-0 async lookup
final db = await useAsync<Database>();

// 24. scope(Enum, () { ... }): Declarative enum scope block
scope(AppScope.checkout, () => bind<CartRepo>(() => CartRepo()));

// 25. context.use(): Borrow or create route-inherited controller in build()
final graft = context.use(UserGraft.new);

// 26. Enum.drop(): Drops scope and disposes in reverse topological DAG order
AppScope.checkout.drop();

// 27. GraftDI.withOverrides(): Zone-isolated mock overrides for unit testing
await GraftDI.withOverrides(overrides: {TypeId.of<Api>(): () => MockApi()}, body: () async {});

// 28. GraftDI.reset(): Complete teardown and reset of ambient DI hierarchy
GraftDI.reset();
```

### 💾 5. Frame-0 Persistence & Dry State
```dart
// 29. super.dry(State.new): Automatically hydrates state on Frame 0 into constructor arguments
class UserGraft extends Graft<UserState> {
  UserGraft() : super.dry(UserState.new);
}

// 30. schemaVersion: Mandatory version contract for deterministic persistence and safe evolution
@override
int get schemaVersion => 1;

// 31. factory: 1-line constructor tear-off for auto-hydrating nested GraftModels
@override
Function get factory => AddressModel.new;

// 32. dryKey: Optional storage key (defaults to class name runtimeType.toString())
@override
String get dryKey => 'user_profile';

// 33. graft.invalidateDry(): Purges controller's persisted dry cache
graft.invalidateDry();

// 34. Enum.invalidateDry(): Purges all dry caches across entire flow
AppScope.checkout.invalidateDry();

// 35. ValueGraft.dry(): Persistent micro-state on Frame 0
final count = ValueGraft<int>.dry(0, key: 'counter');

// 36. FileStateConfig: High-performance binary file driver (.bin) for production
configurePersistence(FileStateConfig(Directory('path/to/storage')));

// 37. MemoryStateConfig: In-memory binary driver for unit tests
configurePersistence(MemoryStateConfig());

// 38. GraftLifecycleObserver: Automatic debounced write flushing on app background/pause
GraftLifecycleObserver.instance.attach();
```

---

## 🏗️ High-Performance Architecture

Graft achieves sub-microsecond diffing, zero wasted rebuilds, and a 100% wrapper-free developer experience by decoupling state evaluation from Flutter's widget tree lifecycle.

### The 7 Core Architectural Pillars:
1. **Hardware-Aligned Bitmask Diffing**: Native cascade mutations evaluated across 64-bit SIMD integer words directly in CPU registers in $< 50\text{ ns}$ with 0 heap allocations.
2. **Surgical Leaf Slot Isolation**: Direct C-level Element pointer dispatch (`ChildSlotEngine`) marks only specific leaf elements dirty, insulating layout parents in 0 rebuilds.
3. **Monotonic Integer Type Identification (`TypeId`)**: Direct index array lookup ($\le 12\text{ ns}$ cold, $< 0.8\text{ ns}$ hot) bypassing runtime string hashing.
4. **In-Degree Topological Reverse DAG Teardown**: Dynamic dependency recording guarantees consumers dispose before base dependencies with zero cycle hazards.
5. **Self-Healing Non-Blocking Async Gate**: `bindAsync<T>()` and `useAsync<T>()` prevent boot delays and eliminate manual service wrappers.
6. **Frame-0 Dry State & Coalescing Persistence**: Synchronous L1 RAM cache eliminates blank-frame flicker, while disk writes coalesce into a 300ms debounced queue.
7. **Ref-Counted Ambient Engine**: 100% zero-wrapper architecture. `context.use<T>()` borrows ambient instances across navigation flows with App-Root auto-promotion and tombstone-deferred exit transition teardown.

> 📖 **Deep Technical Reference:** For exhaustive mechanical pipeline diagrams, memory layout specifications, and mathematical proofs, consult the [ARCHITECTURE.md](ARCHITECTURE.md) manual.

---

## 🧪 Test Verification & Quality Assurance

> 🧪 For the complete test matrix and verification logs across all 71 test files, see **[`TEST_REPORT.md`](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md)**.

Graft is verified against **304 passing tests** with zero static analysis warnings and zero rebuild leakage:

```bash
flutter test
# 00:45 +304: All tests passed!
```

```bash
flutter analyze
# No issues found!
```

| Domain | Tests | Status | Verification Scope |
| :--- | :---: | :---: | :--- |
| **Core State Engine & Zero-Copy Mutation** | 66 | ✅ Pass | In-place baseline mutations (`List`, `Set`, `Map`), nested `GraftState`, 64-bit bitmasks, resets. |
| **Fine-Grained Slot Engine & Rebuild Firewall** | 70 | ✅ Pass | `ignoredMask` short-circuiting, `NoSubscriptionContext` leak prevention, Depth-$N$ parent rebuild insulation. |
| **Frame-0 Persistence & Dry State** | 51 | ✅ Pass | Sub-microsecond L1 binary hydration (~1.5µs), 15 worst-case permutations, order scrambling, type safety. |
| **Dependency Injection (DI) Engine** | 22 | ✅ Pass | Monotonic `TypeId.of<T>()`, reverse DAG teardown, non-blocking `bindAsync`, real SQLite verification. |
| **Route Isolation & Context Lifecycle** | 20 | ✅ Pass | `context.use<T>()` route-stack borrowing, transient `PopupRoute` protection, auto-disposal. |
| **DevTools, Observers & Diagnosibility** | 18 | ✅ Pass | Multi-controller ambient auto-discovery, colorized terminal output, Flutter timeline profiling. |
| **Empirical Benchmark Integration** | 18 | ✅ Pass | Comparative benchmarks against Riverpod, Bloc, Signals, GetX, and Provider. |
| **Async State & Error Boundaries** | 11 | ✅ Pass | Monotonic task tokens, stale response dropping, declarative `graft.async`. |
| **High-Concurrency & Chaos Stress** | 9 | ✅ Pass | Glitch-free reactive diamond DAG, deep computed chains, 50k item list throughput. |

---

## 📄 License

MIT License. Free to use, modify, and distribute.
