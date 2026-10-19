# Graft State Management & Frame-0 Persistence: Complete Developer Guide

---

## 🚀 Overview

**Graft** is a self-optimizing, fine-grained reactive state management and persistence engine for Flutter:
- **Zero Boilerplate:** No immutable `copyWith` methods, no `Equatable` boilerplate, and no code generation (`build_runner` is never required).
- **Cascade Mutations:** Direct mutations on plain variables with 1 synchronous pass: `state..name = 'Alice'..update();`.
- **Surgical Slot Isolation:** Direct C-level pointer notifications (`GraftFastReceiver`) isolate rebuilds to the leaf Element. Parent and sibling widgets experience **0 static rebuilds**.
- **Frame-0 Dry State:** Sub-50ns synchronous L1 RAM state hydration on Frame 0 with **zero blank frames** and **zero controllers needed for forms**.
- **100% DRY Option B Models:** Domain sub-models extend `GraftModel` with plain variables and `propsOf`, matching `GraftState` exactly with zero `fromTuple` constructors and zero tear-offs.

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

Graft provides three ergonomic slot patterns for isolating widget rebuilds without selector closures:

### 1. Callable Shortcut (`graft((s) => ...)`)
The fastest syntax for single-child slots:
```dart
@override
Widget build(BuildContext context) {
  final user = context.use(UserGraft.new);

  return Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: Center(
      child: user((s) => Text(s.name, style: const TextStyle(fontSize: 24))),
    ),
  );
}
```

### 2. Isolated Slot (`graft.slot(...)`)
Surgical leaf slot with optional custom slot keys:
```dart
user.slot((s) => Text('Age: ${s.age}'));
```

### 3. Multi-Child Layouts (`graft.slots(...)`)
Zero rebuild leakage in list or column layouts:
```dart
graft.slots([
  (s) => Text(s.name),
  (s) => Text('Age: ${s.age}'),
  (s) => Icon(s.isOnline ? Icons.check_circle : Icons.offline_bolt),
]);
```

### 4. Asynchronous States (`GraftAsync<T>`)
First-class pattern matching for async operations:
```dart
graft.asyncSlot(
  data: (orders) => OrderList(orders),
  loading: () => const CircularProgressIndicator(),
  error: (err, st) => Text('Failed to load: $err'),
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
- **Synchronous Frame-0 Binary Hydration:** Hydrate deep nested trees on Frame 0 via `dryModel()` with zero blank frames and zero JSON parsing.
- **Zero Boilerplate:** No `fromJson`, no `toJson`, no `copyWith`, and no constructors needed!

---

### 1. Define the Sub-Model (`GraftModel`)

Extend `GraftModel` with plain Dart variables. Override `props` for UI diffing, `onDry()` for Frame-0 persistence, and `onReset()` for in-place resets:

```dart
class AddressModel extends GraftModel {
  String street = '221B Baker Street';
  String city = 'London';
  int zipCode = 10001;

  // 1. Declare properties for recursive slot diffing:
  @override
  GraftProps get props => propsOf(street, city, zipCode);

  // 2. Map persistent fields with zero magic strings:
  @override
  void onDry() {
    street = dry(street);
    city = dry(city);
    zipCode = dry(zipCode);
  }

  // 3. Reset in-place to initial baseline:
  @override
  void onReset() {
    street = '221B Baker Street';
    city = 'London';
    zipCode = 10001;
  }
}
```

---

### 2. Embed the Model in Domain State (`GraftState`)

Instantiate `AddressModel` once directly in your `GraftState`. List it in `props` for UI diffing and map it with `dryModel(address)` in `onDry()`:

```dart
class UserProfileState extends GraftState {
  String fullName = 'Sherlock Holmes';
  bool isSaving = false; // Transient UI flag (starts fresh on app launch)
  AddressModel address = AddressModel(); // Nested GraftModel created once!

  // 1. All fields listed for surgical leaf diffing:
  @override
  GraftProps get props => propsOf(fullName, isSaving, address);

  // 2. Only persistent fields mapped (isSaving starts fresh as false):
  @override
  void onDry() {
    fullName = dry(fullName);
    address = dryModel(address); // ⚡ Recursively maps and hydrates the nested model!
  }

  @override
  void onReset() {
    fullName = 'Sherlock Holmes';
    isSaving = false;
    address.reset(); // Recursively resets nested model in-place!
  }
}
```

---

### 3. Mutate Nested Models in Controller (`Graft<S>`)

Mutate nested fields directly using Dart's native cascade operator:

```dart
class UserProfileGraft extends Graft<UserProfileState> {
  UserProfileGraft() : super(UserProfileState());

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

Enable automatic Frame-0 state persistence with **100% native Dart, zero boilerplate, zero constructors, and zero magic strings**. 

Declare your state with standard plain Dart variables. List domain properties in `props` for surgical UI rebuilds, and map persistent fields in `onDry()`:

```dart
class CheckoutState extends GraftState {
  String customerName = 'Alice';
  String notes = 'Leave at door';
  bool isLoading = false; // Transient UI state (starts fresh every time!)

  // 1. All domain properties listed for surgical leaf diffing:
  @override
  GraftProps get props => propsOf(customerName, notes, isLoading);

  // 2. ONLY persistent fields listed here (zero strings, type-inferred!):
  @override
  void onDry() {
    customerName = dry(customerName);
    notes = dry(notes);
  }
}

class CheckoutGraft extends Graft<CheckoutState> {
  // ⚡ Automatically hydrates from binary L1 RAM on Frame 0!
  CheckoutGraft() : super(CheckoutState());
}
```

- **Frame 0 (Restoration):** The engine reads the binary cache and directly assigns restored values in < 50ns!
- **Selective Persistence:** `customerName` and `notes` restore from disk, while `isLoading` always starts fresh as `false`.
- **First Launch (No Cache):** Naturally falls back to initial defaults (`'Alice'` and `'Leave at door'`).
- **Zero Boilerplate:** NO `read()`, NO constructors needed, NO magic strings, NO `.value` wrappers. 100% refactor-safe in your IDE!

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
Or invalidate a single controller:
```dart
graft.invalidateDry();
```

---

## 📚 Related Technical Guides & Reports

- 🏛️ **[ARCHITECTURE.md](file:///Users/km/Documents/km%20muzahid/graft/ARCHITECTURE.md):** Deep dive into the 6 Core Engineering Pillars, bitmask diffing, monotonic TypeId, and DAG teardowns.
- 💉 **[DI_GUIDE.md](file:///Users/km/Documents/km%20muzahid/graft/DI_GUIDE.md):** Dedicated guide for the DI engine (developer enum scopes, zero-scope boot, singleton lock, non-blocking async DB/network, route leasing).
- 📊 **[BENCHMARK_REPORT.md](file:///Users/km/Documents/km%20muzahid/graft/BENCHMARK_REPORT.md):** Empirical benchmark methodology, hardware specs, and full logs across all 21 benchmark scenarios (including Frame-0 dry persistence at ~1.5 µs latency).
- 🧪 **[TEST_REPORT.md](file:///Users/km/Documents/km%20muzahid/graft/TEST_REPORT.md):** Comprehensive test verification report across 283 passing tests (including 51 persistence and dry state tests).

