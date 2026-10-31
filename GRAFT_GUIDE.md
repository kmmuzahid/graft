# Graft State Management & Frame-0 Persistence: Complete Developer Guide

---

## 🚀 Overview

**Graft** is a self-optimizing, fine-grained reactive state management and persistence engine for Flutter:
- **Zero Boilerplate:** No immutable `copyWith` methods, no `Equatable` boilerplate, and no code generation (`build_runner` is never required).
- **Cascade Mutations:** Direct mutations on plain variables with 1 synchronous pass: `state..name = 'Alice'..update();`.
- **Surgical Slot Isolation:** Direct C-level pointer notifications (`GraftFastReceiver`) isolate rebuilds to the leaf Element. Parent and sibling widgets experience **0 static rebuilds**.
- **Frame-0 Dry State:** Sub-50ns synchronous L1 RAM state hydration on Frame 0 with **zero blank frames** and **zero controllers needed for forms**.
- **100% DRY Option B Models:** Domain sub-models extend `GraftModel` with plain variables and `propsOf`, matching `GraftState` exactly with zero `fromTuple` constructors and zero tear-offs.

> [!TIP]
> **Production Starter Template:** Check out **[`graft_template`](https://github.com/kmmuzahid/graft_template)** — the official production-ready starter template integrating Graft with CoreKit (`core_kit`), complete with route scoping, Frame-0 dry persistence, zero-controller forms, and authentication.

---

## 📖 Table of Contents
1. [Core Reactive Concepts](#core-reactive-concepts)
2. [Defining Domain State (`GraftState`)](#defining-domain-state-graftstate)
3. [Building Controllers (`Graft<S>`)](#building-controllers-grafts)
4. [Surgical UI Slots & Leaf Rebuilds](#surgical-ui-slots--leaf-rebuilds)
5. [Cascaded Domain Sub-Models (`GraftModel`)](#cascaded-domain-sub-models-graftmodel)
6. [Frame-0 Dry State Persistence](#frame-0-dry-state-persistence)
7. [Zero-Controller Forms on Frame 0](#zero-controller-forms-on-frame-0)
8. [Micro-State Persistence (`ValueGraft.dry`)](#micro-state-persistence-valuegraftdry)
9. [Flow-Wide Scope Invalidation (`invalidateDry`)](#flow-wide-scope-invalidation-invalidatedry)
10. [Storage Drivers & Custom Storage Abstraction (`configurePersistence`)](#storage-drivers--custom-storage-abstraction-configurepersistence)
11. [Linter & Architectural Best Practices](#linter--architectural-best-practices)
12. [Related Technical Guides & Reports](#related-technical-guides--reports)

---

## Core Reactive Concepts

Unlike traditional architectures that re-create entire immutable state trees on every event, Graft separates **Domain Data** (`GraftState`) from **Reactive Coordination** (`Graft`):

```
┌────────────────────────────────────────────────────────┐
│                      GraftState                        │
│   Plain mutable fields: name, count, address           │
│   props => propsOf(name, count, address)               │
└──────────────────────────┬─────────────────────────────┘
                           │ cascade mutate + update()
                           ▼
┌────────────────────────────────────────────────────────┐
│                   Graft Controller                     │
│   - Bitmask Diffing (< 50 ns, 0 heap allocations)      │
│   - Frame-0 Dry Persistence (L1 RAM cache < 50 ns)     │
│   - Lifecycle Hooks (onInit / onDispose)               │
└──────────────────────────┬─────────────────────────────┘
                           │ surgical leaf pointer dispatch
                           ▼
┌────────────────────────────────────────────────────────┐
│                  Flutter UI Widgets                    │
│   Slot 0 (Name): Rebuilt (1 rebuild)                   │
│   Slot 1 (Count): Untouched (0 rebuilds)               │
│   Slot 2 (Address): Untouched (0 rebuilds)             │
└────────────────────────────────────────────────────────┘
```

---

## Defining Domain State (`GraftState`)

Subclass `GraftState`, define plain mutable fields, and override `props`:

```dart
class UserState extends GraftState {
  String name = 'Alice';
  int age = 30;
  bool isOnline = false;

  @override
  GraftProps get props => propsOf(name, age, isOnline);
}
```

> [!NOTE]
> ### 💡 Frame-0 Dry Persistence vs Transient State
> Frame-0 dry persistence is **strictly optional**. You only use `super.dry(State.new)` and declare `@override int get schemaVersion => 1;` when you want that state or model's data saved permanently across app restarts (e.g. auth tokens, checkout drafts, user preferences).
>
> For **transient UI states** (e.g. search queries, bottom sheet filters, confirmation dialogs, animation flags), simply use standard `super(State())` with `props => propsOf(...)` and mutate in-place with `update()`.

> [!TIP]
> ### 🧠 State vs. Controller Lifecycle: `GraftState` Has No `init()`
> - **`GraftState` (Domain Data):** Holds data fields and `props`. It has **no `init()` or `onInit()` method**. Initial values are assigned directly at declaration (`String name = 'Alice';`) or via standard Dart constructor formals (`UserState({this.name = 'Alice'});`).
> - **`Graft` (Controller):** Owns UI coordination and lifecycle hooks (`onInit()` & `onDispose()`). When `context.use(...)` or `context.create(...)` resolves or creates a controller, Frame-0 hydration completes synchronously *before* `onInit()` runs.
> - **`GraftStateConfig` (Storage Contract):** Defines 5 pure storage I/O methods. It has **no `init()` method**; dependencies (database handles, directories) are passed into its constructor.

### Mutating State In-Place
Use standard Dart cascade syntax:
```dart
state
  ..name = 'Bob'
  ..isOnline = true
  ..update(); // Diffing and leaf dispatch executed synchronously in 1 pass!
```

---

## Building Controllers (`Graft<S>`)

Extend `Graft<UserState>` to hold business logic and controllers:

```dart
class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state..name = newName..update();
  }

  void incrementAge() {
    state..age += 1..update();
  }
}
```

---

## Surgical UI Slots & Leaf Rebuilds

Graft provides a comprehensive suite of ergonomic reactive slot primitives designed to isolate widget rebuilds to the exact leaf element without requiring selector boilerplate:

### ⚡ Architectural Foundation: Native `ComponentElement` Slots
Unlike traditional Flutter state management libraries that wrap reactive nodes in `StatefulWidget`, `State`, and `ValueNotifier`, Graft's slots (`graft((s) => ...)`, `graft.slot`, and `graft.slots`) subclass Flutter's core `ComponentElement` directly:
- **Direct Pointer Dispatch (`GraftFastReceiver`)**: The controller maintains a direct pointer to the mounted leaf element. State mutations invoke `fast.markFastDirty()` in $< 5\text{ ns}$, which directly executes Flutter's native `Element.markNeedsBuild()`.
- **Zero Intermediate Wrappers**: Zero `ValueNotifier`, zero `StreamSubscription`, and zero closure allocations on notification.
- **Single-Scalar Fast Path**: When a state contains a single property (`_scalarCount == 1`), multi-child diffing is bypassed completely. The slot marks dirty and executes `_builder(_state)` directly once per frame.
- **Level-0 Pre-Flight Bypass (`_commonIgnoredMask`)**: For multi-child layouts (`graft.slots`), an $O(1)$ single-cycle pre-flight bitwise test aborts layout reconciliation in $< 1\text{ ns}$ when mutations affect fields universally ignored by all child slots.
- **Depth-$N$ Parent Rebuild Insulation**: Slots execute within an internal `NoSubscriptionContext`, preventing ambient `Theme` or `MediaQuery` subscriptions from leaking into parent layout containers.

---

### 1. Signature Callable Leaf Slot (`graft((s) => ...)`)
The fastest syntax for single-child slots. Provides **Depth-$N$ parent rebuild insulation**—outer containers (`Card`, `Padding`, `AppBar`) experience **0 rebuilds**:
```dart
@override
Widget build(BuildContext context) {
  final user = context.use(UserGraft.new);

  return Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: Center(
      // Rebuilds ONLY when name changes; outer Center & Scaffold never rebuild!
      child: user((s) => Text(s.name, style: const TextStyle(fontSize: 24))),
    ),
  );
}
```

### 2. Explicit Leaf Slot (`graft.slot(builder: ...)`)
Named alternative to the callable syntax with optional custom keys:
```dart
user.slot(
  builder: (s) => Text('Age: ${s.age}'),
);
```

### 3. Multi-Child Layout Diff Engine (`graft.slots(...)`)
Universal layout diffing (`Column`, `Row`, `Wrap`, `Stack`, `Flex`). Each item in the returned list becomes an independently evaluated diff slot. Unchanged slots, static headers, and condition branches evaluate with **0 rebuilds**:
```dart
user.slots(
  layout: Column(crossAxisAlignment: CrossAxisAlignment.start, children: slots),
  slots: (s) => [
    const ProfileHeader(), // 0 rebuilds (const pointer match)
    Text('Name: ${s.name}'), // Rebuilds only when name changes
    Text('Email: ${s.email}'), // Rebuilds only when email changes
    if (s.isOnline) const OnlineBadge(), // Dynamic branch
  ],
);
```

### 4. Memoized Computed Selector (`graft.compute<R>(...)`)
Pre-flight derived value caching. Checks the raw computed value *before* executing the builder closure. If the computed value hasn't changed, the widget builder closure is **never executed**:
```dart
user.compute<int>(
  compute: (s) => s.notifications.length,
  builder: (count) => Badge(
    label: Text('$count'),
    child: const Icon(Icons.notifications),
  ),
);
```

### 5. Virtualized Lazy Collections (`graft.builder<T>(...)`)
100% lazy collections (`ListView.builder`, `GridView.builder`) with per-item slot isolation. Modifying one item in a 10,000-item list triggers **1 rebuild** for that item only, while all other items experience **0 rebuilds**:
```dart
taskGraft.builder<TaskItem>(
  items: (s) => s.tasks,
  itemBuilder: (task, index) => ListTile(
    title: Text(task.title),
    trailing: Checkbox(
      value: task.isDone,
      onChanged: (_) => taskGraft.toggleTask(index),
    ),
  ),
);
```

### 6. Declarative Async Pattern Matching (`graft.async<T>(...)`)
Type-safe algebraic pattern matching for `GraftAsync` states (`idle`, `loading`, `data`, `error`):
```dart
orderGraft.async<List<Order>>(
  selector: (s) => s.ordersState,
  data: (orders) => OrderListView(orders: orders),
  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
  error: (err, st) => Text('Failed to load orders: $err'),
  idle: () => const Text('Tap to load orders'),
);
```

### 7. Multi-Controller Rebuild Firewall (`GraftBoundary`)
An Element-level rebuild barrier with **Ambient Auto-Discovery** and **Backward Adaptive Learning**. It automatically discovers and listens to multiple controllers simultaneously, completely shielding parent layouts from inner rebuilds:
```dart
GraftBoundary(
  builder: (context) {
    // Ambiently discovers and listens to userGraft & themeGraft:
    return Row(
      children: [
        Text(userGraft.state.name),
        const SizedBox(width: 8),
        Icon(Icons.palette, color: themeGraft.state.accentColor),
      ],
    );
  },
);
```

---

## Cascaded Domain Sub-Models (`GraftModel`)

In enterprise applications, domain states are rarely flat. Traditional immutable architectures force developers to write nested `copyWith` chains or resort to heavy code generation (`build_runner`):

```dart
// ❌ Traditional Immutable Approach (GC pressure & verbose):
state = state.copyWith(
  address: state.address.copyWith(street: '123 Main St'),
);
```

Graft completely eliminates this with **`GraftModel`**:
- **100% Cascade-Mutable:** Mutate nested models in-place with native Dart cascades (`state..address.street = '123'..update();`).
- **Zero Allocations & Zero GC:** The existing model instance is updated in-place; no ephemeral copy instances or wrapper trees are allocated.
- **Recursive Bitmask Diffing:** When `update()` executes, Graft recursively diffs nested model `props` against their baseline snapshots in $< 50\text{ ns}$.
- **Synchronous Frame-0 Binary Hydration:** Hydrate deep nested trees on Frame 0 directly into constructor arguments with zero blank frames and zero JSON parsing.
- **Zero Boilerplate:** No `fromJson`, no `toJson`, no `copyWith`, and no constructors needed!

---

### 1. Define the Sub-Model (`GraftModel`)

Extend `GraftModel` with plain Dart variables. Override `schemaVersion => 1`, `props` for UI diffing, and `factory => AddressModel.new` for Frame-0 constructor hydration:

```dart
class AddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String street;
  String city;
  int zipCode;

  AddressModel([
    this.street = '221B Baker Street',
    this.city = 'London',
    this.zipCode = 10001,
  ]);

  // 1. Declare properties for recursive slot diffing:
  @override
  GraftProps get props => propsOf(street, city, zipCode);

  // 2. 1-line constructor tear-off for auto-hydration on Frame 0:
  @override
  Function get factory => AddressModel.new;

  // 3. Reset in-place to initial baseline:
  @override
  void onReset() {
    street = '221B Baker Street';
    city = 'London';
    zipCode = 10001;
  }
}
```

> [!NOTE]
> ### 💡 When does a `GraftModel` need `factory`?
> A `GraftModel` implements `@override Function get factory => Model.new;` so that Frame-0 hydration can instantiate restored models automatically into constructor arguments without any manual index casting.
>
> If your domain sub-model is used purely in-memory (or belongs to a transient state), no `factory` or `schemaVersion` is needed. Simply declare `props => propsOf(...)` and optional `onReset()`.

---

### 2. Embed the Model in Domain State (`GraftState`)

Declare `AddressModel` in the state's constructor with a default value. List it in `props` for UI diffing, and pass the constructor tear-off to `super.dry(UserProfileState.new)`:

```dart
class UserProfileState extends GraftState {
  @override
  int get schemaVersion => 1;

  String fullName;
  bool isSaving; // Transient UI flag (starts fresh on app launch)
  AddressModel address; // Nested GraftModel

  UserProfileState([
    this.fullName = 'Sherlock Holmes',
    this.isSaving = false,
    AddressModel? address,
  ]) : address = address ?? AddressModel();

  // 1. All fields listed for surgical leaf diffing:
  @override
  GraftProps get props => propsOf(fullName, isSaving, address);

  @override
  void onReset() {
    fullName = 'Sherlock Holmes';
    isSaving = false;
    address.onReset();
  }
}
```

---

### 3. Mutate Nested Models in Controller (`Graft<S>`)

Mutate nested fields directly using Dart's native cascade operator:

```dart
class UserProfileGraft extends Graft<UserProfileState> {
  UserProfileGraft() : super.dry(UserProfileState.new);

  // Mutate top-level field:
  void updateName(String name) {
    state..fullName = name..update();
  }

  // ⚡ Mutate nested model fields directly in-place:
  void updateAddress({required String street, required String city}) {
    state
      ..address.street = street
      ..address.city = city
      ..update(); // Automatically detects nested mutations with 0 object allocations!
  }

  // Reset entire state tree in-place:
  void resetProfile() {
    state.reset(); // Restores fullName and address in 1 synchronous pass!
  }
}
```

---

### 4. Surgical UI Leaf Isolation with Nested Fields

Because `Graft` computes bitmasks across nested model properties, modifying `address.street` updates **only** the address leaf slot. Sibling widgets watching `fullName` experience **0 rebuilds**:

```dart
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.use(UserProfileGraft.new);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🎯 Leaf Slot 1: Watches ONLY fullName.
            // (When address changes, this slot experiences 0 rebuilds!)
            user((s) => Text(
              s.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )),

            const Divider(),

            // 🎯 Leaf Slot 2: Watches nested AddressModel fields.
            // (When fullName changes, this slot experiences 0 rebuilds!)
            user((s) => Text(
              '${s.address.street}, ${s.address.city} (${s.address.zipCode})',
              style: const TextStyle(color: Colors.grey),
            )),

            const SizedBox(height: 20),

            // ⚡ Zero-Controller TextFormField bound to Frame-0 restored nested model:
            TextFormField(
              initialValue: user.state.address.street,
              decoration: const InputDecoration(labelText: 'Street Address'),
              onChanged: (val) => user.updateAddress(
                street: val,
                city: user.state.address.city,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: user.resetProfile,
              child: const Text('Reset All to Defaults'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Frame-0 Dry State Persistence

Enable automatic Frame-0 state persistence with **100% native Dart, zero boilerplate, zero manual index casting, and zero magic strings**. 

Declare your state with standard constructor parameters and defaults, override `schemaVersion => 1`, and pass the constructor tear-off to `super.dry(State.new)`:

```dart
class CheckoutState extends GraftState {
  @override
  int get schemaVersion => 1;

  String customerName;
  String notes;
  bool isLoading; // Transient UI state (starts fresh every time!)

  CheckoutState([
    this.customerName = 'Alice',
    this.notes = 'Leave at door',
    this.isLoading = false,
  ]);

  // 1. All domain properties listed for surgical leaf diffing:
  @override
  GraftProps get props => propsOf(customerName, notes, isLoading);
}

class CheckoutGraft extends Graft<CheckoutState> {
  // ⚡ Directly hydrates from binary L1 RAM on Frame 0 into constructor arguments!
  CheckoutGraft() : super.dry(CheckoutState.new);
}
```

- **Frame 0 (Restoration):** The engine reads the binary cache and directly invokes `CheckoutState.new(cached[0], cached[1], ...)` in < 50ns before initial paint!
- **Selective Persistence:** `customerName` and `notes` restore from cache, while `isLoading` starts fresh as `false`.
- **First Launch (No Cache):** Naturally falls back to constructor defaults (`'Alice'` and `'Leave at door'`).
- **Two-Tier Enforcement:** `packages/graft_lint` flags missing `schemaVersion` or `factory` at compile time; runtime throws actionable `StateError` if contracts are omitted.
- **Zero Boilerplate:** NO `read()`, NO manual index casting, NO magic strings. 100% refactor-safe in your IDE!

### Native Lifecycle Hooks (`onInit` & `onDispose`)
When `Graft` is instantiated, Frame-0 hydration completes **before** `onInit()` runs:
```dart
class CheckoutGraft extends Graft<CheckoutState> {
  CheckoutGraft() : super.dry(CheckoutState.new);

  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Synchronously initialized from restored Frame-0 state!
    notesController.text = state.notes;
  }

  @override
  void onDispose() {
    notesController.dispose(); // Automatically disposed when screen unmounts
    super.onDispose();
  }
}
```

---

## Zero-Controller Forms on Frame 0

Standard Flutter `TextFormField` directly displays Frame-0 restored state with **zero controllers**, **zero `initState`**, and **zero `dispose`**:

```dart
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final graft = context.use(CheckoutGraft.new);

    return Scaffold(
      body: Column(
        children: [
          // ⚡ Displays restored text on Frame 0 with ZERO flash:
          TextFormField(
            initialValue: graft.state.customerName,
            onChanged: (val) => graft.state..customerName = val..update(),
          ),
        ],
      ),
    );
  }
}
```

---

## Micro-State Persistence (`ValueGraft.dry`)

Persist a single standalone primitive or enum micro-state without creating a state class:

```dart
// Counter that automatically restores on Frame 0 and persists across app restarts:
final counter = ValueGraft<int>.dry(0, key: 'app_counter');

void increment() {
  counter.value++; // Automatically saved and debounced!
}
```

---

## Flow-Wide Scope Invalidation (`invalidateDry`)

When an order is submitted or a flow is reset, purge all dry states across the entire scope with a single line:

```dart
void submitOrder() {
  // Purges all persisted forms and caches for checkout flow:
  AppScope.checkout.invalidateDry();

  // Subsequent mutations are frozen (produce 0 writes):
  state..customerName = ''..update();
}
```
```dart
graft.invalidateDry();
```

When using `GraftDevObserver`, Frame-0 dry state creation, updates, hydrations, and invalidations are logged automatically with distinct emoji badges:

```text
[🌱 GRAFT CREATED] | SignupGraft 💾 [DRY: signup_draft]

[❄️ GRAFT DRY HYDRATED] | SignupState 💾 [key: signup_draft] | restored from L1 RAM in <50ns

[⚡ GRAFT CHANGE] | SignupGraft 💾 [DRY: signup_draft]
  SignupState(name: "", email: "")
  ➡️ SignupState(name: "Alice", email: "alice@example.com")

[🧹 GRAFT DRY INVALIDATED] | SignupState 💾 [key: signup_draft] | persistence cleared for session
```

---

## Storage Drivers & Custom Storage Abstraction (`configurePersistence`)

> [!IMPORTANT]
> ### ⚠️ Permanent Disk Persistence Requires Storage Configuration
> By default, if unconfigured, Graft operates purely in RAM using an internal `MemoryStateConfig()`. While state changes remain reactive during the current session, **state will NOT survive app restarts unless a permanent storage abstraction is configured**.
>
> To persist state permanently to disk or a database across app restarts, you must configure a storage driver in your `main()` function via `configurePersistence()`.

Graft provides zero-dependency binary persistence drivers out-of-the-box, as well as an extensible storage contract (`GraftStateConfig`) allowing teams to connect any storage engine (SharedPreferences, Encrypted Storage, SQLite, or Cloud Sync).

---

### 1. Production Binary File Driver (`FileStateConfig`)
The easiest zero-dependency solution for Flutter Mobile, Desktop, and Embedded targets. Saves binary blobs directly into `.bin` files:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Point to application documents directory (e.g. path_provider):
  final docsDir = await getApplicationDocumentsDirectory();

  // 2. Configure permanent binary file driver:
  configurePersistence(FileStateConfig(docsDir));

  runApp(const MyApp());
}
```
All persistent states are pre-read synchronously into L1 RAM cache on Frame 0 and written back to disk asynchronously using a coalesced 300ms debounce queue during user typing.

---

### 2. Implementing a Custom Storage Abstraction (`GraftStateConfig`)
`GraftStateConfig` defines 5 contract methods (`readAllSync`, `read`, `write`, `delete`, and `close`). It does **not** mandate any `init()` method—you simply pass any pre-opened storage instance (such as `SharedPreferences`, encrypted storage, or native box) directly into your class constructor:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:graft/graft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStateConfig implements GraftStateConfig {
  final SharedPreferences prefs;
  SharedPrefsStateConfig(this.prefs);

  static const String _prefix = 'graft_';

  @override
  Map<String, Uint8List> readAllSync() {
    // ⚡ Pre-warms L1 RAM cache: enables Frame-0 instant hydration with 0 blank frames!
    // SharedPreferences keeps all cached keys in memory synchronously:
    final results = <String, Uint8List>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        final base64String = prefs.getString(key);
        if (base64String != null) {
          results[key.substring(_prefix.length)] = base64Decode(base64String);
        }
      }
    }
    return results;
  }

  @override
  Future<Uint8List?> read(String key) async {
    final base64String = prefs.getString('$_prefix$key');
    return base64String != null ? base64Decode(base64String) : null;
  }

  @override
  Future<void> write(String key, Uint8List value) async {
    // Automatically debounced (300ms) by Graft's internal DebounceQueue:
    await prefs.setString('$_prefix$key', base64Encode(value));
  }

  @override
  Future<void> delete(String key) async {
    await prefs.remove('$_prefix$key');
  }

  @override
  Future<void> close() async {
    // SharedPreferences maintains no open file handle requiring disposal
  }
}

// In main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences before mounting UI:
  final prefs = await SharedPreferences.getInstance();
  configurePersistence(SharedPrefsStateConfig(prefs));

  runApp(const MyApp());
}
```

---

### 3. In-Memory Driver for Testing (`MemoryStateConfig`)
For unit tests, widget tests, and CI pipelines, use `MemoryStateConfig` for 100% in-memory isolation without disk I/O:
```dart
void main() {
  setUp(() {
    configurePersistence(MemoryStateConfig());
  });

  tearDown(() {
    GraftDI.reset();
  });

  test('Frame-0 dry persistence unit test', () {
    // Tests run with 0 file system side effects!
  });
}
```

---

## Linter & Architectural Best Practices

Use the official **[`graft_lint`](https://pub.dev/packages/graft_lint)** analyzer plugin to catch anti-patterns and enforce architectural contracts directly in your IDE:

### 1. `avoid_nested_graft_slot` (Severity: 🔴 `error`)
Graft slots (`graft((s) => ...)`, `graft.slot`, `graft.slots`, `graft.builder`) are already isolated micro-diffing engines. Nesting a slot inside another slot of the same controller creates redundant reconciliation loops and subverts fine-grained rebuild insulation.
```dart
// ❌ BAD: Illegal nesting of slots of the same controller
graft.slot(
  builder: (s) => Column(
    children: [
      Text('Title: ${s.title}'),
      graft((s) => Text('Name: ${s.name}')), // 🔴 avoid_nested_graft_slot error!
    ],
  ),
);

// ✅ GOOD: Use graft.slots for multi-child layouts
graft.slots(
  layout: Column(children: slots),
  slots: (s) => [
    Text('Title: ${s.title}'),
    Text('Name: ${s.name}'),
  ],
);
```

### 2. `prefer_props_in_graft_state` (Severity: 🔴 `error`)
Every `GraftState` class must declare `GraftProps get props => propsOf(...)` to enable 1-cycle CPU bitmask diffing and 0-GC state evaluation:
```dart
// ❌ BAD: Missing props contract
class ProfileState extends GraftState {
  String name = '';
}

// ✅ GOOD: Declares tracked fields for hardware bitmask diffing
class ProfileState extends GraftState {
  String name = '';
  @override
  GraftProps get props => propsOf(name);
}
```

### 3. `require_graft_route_observer` (Severity: 🔴 `error`)
Guarantees that `GraftRouteTracker.observer` is registered in `MaterialApp.navigatorObservers` or `CupertinoApp.navigatorObservers` so that controllers are automatically disposed when their owner route pops:
```dart
// ✅ GOOD: Route observer registered
MaterialApp(
  navigatorObservers: [GraftRouteTracker.observer],
  home: const HomeScreen(),
);
```

---

## 📚 Related Technical Guides & Reports

- 🚀 **[graft_template](https://github.com/kmmuzahid/graft_template):** Official production-ready starter template integrating **Graft** with **CoreKit** (`core_kit`).
- 🏛️ **[ARCHITECTURE.md](https://github.com/kmmuzahid/graft/blob/main/ARCHITECTURE.md):** Deep dive into the 7 Core Engineering Pillars, bitmask diffing, native `ComponentElement` slots, monotonic TypeId, and DAG teardowns.
- 💉 **[DI_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md):** Dedicated guide for the DI engine (developer enum scopes, zero-scope boot, singleton lock, non-blocking async DB/network, route leasing).
- 📊 **[BENCHMARK_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** Empirical benchmark methodology, hardware specs, and full logs across all 21 benchmark scenarios (including Frame-0 dry persistence at ~1.5 µs latency).
- 🧪 **[TEST_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Comprehensive test verification report across 304 passing tests (including 51 persistence and dry state tests).

