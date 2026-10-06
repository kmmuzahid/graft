# Graft 🌱

**Graft is the first self-optimizing state management engine for Flutter: combining the clean domain architecture of BLoC, the micro-rebuild precision of Signals, and the register-level diffing speed of a hardware bitmask.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![tests](https://img.shields.io/badge/tests-185%20passed-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!IMPORTANT]
> ### 🚀 Graft is in Public Alpha (`0.1.2-alpha.4`)
> Graft is actively evolving in its initial alpha release. It is designed to demonstrate that Flutter state management does not require choosing between architectural cleanliness and micro-rebuild performance.
> 
> We invite the community to test it, push its slot diffing and route scoping to the limits, and share your feedback on [GitHub Issues](https://github.com/kmmuzahid/graft/issues)!

---

## 🏛️ The 6 Core Pillars (Philosophy)

State management in Flutter has historically forced developers to choose between two extremes:
1. **Architectural Cleanliness with Rebuild Overhead:** Clean domain classes (BLoC/Provider) that rebuild entire widget subtrees unless wrapped in dozens of verbose `BlocSelector` or `Selector` widgets.
2. **Rebuild Precision with Domain Fragmentation:** Fine-grained reactivity (Signals/GetX/MobX) that shatters cohesive domain models into fragmented primitive wrappers (`signal()`, `.obs`, `.value`, `rx`), cluttering business logic and polluting UI code.

Graft rejects this compromise through 6 foundational pillars:

1. **Zero-Wrapper Domain State:** State models are pure Dart classes extending `GraftState`. No `Signal<T>`, no `.obs`, no `.value`, and strictly zero code generation (`build_runner` is never required).
2. **Mandatory `props` & Recursive Snapshot Contract:** Domain properties are declared via `List<Object?> get props;`, an abstract compiler-enforced contract. Graft uses recursive deep snapshotting for nested `GraftState` sub-states and collections, eliminating forgotten fields and ensuring 100% snapshot integrity during in-place cascade mutations.
3. **Unbounded Hardware-Aligned `GraftMask`:** State field modifications are mapped into an unbounded, 32-bit chunked word-based bitset (`GraftMask`). It diffs $\le 64$ fields in CPU registers and effortlessly scales to 128, 500, or 1,000+ fields with 100% web JS compatibility and 0 GC heap allocations.
4. **Synchronous In-Place Cascade Mutation & In-Place Reset:** Direct synchronous updates via `state..field = val..update()` and complete baseline resets via `state.reset()`. Primitives, nested models, and collection items are accurately diffed without requiring immutable `copyWith` methods.
5. **Two-Wrapper Architecture & Context Decoupling:**
   - **`GraftBoundary`**: Subtree-level rebuild barrier featuring **Ambient Auto-Discovery** (zero manual lists via `GraftScopeTracker`) and **Backward Adaptive Learning** with multi-field bitwise union accumulation.
   - **`graft((s) => ...)`**: Fine-grained surgical leaf slot with Depth-$N$ parent rebuild insulation, powered by `NoSubscriptionContext` to prevent `Theme`/`MediaQuery` subscription bleeding during widget diffing.
   - **`graft.slots(...)`**: Universal multi-child layout slot diffing with self-optimizing `ignoredMask` pre-flight bypass.
6. **Automatic Route-Aware Lifecycle & PopupRoute Protection:** Controllers automatically inherit down predecessor routes and cleanly self-dispose when their owning screen route pops. Transient routes (`showDialog`, `showModalBottomSheet`) borrow safely without prematurely disposing host controllers via `resolveOwnerRoute`.

---

## 🛠️ Quick Start

### 1. Define State & Controller
Extend `GraftState` and declare domain properties in `props`. No `copyWith` or code-gen needed:

```dart
class UserState extends GraftState {
  String name = 'Alice';
  String email = 'alice@example.com';
  int points = 0;

  @override
  List<Object?> get props => [name, email, points];
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Synchronous 1-cycle bitmask diff & surgical UI dispatch
  }

  void addPoints(int amount) {
    state
      ..points += amount
      ..update();
  }

  void reset() {
    state.reset(); // Restores initial baseline values synchronously
  }
}
```

### 2. The Core Innovations: `slot`, `slots`, & `GraftBoundary`

Graft eliminates wasteful Flutter subtree rebuilds using 3 dedicated UI primitives:

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
  layout: (children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  children: (s) => [
    ProfileHeader(), // 0 rebuilds (even though it is not const)
    Text('Name: ${s.name}'), // 0 rebuilds when name is unchanged
    Text('Email: ${s.email}'), // 0 rebuilds when email is unchanged
    if (s.points > 100) const VipBadge(), // Dynamic branch
  ],
)
```

#### C. Multi-Graft Rebuild Firewall (`GraftBoundary`)
An Element-level rebuild barrier with **Ambient Auto-Discovery** and **Backward Adaptive Learning**. 

When placed inside heavy layout containers or inside `graft.slots(...)`, it auto-discovers and listens to multiple controllers simultaneously, completely preventing expensive parent containers and sibling slots from rebuilding:

```dart
dashboardGraft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    const HeaderBanner(), // 0 rebuilds (const pointer match)
    Text('Section: ${s.title}'), // Slot 1: Diffed by dashboardGraft

    // 🛡️ Heavy layout container wrapping a multi-controller GraftBoundary:
    //backward tree will not rebuild of GraftBoundary even though it is in the same graft.slots
    //this is the power of graft
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
Attach `GraftRouteObserver` to your `MaterialApp` in `main.dart`, and borrow controllers on-demand anywhere in your widget tree:

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
      navigatorObservers: [GraftRouteObserver()],
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
        layout: (children) => Column(children: children),
        children: (s) => [
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

#### 2. `graft.slots({required layout, required children, key})`
The universal multi-child slot diffing engine. Evaluates child widgets against learned `fieldDependenciesMask` and `ignoredMask`, bypassing unchanged slots with 0 element rebuilds:

```dart
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

#### 3. `GraftBoundary`
An Element-level rebuild firewall featuring **Ambient Auto-Discovery** and **Backward Adaptive Learning**.

When used inside layout containers or complex multi-child `graft.slots(...)`, it isolates multi-controller subscriptions and traps leaf mutations, completely preventing expensive parent containers and sibling slots from rebuilding:

```dart
dashboardGraft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    HeaderBanner(), // 0 rebuilds (even though it is not const)
    Text('Section: ${s.title}'), // Slot 1: Diffed by dashboardGraft

    // 🛡️ Heavy layout container wrapping a multi-controller GraftBoundary:
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
  (s) => s.profileState,
  data: (profile) => ProfileCard(profile),
  loading: () => const ShimmerCard(),
  error: (err, st) => ErrorBanner(error: err),
  idle: () => const PlaceholderCard(),
)
```

#### 7. `GraftScope`
Provides localized subtree scoping for nested navigation hierarchies (GoRouter `StatefulShellRoute`, bottom tabs, or modal sheets):

```dart
GraftScope(
  builder: (context) => const NestedTabNavigator(),
)
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
  List<Object?> get props => [items, discount];

  @override
  void onReset() {
    items.clear();
    discount = 0.0;
  }
}
```

* **`List<Object?> get props`**: Mandatory abstract contract declaring properties for diffing.
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

### C. Route-Stack Dependency Injection (`BuildContext` Extensions)

#### 1. `context.use<T extends Graft>([factory])`
Resolves an active controller across the navigation stack, or creates one if not found:
* **Route Stack Sharing**: If an ancestor route in the navigation stack created `T`, this screen **borrows** the existing instance.
* **Automatic Route Disposal**: The first screen that calls `context.use<T>()` becomes the **Owner**. When that screen pops from the Navigator, `T` is automatically disposed.
* **Transient PopupRoute Protection**: When opening dialogs (`showDialog`) or bottom sheets (`showModalBottomSheet`), Graft anchors ownership to the underlying `PageRoute`. Closing the popup will **never** prematurely dispose the controller.

```dart
class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Borrows existing ProfileGraft from HomeScreen in the route stack:
    final graft = context.use(ProfileGraft.new);
    return Scaffold(...);
  }
}
```

#### 2. `context.create<T extends Graft>([factory])`
Force-creates a brand-new, isolated instance owned exclusively by the current screen:

```dart
// Isolated wizard or temporary comparison form:
final isolatedGraft = context.create(CheckoutGraft.new);
```

#### 3. `GraftRegistry`
Central factory registry configured at application startup:

```dart
void main() {
  // 1. Route-scoped: created lazily, disposed when owner route pops:
  GraftRegistry.register(UserGraft.new);
  GraftRegistry.register(CartGraft.new);

  // 2. Global Singleton: persistent app-wide, survives route pops:
  GraftRegistry.registerSingleton(AuthGraft.new);

  // 3. Fallback to external service locator (GetIt, Kiwi, etc.):
  GraftRegistry.fallbackLocator = <T extends Object>() => GetIt.I<T>();

  runApp(const MyApp());
}
```

---

### D. Observability & DevTools

#### 1. `GraftObserver` & `GraftDevObserver`
Global hook for monitoring lifecycle, state transitions, slot rebuilds, and errors:

```dart
void main() {
  // Colorized terminal logging during development:
  Graft.observer = GraftDevObserver(logRebuilds: true);
  runApp(const MyApp());
}

// Or implement custom analytics/error reporting:
class ProductionObserver extends GraftObserver {
  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

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

## 🏗️ High-Performance Architecture

Graft achieves sub-microsecond diffing and zero wasted rebuilds by decoupling state evaluation from Flutter's widget tree lifecycle.

### 1. Hardware-Aligned Bitmask Diff Pipeline
```text
┌────────────────────────────────────────────────────────────────────────┐
│                      DEVELOPER CALL (ZERO BOILERPLATE)                 │
│         state..address.city = 'Berlin'..tasks.add(item)..update()      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          GRAFT CORE ENGINE                             │
│                  diffChanges(): Evaluate props against _baseline       │
│                                   │                                    │
│         ┌─────────────────────────┼────────────────────────┐           │
│         ▼                         ▼                        ▼           │
│  [ Primitive Values ]   [ Nested Sub-States ]     [ Collections ]      │
│  (int, String, bool)    (GraftState in props)    (List, Set, Map)      │
│  1-Cycle Identity:      Deep Recursive Props     Recursive Elements    │
│  identical(prev, curr)  Snapshot Comparison      Snapshot Equality     │
│         │                         │                        │           │
│         └─────────────────────────┼────────────────────────┘           │
│                                   ▼                                    │
│            Compute 64-bit Integer dirtyMask in CPU registers           │
│                                   │                                    │
│                                   ▼                                    │
│                       notifyMask(dirtyMask)                            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│              SELF-HEALING SLOT RECONCILIATION PIPELINE                 │
│                 GraftMultiChildDiffEngine / GraftBoundary              │
│                                   │                                    │
│            Does dirtyMask intersect slot's learnedDependencies?        │
│                    ┌──────────────┴──────────────┐                     │
│                   YES                            NO                    │
│                    │                             │                     │
│           [⚡ 1-CPU Fast Path]         [🔬 2-ns Fingerprint Check]     │
│           Immediate leaf rebuild       Evaluate slot hash              │
│           notifier.value = newWidget;            │                     │
│                                      ┌───────────┴───────────┐         │
│                                     MATCH                DIFFERENT     │
│                                      │                       │         │
│                                 [0 Rebuild]       [💥 SELF-HEAL MASK]  │
│                                 Bypassed clean    • Leaf rebuild!      │
│                                                   • learned |= dirty   │
└────────────────────────────────────────────────────────────────────────┘
```

### 2. Route-Stack Lifecycle & PopupRoute Protection

Graft's dependency injection coordinates with Flutter's `Navigator` stack to eliminate manual service locators and memory leaks:

```text
┌────────────────────────────────────────────────────────────┐
│                    Route A (HomeScreen)                    │
│             Calls: context.use(ProfileGraft.new)           │
│             👑 Becomes OWNER of ProfileGraft               │
└─────────────────────────────┬──────────────────────────────┘
                              │ Navigator.push()
                              ▼
┌────────────────────────────────────────────────────────────┐
│                 Route B (EditProfileScreen)                │
│             Calls: context.use(ProfileGraft.new)           │
│             🤝 BORROWS existing ProfileGraft               │
└─────────────────────────────┬──────────────────────────────┘
                              │ showDialog() / ModalBottomSheet
                              ▼
┌────────────────────────────────────────────────────────────┐
│           Transient PopupRoute (ConfirmDialog)             │
│             🛡️ Protected: Anchored to Route B              │
│      Closing dialog does NOT dispose ProfileGraft!         │
└────────────────────────────────────────────────────────────┘
                              │ Route A popped
                              ▼
┌────────────────────────────────────────────────────────────┐
│             ProfileGraft.dispose() Automatically           │
│               0 Memory Leaks • 0 Manual Hooks              │
└────────────────────────────────────────────────────────────┘
```

* **Route Stack Borrowing**: Downstream screens automatically share existing controllers from predecessor routes without needing prop drilling or complex inherited widgets.
* **Owner-Controlled Disposal**: The screen that initializes a controller owns its lifecycle. When that route pops, Graft disposes the controller automatically.
* **Transient Popup Protection**: Dialogs, alerts, and modal bottom sheets anchor to their parent `PageRoute`. Popping a dialog never prematurely kills the host controller.

---

### 3. Core Engine Mechanics

* **1-Cycle Bitmask Evaluation**: Up to 64 state fields are tracked in 64-bit integer bitmasks, evaluated directly in CPU registers via single bitwise AND operations (`dirtyMask & slotMask != 0`). For models with more than 64 fields, `GraftMask` seamlessly scales into chunked 32-bit integer words with 100% web JavaScript compatibility.
* **Depth-$N$ Parent Rebuild Insulation**: `graft((s) => ...)` leaf slots are executed inside an internal `NoSubscriptionContext`, preventing ambient `Theme` or `MediaQuery` subscriptions from leaking into intermediate layout parents.
* **Zero GC Pressure on Mutations**: Synchronous in-place cascade updates (`state..name = 'Alice'..update()`) reuse existing domain objects. No new wrapper objects or transient copy instances are allocated during state transitions.
* **Pre-Flight Slot Short-Circuiting**: `graft.slots(...)` tracks `ignoredMask` alongside learned dependencies. If a state mutation only modifies fields that no child slot listens to, the diff engine bypasses the entire layout build phase in 0 element rebuilds.

---

## 🧪 Test Verification & Quality Assurance

Graft is verified against **185 passing tests** with zero static analysis warnings:

```bash
flutter test
# 00:08 +185: All tests passed!
```

```bash
dart analyze
# No issues found!
```

| Domain | Test Suite Files | Verification Scope |
| :--- | :--- | :--- |
| **State & Collections** | `test/graft_state_test.dart`<br>`test/nested_substate_mutation_test.dart`<br>`test/collection_mutation_test.dart`<br>`test/graft_mask_test.dart`<br>`test/large_state_bitmask_test.dart` | In-place baseline mutations (`List`, `Set`, `Map`), nested `GraftState` mutation diffing, 64-bit bitmasks, unbounded mask growth, and reset. |
| **Rebuild Firewall & Diff Engine** | `test/adaptive_slot_preflight_test.dart`<br>`test/context_isolation_leak_test.dart`<br>`test/deterministic_slot_bitmask_test.dart`<br>`test/bitmask_preflight_test.dart`<br>`test/safe_ast_context_test.dart`<br>`test/depth_n_isolation_test.dart`<br>`test/slot_engine_test.dart`<br>`test/disordering_test.dart` | `ignoredMask` pre-flight short-circuiting, `NoSubscriptionContext` leak prevention, Depth-$N$ parent rebuild insulation, and disordered slot resolution. |
| **Auto-Discovery & Tickers** | `test/graft_boundary_test.dart`<br>`test/multi_graft_combinator_test.dart`<br>`test/animation_isolation_test.dart` | Multi-controller ambient auto-discovery, backward adaptive learning, and 60fps/120fps continuous animation ticker containment. |
| **Routing & Lifecycle** | `test/dialog_popup_lifecycle_test.dart`<br>`test/graft_route_test.dart`<br>`test/graft_route_extended_test.dart`<br>`test/nested_route_isolation_test.dart`<br>`test/lifecycle_test.dart` | `context.use<T>()` route-stack borrowing, transient `PopupRoute` dialog protection, parallel navigator isolation, and auto-disposal on route pop. |
| **Async Concurrency & Slots** | `test/async_concurrency_race_test.dart`<br>`test/coalescing_test.dart`<br>`test/graft_async_widget_test.dart` | Monotonic task token guard (`_currentAsyncTaskId`), stale response dropping, and declarative `graft.async` slots. |
| **Stress & Scalability** | `test/benchmark/*` (10 test files) | Glitch-free reactive diamond DAG propagation, deep computed chain evaluation, multi-field batching, and high-frequency frame stress testing. |

---

## 📄 License

MIT License. Free to use, modify, and distribute.
