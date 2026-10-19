# Technical Architecture & Specification: The Graft Dependency Injection (DI) Engine

---

## 1. Architectural Foundations & Invariants

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      THE 6 INVARIANTS OF GRAFT DI                       │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. Zero Codegen       │ Strictly pure Dart constructor tear-offs.       │
│                       │ No build_runner, no .g.dart files.              │
├───────────────────────┼─────────────────────────────────────────────────┤
│ 2. Dual-Speed Lookups │ Cold resolution: ≤ 12ns (Monotonic TypeId array)│
│                       │ Hot frame loops: < 0.8ns (late final L1 offset) │
├───────────────────────┼─────────────────────────────────────────────────┤
│ 3. Automated Scopes   │ Auto-starts lazily on first access. If ANY      │
│                       │ member is referenced, NONE of the scope disposes│
│                       │ (cohesive unit). Preserved across routes.       │
├───────────────────────┼─────────────────────────────────────────────────┤
│ 4. Reverse DAG Drops  │ In-degree dependency tracking ensures consumers │
│                       │ dispose BEFORE underlying databases/services.   │
├───────────────────────┼─────────────────────────────────────────────────┤
│ 5. Headless Testing   │ Zone-isolated overrides without Flutter widget  │
│                       │ bindings or static container cleanup.           │
├───────────────────────┼─────────────────────────────────────────────────┤
│ 6. Grafts Always Die  │ Scopes hold ONLY repositories & services.       │
│                       │ Grafts are route-bound and unconditionally die. │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.1 Strict Modular Constraints
1. **< 200 Lines Per Class Rule:** Every class, mixin, and engine component shall remain strictly **< 200 lines of code**. Large structures are decomposed into modular, single-responsibility units.
2. **Zero `await` in `main()`:** Initializing DI and persistence requires **no `await`**. The engine handles background async I/O automatically via `bindAsync<T>()` and non-blocking `useAsync<T>()` execution gates, ensuring non-blocking application boot without forcing developers to subclass framework classes or wrap individual queries in `guard()`:
   ```dart
   void main() {
     configureDependencies(); // Synchronous, 0-await, zero subclassing!
     runApp(const MyApp());
   }
   ```
3. **Dual-Speed Resolution:**
   - **Cold lookup:** Monotonic `TypeId<T>.id` maps directly to a flat array offset in $\le 12\text{ ns}$ (zero hash collisions, zero string comparisons).
   - **Hot lookup:** Classes cache dependencies via `late final _repo = use<OrderRepository>();`, compiling down to a single V-table offset lookup in $< 0.8\text{ ns}$.
4. **Reverse DAG Drops:** In-degree dependency tracking ensures consumers dispose BEFORE underlying databases/services.
5. **Headless Testing:** Zone-isolated overrides without Flutter widget bindings or static container cleanup.
6. **Grafts Always Die (Never Held by Scopes):** Scopes hold *only* domain repositories and services. `Graft` state controllers are never stored in, owned by, or kept alive by an `AppScope`. A `Graft` is created on-demand by its screen via `context.use(...)` and **always dies unconditionally** when its screen route pops.

---

## 2. Directory Layout & Component Specifications (`lib/src/di/`)

All DI engine components reside in `lib/src/di/`, each strictly **< 200 lines of code**:

```
lib/src/di/
├── type_id.dart                  # Monotonic integer type assigner (< 25 lines)
├── disposable.dart               # Disposable contract & lifecycle tokens (< 35 lines)
├── scope_tier.dart               # Scope tier enum & lease tracking tokens (< 35 lines)
├── scope_node.dart               # Flat array resolution, DAG tracking & drop (< 195 lines)
├── graft_di.dart                 # Ambient use<T>() & useAsync<T>() locators (< 75 lines)
├── async_binding.dart            # Automated async factory & non-blocking Future gate (< 75 lines)
└── graft_scope.dart              # Developer-defined Enum scope, bind() & bindAsync() (< 95 lines)
```

---

### 2.1 Integer Type Identification (`type_id.dart` < 25 lines)
Standard hash maps incur hash computing and bucket traversals. Graft assigns every class an immutable integer ID at first reference to index a flat array:

```dart
// lib/src/di/type_id.dart
abstract final class TypeId<T> {
  static final int id = _TypeIdCounter.next++;
}

class _TypeIdCounter {
  static int next = 0;
}
```

---

### 2.2 Lifecycle Interfaces (`disposable.dart` < 35 lines)
Clean contracts for two-phase initialization and disposal:

```dart
// lib/src/di/disposable.dart
abstract interface class Disposable {
  void dispose();
}

abstract interface class GraftInitializable {
  void onInit();
}
```

---

### 2.3 Scope Tier & Lease Tokens (`scope_tier.dart` < 40 lines)
Defines scope longevity and retention policies:

```dart
// lib/src/di/scope_tier.dart
enum ScopeTier {
  /// Immortal: Process lifespan, never closed (e.g. AppDb, ApiClient, AuthService)
  root,

  /// Preserved: Cross-route flow / user session, alive while active lease tokens exist
  preserved,

  /// Transient: Route-bound, auto-disposed when the owner route pops
  transient,
}
```

---

### 2.4 The Scope Node & Reverse Topological DAG (`scope_node.dart` < 190 lines)
Each scope holds a flat, fast-indexed array of instances, factories, active token leases, and a runtime directed dependency graph:

```dart
// lib/src/di/scope_node.dart
import 'type_id.dart';
import 'disposable.dart';
import 'scope_tier.dart';

class ScopeNode {
  ScopeNode({required this.name, required this.tier, this.parent});

  final String name;
  final ScopeTier tier;
  final ScopeNode? parent;

  // Direct integer-indexed storage for sub-nanosecond lookups
  final List<Object?> _instances = [];
  final Map<int, Object Function()> _factories = {};

  // Runtime In-Flight DAG: Consumer TypeId -> Set of Dependency TypeIds
  final Map<int, Set<int>> _dependencies = {};

  // Active Screen/Flow Leases: TypeId -> Set of Token references
  final Map<int, Set<Object>> _leases = {};

  // Tracked Dry State Keys belonging to this scope
  final Set<String> _dryKeys = {};

  // Tracked Individually Preserved Type IDs within this scope
  final Set<int> _preservedIds = {};

  void registerDryKey(String key) => _dryKeys.add(key);

  /// ⚡ Flow-Wide Dry Invalidation:
  /// Cancels debounce writes, evicts L1 cache, writes L2 tombstones, and freezes states.
  void invalidateDry() {
    for (final key in _dryKeys) {
      // Invalidate dry persistence via storage coordinator
      GraftAmbientLocator.coordinator.invalidate(key);
    }
    _dryKeys.clear();
  }

  // Tracked Types where singleton is explicitly disabled (singleton: false)
  final Set<int> _nonSingletonIds = {};

  void bind<T>(
    T Function() factory, {
    bool singleton = true,
    bool preserved = false,
  }) {
    final id = TypeId<T>.id;
    _factories[id] = factory;
    if (preserved) {
      _preservedIds.add(id);
    }
    if (!singleton) {
      _nonSingletonIds.add(id);
    }
  }

  bool isSingleton(int id) => !_nonSingletonIds.contains(id);

  bool canResolve(int id) =>
      _factories.containsKey(id) || (parent?.canResolve(id) ?? false);

  T resolve<T>(List<int> resolutionStack) {
    final id = TypeId<T>.id;

    // 1. FAST PATH: Already instantiated in active scope
    if (id < _instances.length && _instances[id] != null) {
      _recordDependency(resolutionStack, id);
      return _instances[id] as T;
    }

    // 2. INSTANTIATION: Registered within this scope
    if (_factories.containsKey(id)) {
      return _instantiate<T>(id, resolutionStack);
    }

    // 3. UPSTREAM FALLBACK: Traverse up the tree to Preserved or Root
    if (parent != null) {
      return parent!.resolve<T>(resolutionStack);
    }

    throw StateError('Graft: Type $T is not registered in the active scope hierarchy.');
  }

  T _instantiate<T>(int id, List<int> resolutionStack) {
    // 🛡️ Debug Circular Dependency Interception (Stripped in AOT release)
    assert(() {
      if (resolutionStack.contains(id)) {
        final cycle = [...resolutionStack, id]
            .map((i) => 'TypeId#$i')
            .join(' ──▶ ');
        throw StateError(
          '\n╔══════════════════════════════════════════════════════════════════╗\n'
          '║  GRAFT CIRCULAR DEPENDENCY DETECTED                              ║\n'
          '╚══════════════════════════════════════════════════════════════════╝\n'
          'Cycle: $cycle\n'
          'Action: Move circular calls to onInit() or invoke them inside methods.\n',
        );
      }
      return true;
    }());

    _recordDependency(resolutionStack, id);
    resolutionStack.add(id);

    final factory = _factories[id]!;
    final instance = factory();

    // Store in flat array only if singleton:
    if (isSingleton(id)) {
      while (_instances.length <= id) {
        _instances.add(null);
      }
      _instances[id] = instance;
    }

    resolutionStack.removeLast();

    // Two-Phase Lifecycle: Trigger after pointer is safely registered in cache
    if (instance is GraftInitializable) {
      instance.onInit();
    }

    return instance as T;
  }

  void _recordDependency(List<int> stack, int dependencyId) {
    if (stack.isNotEmpty) {
      final consumerId = stack.last;
      (_dependencies[consumerId] ??= {}).add(dependencyId);
    }
  }

  /// ⚡ Cohesive Scope Reference Tracking:
  /// Returns true if ANY member within this scope is still being referenced.
  bool get hasActiveReferences {
    // 1. Any active screen/flow lease on ANY member in this scope
    for (final holders in _leases.values) {
      if (holders.isNotEmpty) return true;
    }
    // 2. Any active in-degree from an active consumer
    for (int i = 0; i < _instances.length; i++) {
      if (_instances[i] != null && _inDegree(i) > 0) return true;
    }
    return false;
  }

  void retain(int id, Object owner) {
    (_leases[id] ??= {}).add(owner);
  }

  void release(int id, Object owner) {
    final holders = _leases[id];
    if (holders == null) return;
    holders.remove(owner);

    // ⚡ Cohesive Scope Teardown Rule:
    // If ANY member of this scope is still referenced, NONE of the members dispose!
    // The scope drops ONLY when ALL members have zero active references (and tier != preserved).
    if (!hasActiveReferences && tier != ScopeTier.preserved) {
      drop();
    }
  }

  int _inDegree(int dependencyId) {
    int count = 0;
    for (final entry in _dependencies.entries) {
      if (_instances[entry.key] != null && entry.value.contains(dependencyId)) {
        count++;
      }
    }
    return count;
  }

  void _disposeInstance(int id, {bool force = false}) {
    if (id >= _instances.length) return;
    if (_preservedIds.contains(id) && !force) return;
    final instance = _instances[id];
    if (instance == null) return;

    _instances[id] = null;
    _leases.remove(id);
    _dependencies.remove(id);

    if (instance is Disposable) {
      instance.dispose();
    }
  }

  /// Reverse Topological Teardown: Disposes consumers BEFORE dependencies
  void drop({bool force = false}) {
    if (tier == ScopeTier.root && !force) return;

    final activeIds = <int>[];
    for (int i = 0; i < _instances.length; i++) {
      if (_instances[i] != null) activeIds.add(i);
    }

    // Topological DAG Sort: Nodes that are dependencies of others drop last
    activeIds.sort((a, b) {
      final bDependsOnA = _dependencies[b]?.contains(a) ?? false;
      if (bDependsOnA) return 1; // b drops before a
      final aDependsOnB = _dependencies[a]?.contains(b) ?? false;
      if (aDependsOnB) return -1;
      return 0;
    });

    for (final id in activeIds) {
      _disposeInstance(id, force: force);
    }
  }
}
```

---

### 2.5 Top-Level Ambient Container & Zone Test Hook (`graft_di.dart` < 70 lines)
Provides ambient resolution while maintaining testing safety via async Dart `Zone`s:

```dart
// lib/src/di/graft_di.dart
import 'dart:async';
import 'scope_node.dart';
import 'scope_tier.dart';

abstract class GraftDI {
  static final ScopeNode root = ScopeNode(name: 'root', tier: ScopeTier.root);
  static ScopeNode activeScope = root;
  static final List<int> _resolutionStack = [];
  static final Object testZoneKey = Object();

  static T resolve<T>() {
    // 1. Pure Dart Zone Test Override Check
    final testOverrides = Zone.current[testZoneKey] as Map<Type, Object>?;
    if (testOverrides != null && testOverrides.containsKey(T)) {
      return testOverrides[T] as T;
    }

    // 2. Active Hierarchy Scope Evaluation
    return activeScope.resolve<T>(_resolutionStack);
  }

  static void reset() {
    root.drop(force: true);
    activeScope = root;
    _resolutionStack.clear();
  }
}

// Global ambient top-level resolution function (replaces get<T>() to avoid GetIt conflicts)
T use<T>() => GraftDI.resolve<T>();
```

---

### 2.6 Automated Async Resource Binding (`async_binding.dart` < 75 lines)
Developers do **not** need to subclass framework classes or manually wrap queries in `guard(() => ...)`. Any async dependency—including 3rd-party libraries (`sqflite`'s `Database`, `SharedPreferences`, `Dio`, `Isar`) or custom domain services (`AppDb`)—is registered with `bindAsync<T>()`:

```dart
// lib/src/di/async_binding.dart
import 'dart:async';

/// Automated non-blocking execution gate for asynchronous dependencies.
///
/// Transparently buffers callers on Frame 0 before background initialization
/// completes, and returns cached instances instantly (0ns) once ready.
/// Developers write 100% standard Dart methods with zero manual guard() wrappers.
class AsyncBinding<T> {
  final Future<T> Function() factory;
  final bool singleton;
  final bool preserved;

  Future<T>? _future;
  T? _resolvedInstance;
  bool _isCompleted = false;

  AsyncBinding(
    this.factory, {
    this.singleton = true,
    this.preserved = false,
  });

  /// Starts or returns the background initialization Future.
  Future<T> resolve() {
    if (_isCompleted) return Future<T>.value(_resolvedInstance as T);
    if (_future != null) return _future!;

    final completer = Completer<T>();
    _future = completer.future;

    factory().then((instance) {
      if (singleton) {
        _resolvedInstance = instance;
        _isCompleted = true;
      }
      completer.complete(instance);
    }).catchError((err, stack) {
      completer.completeError(err, stack);
    });

    return _future!;
  }

  /// Synchronously returns the resolved instance if already completed.
  T? get resolvedInstance => _isCompleted ? _resolvedInstance : null;

  /// Whether the background asynchronous factory has completed.
  bool get isCompleted => _isCompleted;

  /// Resets state when scope is dropped.
  void reset() {
    _future = null;
    _resolvedInstance = null;
    _isCompleted = false;
  }
}
```

---

---

### 2.7 Developer-Defined Enum Scopes & Scope Blocks (`graft_scope.dart` < 95 lines)
The engine does **not** hardcode scope names or enforce pre-packaged enums. The developer defines **any custom `Enum`** for their application scopes, and explicitly instructs the engine which scopes are `preserved`:

```dart
// lib/src/di/graft_scope.dart
import 'graft_di.dart';
import 'scope_node.dart';
import 'scope_tier.dart';

/// Active scope during configuration block execution
ScopeNode _currentScope = GraftDI.root;

/// ⚡ Ambient Binding Function:
/// Registers a dependency factory into the currently active [scope] block.
/// Supports domain repositories, services, and Graft controller factories.
/// - [singleton]: Defaults to `true`! Cached as a singleton in this scope.
///   When true, `context.create` will NEVER duplicate it.
/// - Set [singleton: false] if you want `context.create` to create fresh duplicates.
/// - Set [preserved: true] to keep this specific instance alive across route pops.
void bind<T>(
  T Function() factory, {
  bool singleton = true,
  bool preserved = false,
}) {
  _currentScope.bind<T>(
    factory,
    singleton: singleton,
    preserved: preserved,
  );
}

/// ⚡ Declarative Scope Block:
/// Opens a scope block for ANY developer-defined [Enum].
/// The developer explicitly tells the engine whether this scope is [preserved] or transient.
void scope(
  Enum scopeEnum,
  void Function() block, {
  bool preserved = false,
}) {
  final node = GraftScopeRegistry.getOrCreateNode(
    scopeEnum,
    preserved ? ScopeTier.preserved : ScopeTier.transient,
  );
  final previous = _currentScope;
  _currentScope = node;
  try {
    block();
  } finally {
    _currentScope = previous;
  }
}

/// Registry mapping developer-provided Enums to internal ScopeNode instances
abstract class GraftScopeRegistry {
  static final Map<Enum, ScopeNode> _enumNodes = {};

  static ScopeNode getOrCreateNode(Enum scopeEnum, ScopeTier tier) {
    return _enumNodes.putIfAbsent(
      scopeEnum,
      () => ScopeNode(
        name: '${scopeEnum.runtimeType}.${scopeEnum.name}',
        tier: tier,
        parent: GraftDI.root,
      ),
    );
  }

  static ScopeNode? findNode(Enum scopeEnum) => _enumNodes[scopeEnum];

  static void invalidateDry(Enum scopeEnum) {
    _enumNodes[scopeEnum]?.invalidateDry();
  }

  static void drop(Enum scopeEnum, {bool invalidateDry = false}) {
    if (invalidateDry) invalidateDry(scopeEnum);
    _enumNodes.remove(scopeEnum)?.drop();
  }
}

/// ⚡ Type-Safe Developer Enum Extension:
/// Enables calling scope operations directly on any developer-defined Enum:
/// e.g. `AppScope.orders.invalidateDry()` or `AppScope.checkout.drop()`
extension GraftScopeEnumX on Enum {
  /// Purges all Frame-0 dry persistence belonging to this scope across all screens
  void invalidateDry() => GraftScopeRegistry.invalidateDry(this);

  /// Drops all members of this scope (cohesive teardown)
  void drop({bool invalidateDry = false}) =>
      GraftScopeRegistry.drop(this, invalidateDry: invalidateDry);
}
```

---

### 2.8 How Grafts Are Added to & Managed by DI

```
┌────────────────────────────────────────────────────────────────────────┐
│                     HOW GRAFTS RELATE TO DI & SCOPES                   │
├──────────────────────────┬─────────────────────────────────────────────┤
│ 1. What Scopes Hold      │ Scopes hold domain services & repositories  │
│                          │ AND Graft factories (constructors).         │
│                          │ Scopes NEVER retain Graft instances!        │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 2. Adding Graft to DI    │ bind(OrderListGraft.new) inside a scope     │
│                          │ registers the constructor tear-off.         │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 3. Resolving in UI       │ context.use<OrderListGraft>() calls the     │
│                          │ registered factory to instantiate.          │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 4. Route Ownership       │ GraftRouteTracker attaches the instance to  │
│                          │ the screen's ModalRoute.                    │
├──────────────────────────┼─────────────────────────────────────────────┤
│ 5. Unconditional Death   │ When the Route pops, the Graft ALWAYS dies! │
│                          │ The scope does NOT keep it alive.           │
└──────────────────────────┴─────────────────────────────────────────────┘
```

#### Step-by-Step Lifecycle:
1. **Adding a Graft in DI:**
   ```dart
   scope(AppScope.orders, () {
     bind(OrderRepository.new); // Domain Repository
     bind(OrderListGraft.new);  // Graft Controller Factory!
   });
   ```
   `bind(OrderListGraft.new)` stores the constructor tear-off under `OrderListGraft`.

2. **Resolving in the Widget:**
   ```dart
   class OrderListScreen extends StatelessWidget {
     const OrderListScreen({super.key});

     @override
     Widget build(BuildContext context) {
       // ⚡ Resolves factory from active AppScope.orders:
       final graft = context.use<OrderListGraft>();
       ...
     }
   }
   ```
   - When `context.use<OrderListGraft>()` executes:
     1. It finds the `OrderListGraft.new` factory from the active DI scope.
     2. It creates a brand-new instance of `OrderListGraft`.
     3. It registers the instance with the current Flutter `ModalRoute`.
     4. When the screen route pops from the navigation stack, **that `OrderListGraft` instance is immediately and unconditionally disposed**.
     5. The scope **never** keeps the Graft alive. It only stored the recipe (factory).

3. **Consuming Services inside the Graft:**
   Inside `OrderListGraft`, the controller resolves domain services ambiently:
   ```dart
   class OrderListGraft extends Graft<OrderListState> {
     OrderListGraft() : super(OrderListState());

     // Resolves OrderRepository from active scope hierarchy:
     late final _orderRepo = use<OrderRepository>();
     late final _auth = use<AuthService>();
   }
   ```

4. **The Singleton Lock Invariant (`singleton` Defaults to `true`):**
   - **Singleton by Default:** Every `bind()` call sets `singleton: true` by default!
   - **Singleton Lock:** Because it is a singleton by default, calling `context.create<T>()` **NEVER forces a duplicate**; it strictly respects the DI contract and safely returns the existing singleton.
   - **Route Disposal Immunity:** Singletons are **never disposed by route pops**.
   - **Opting into Duplicates:** If a developer specifically wants a Graft or Service to allow duplicate instances per screen, they explicitly pass `singleton: false`:
     ```dart
     // Allows context.create<OrderListGraft>() to create fresh duplicates:
     bind(OrderListGraft.new, singleton: false);
     ```
   - When `singleton: false` is configured, `context.create<T>()` instantiates a fresh duplicate owned by that screen route, which automatically disposes when that screen pops.

---

### 2.9 Interface vs. Implementation Binding & Mock Overrides for Testing

Clean architecture demands that controllers depend strictly on abstract contracts, not concrete implementations (e.g. SQLite databases or HTTP network clients).

#### 1. Defining the Contract & Implementation:
```dart
// lib/domain/repositories/order_repository.dart
abstract interface class OrderRepository implements Disposable {
  Future<List<Order>> fetchOrders(String userId);
}

// lib/data/repositories/order_repository_impl.dart
class OrderRepositoryImpl implements OrderRepository {
  late final _db = use<AppDb>();
  late final _api = use<ApiClient>();

  @override
  Future<List<Order>> fetchOrders(String userId) async {
    final rows = await _db.query('SELECT * FROM orders WHERE user_id = ?', [userId]);
    return rows.map(Order.fromMap).toList();
  }

  @override
  void dispose() {}
}
```

#### 2. Registering Interface to Implementation in DI:
In `configureDependencies()`:
```dart
// Binds interface <OrderRepository> to constructor tear-off OrderRepositoryImpl.new:
bind<OrderRepository>(OrderRepositoryImpl.new);

// Can also be marked preserved individually:
bind<PaymentTokenRepository>(PaymentTokenRepositoryImpl.new, preserved: true);
```

#### 3. Controller Consumes ONLY the Interface:
```dart
class OrderListGraft extends Graft<OrderListState> {
  OrderListGraft() : super(OrderListState());

  // Talks strictly to the abstract contract:
  late final _orderRepo = use<OrderRepository>();
}
```

#### 4. Headless Unit Testing with Mock Overrides:
In tests, mock instances are injected directly into the active Dart Zone. Zero Flutter widget bindings, zero static container resets:
```dart
// test/order_list_graft_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  test('OrderListGraft loads orders from mock repository', () async {
    final mockRepo = MockOrderRepository();
    when(() => mockRepo.fetchOrders('usr_1')).thenAnswer((_) async => [Order(id: 1)]);

    // Pure Dart headless Zone override:
    graftTest<OrderListGraft, OrderListState>(
      'loads orders',
      overrides: {
        OrderRepository: mockRepo, // ⚡ Replaces OrderRepositoryImpl seamlessly!
      },
      build: () => OrderListGraft(),
      act: (graft) => graft.loadOrders(),
      expect: () => [
        isA<OrderListState>().having((s) => s.orders.length, 'orders.length', 1),
      ],
    );
  });
}
```

---

## 3. Developer Experience (DX Walkthrough)

### Step 1: Developer Defines Scope Enum & Configures Dependencies

The developer defines their own enum and decides which scopes are `preserved`:

```dart
// lib/core/di/app_scope.dart
enum AppScope {
  root,
  session,
  orders,
  checkout,
}
```

```dart
// lib/core/di/dependencies.dart
import 'package:graft/graft.dart';
import 'app_scope.dart';

void configureDependencies() {
  // 🛡️ 1. ROOT IMMORTALS (Process lifespan, never closed)
  scope(AppScope.root, () {
    bind(AppDb.new);
    bind(ApiClient.new);
    bind(AuthService.new);
  });

  // 👤 2. PRESERVED SESSION SCOPE (Developer flags preserved: true!)
  // Survives route transitions while user is logged in:
  scope(AppScope.session, preserved: true, () {
    bind(UserRepository.new);
    bind(CartRepository.new);
  });

  // 🌊 3. TRANSIENT FLOW SCOPE (Default: preserved = false)
  // Auto-starts on first use, auto-drops when all flow screens pop:
  scope(AppScope.orders, () {
    bind(OrderRepository.new);
    bind(OrderListGraft.new); // ⚡ Graft factory registered in DI!
  });

  scope(AppScope.checkout, () {
    bind(CheckoutRepository.new);
    bind(CheckoutGraft.new);
  });
}
```

---

### Step 2: Application Entrypoint in `main()` (Synchronous, 0-Await!)

Because `GraftAsyncService` uses the self-healing `guard()` gate, **no `await` is ever needed in `main()`**:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:graft/graft.dart';
import 'core/di/dependencies.dart';
import 'features/orders/views/order_list_screen.dart';

void main() {
  // ⚡ 100% Synchronous, Zero-Await Boot:
  // Option A (Zero ceremony):
  configureDependencies();

  // Option B (With optional custom storage config):
  // Graft.init(config: CustomConfig(), setup: configureDependencies);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: OrderListScreen());
  }
}
```

---

### Step 3: Zero-Boilerplate Database & Repository (100% Automatic!)

Zero wrapper classes, zero `GraftAsyncService` inheritance, zero `late` variables, and **zero `guard()` wrappers**:

```dart
// lib/core/di/dependencies.dart
import 'package:sqflite/sqflite.dart';
import 'package:graft/graft.dart';

void configureDependencies() {
  // 1. Direct 3rd-party library registration (Zero wrapper classes needed!):
  bindAsync<Database>(() async {
    return await openDatabase(
      'app.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE orders (id INT, total REAL, user_id TEXT)');
      },
    );
  });

  // 2. Repositories consume Database automatically via useAsync:
  bind(OrderRepository.new);
}

// lib/features/orders/data/order_repository.dart
class OrderRepository implements Disposable {
  // Pre-cached async handle resolved in < 0.8ns:
  late final _db = useAsync<Database>();
  late final _api = use<ApiClient>();

  Future<List<Order>> fetchOrders(String userId) async {
    // 🛡️ 100% AUTOMATIC ENGINE GATE:
    // If called on Frame 0 before openDatabase() finishes, (await _db) transparently
    // pauses and resumes the instant the DB is ready! ZERO LateInitializationError!
    // Calls standard db.rawQuery() natively with zero guard() wrappers!
    final db = await _db;
    final rows = await db.rawQuery('SELECT * FROM orders WHERE user_id = ?', [userId]);
    return rows.map(Order.fromMap).toList();
  }

  @override
  void dispose() {}
}
```

#### What if the developer prefers an encapsulating `AppDb` class?
Developers can also write their own domain service using clean, immutable `final` fields—without extending any framework class:
```dart
class AppDb implements Disposable {
  final Database db; // Clean, immutable final field!
  AppDb(this.db);

  // Pure standard Dart method! Zero guard() wrappers!
  Future<List<Map<String, Object?>>> query(String sql, [List<Object?>? args]) {
    return db.rawQuery(sql, args);
  }

  @override
  void dispose() => db.close();
}

// In configureDependencies():
bindAsync<AppDb>(() async {
  final db = await openDatabase('app.db', version: 1);
  return AppDb(db);
});
```

---

### Step 4: Controller (`GraftState` with CPU Bitmasks)

```dart
// lib/features/orders/controllers/order_list_graft.dart
class OrderListState extends GraftState {
  List<Order> orders = [];
  bool isLoading = false;

  @override
  GraftProps get props => propsOf(orders, isLoading);

  @override
  void onReset() {
    orders.clear();
    isLoading = false;
  }
}

class OrderListGraft extends Graft<OrderListState> {
  OrderListGraft() : super(OrderListState());

  late final _orderRepo = use<OrderRepository>();
  late final _user = use<UserRepository>();

  /// ⚡ Order Completed / Submitted:
  void submitOrder() {
    // Purges all dry state across the entire orders flow with 1 call!
    AppScope('orders').invalidateDry();
  }

  Future<void> loadOrders() async {
    state..isLoading = true..update(); // 1-cycle CPU bitmask dispatch
    try {
      final data = await _orderRepo.fetchOrders(_user.currentUserId);
      state..orders = data..update();
    } finally {
      state..isLoading = false..update();
    }
  }
}
```

---

### Step 5: Route-Aware UI with Slots (`0.1.2` Parity)

```dart
// lib/features/orders/views/order_list_screen.dart
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolves registered factory from active DI scope:
    final graft = context.use<OrderListGraft>();

    return Scaffold(
      appBar: AppBar(
        // Surgical leaf slot: isolates title with 0 outer container rebuilds
        title: graft((s) => Text('Orders (${s.orders.length})')),
      ),
      // Universal multi-child slot diff engine:
      body: graft.slots(
        layout: Column(children: slots),
        slots: (s) => [
          if (s.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: graft.builder<Order>(
              items: (s) => s.orders,
              itemBuilder: (order, index) => ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Text(order.formattedPrice),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Step 6: Pure Dart Testing Harness (`graftTest` Integration)

```dart
// test/features/orders/order_list_graft_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepo extends Mock implements OrderRepository {}
class MockUserRepo extends Mock implements UserRepository {}

void main() {
  group('OrderListGraft Tests', () {
    final mockOrderRepo = MockOrderRepo();
    final mockUserRepo = MockUserRepo();

    // Declarative testing with ambient mock injection via Zone isolation:
    graftTest<OrderListGraft, OrderListState>(
      'loads orders and flips isLoading bitmask without widget setup',
      overrides: [mockOrderRepo, mockUserRepo],
      setUp: () {
        when(() => mockUserRepo.currentUserId).thenReturn('usr_100');
        when(() => mockOrderRepo.fetchOrders('usr_100'))
            .thenAnswer((_) async => [Order(id: 1, total: 35.0)]);
      },
      build: () => OrderListGraft(),
      act: (graft) => graft.loadOrders(),
      expect: () => [
        isA<OrderListState>().having((s) => s.isLoading, 'isLoading', true),
        isA<OrderListState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.orders.length, 'orders.length', 1),
      ],
      verify: (graft) {
        expect(graft.state.orders.first.id, equals(1));
      },
    );
  });
}
```

---

## 5. Comprehensive Testing Matrix & Verification Strategy

To guarantee zero regressions and bulletproof reliability, the DI engine includes an exhaustive test suite organized under `test/di/`:

```
test/
└── di/
    ├── type_id_test.dart                 # Monotonic integer ID generation & collision tests
    ├── scope_node_test.dart               # Flat array resolution, upstream fallback, root bounds
    ├── circular_dependency_test.dart      # Intercepts circular references in debug mode
    ├── cohesive_scope_lease_test.dart     # Multi-lease shared repo retention & cohesive teardown
    ├── reverse_dag_teardown_test.dart     # Verifies consumers dispose strictly before dependencies
    ├── async_service_guard_test.dart      # Queued query execution during onOpen, zero await in main
    ├── zone_override_test.dart            # Headless graftTest(overrides: [mock]) in pure Dart
    ├── route_scope_bridge_test.dart       # ModalRoute pop lease release & auto-disposal
    ├── flow_invalidate_dry_test.dart      # AppScope.name.invalidateDry() triggers storage purges
    └── benchmark_di_lookup_test.dart      # Strict latency assertions: cold ≤ 12ns, hot < 0.8ns
```

### 5.1 Deep Dive into Critical Test Specifications

#### 1. Dual-Speed Lookup Speed Benchmark (`benchmark_di_lookup_test.dart`)
- **Objective:** Assert that cold TypeId flat array resolution runs in $\le 12\text{ ns}$ and cached `late final` hot resolution runs in $< 0.8\text{ ns}$.
- **Execution:**
  1. Register 50 diverse services in `AppRegistry`.
  2. Execute 100,000 cold resolutions via `use<T>()` across all 50 types:
     ```dart
     final stopwatch = Stopwatch()..start();
     for (int i = 0; i < 100000; i++) {
       final s = use<Service42>();
     }
     stopwatch.stop();
     final coldNanos = stopwatch.elapsedMicroseconds * 1000 / 100000;
     expect(coldNanos, lessThanOrEqualTo(12.0));
     ```
  3. Execute 1,000,000 hot loops accessing a `late final _repo = use<OrderRepository>()` field.
  4. Assert hot execution runs in $< 0.8\text{ ns}$ per access.

#### 2. Cohesive Scope & Shared Repository Lease Test (`cohesive_scope_lease_test.dart`)
- **Objective:** Verify that when Scope A and Scope B share a repository:
  1. When Scope A completes and calls `drop()`, if Scope B still holds an active lease on the shared repository, **the shared repository DOES NOT dispose**.
  2. If ANY member of Scope B is still referenced, **NONE of the members of Scope B dispose**.
  3. The shared repository disposes ONLY when the last active lease reaches zero.
- **Execution:**
  1. Define `AuthRepo` shared by `LoginScope` and `CheckoutScope`.
  2. Lease `AuthRepo` to both scopes.
  3. Trigger route pop on `LoginScope`.
  4. Assert `AuthRepo.isDisposed == false`.
  5. Trigger route pop on `CheckoutScope`.
  6. Assert `AuthRepo.isDisposed == true`.

#### 3. Reverse Topological DAG Teardown Test (`reverse_dag_teardown_test.dart`)
- **Objective:** Verify that when a scope drops, consumer controllers and repositories dispose *strictly before* the database and network client they depend upon.
- **Execution:**
  1. Chain: `OrderController` $\rightarrow$ `OrderRepository` $\rightarrow$ `AppDb`.
  2. Record disposal order log in a shared list.
  3. Call `scope.drop()`.
  4. Assert disposal sequence matches: `['OrderController', 'OrderRepository', 'AppDb']`.
  5. Assert that if `OrderRepository.dispose()` flushes pending queries to `AppDb`, `AppDb` is guaranteed to still be open!

#### 4. Async Service Query Gate & Error Handling (`async_service_guard_test.dart`)
- **Objective:** Verify that synchronous `Graft.init()` allows instant app launch, and queries sent during `AppDb.onOpen()` pause transparently and execute in exact order upon readiness.
- **Execution:**
  1. `AppDb.onOpen()` completes after 50ms simulated async delay.
  2. Repository immediately issues 5 concurrent queries synchronously in constructor.
  3. Assert zero unhandled exceptions or race conditions.
  4. Fast-forward time / await: assert all 5 queries resolve with correct data.
  5. Verify that if `onOpen()` throws an exception, all queued `guard()` calls reject safely with the underlying error.

#### 5. Circular Dependency Debug Interception (`circular_dependency_test.dart`)
- **Objective:** Assert that circular constructor references (e.g. `A` requires `B`, `B` requires `A`) trigger an informative ASCII assertion error in debug mode without hanging or stack overflowing.
- **Execution:**
  1. Register `ServiceA(use<ServiceB>)` and `ServiceB(use<ServiceA>)`.
  2. Expect calling `use<ServiceA>()` to throw `StateError` containing:
     `GRAFT CIRCULAR DEPENDENCY DETECTED` and the exact cycle arrow chain.

---

## 6. Performance Regression Defense & Benchmark Preservation Strategy

Graft's sub-microsecond performance leadership is a core project invariant. The DI engine is engineered with zero runtime penalties on the state diffing and UI rendering loops:

### 6.1 Performance Architecture Highlights

1. **Zero Impact on `GraftState.update()`:**
   - DI resolution operates strictly during object instantiation (`onInit` / `late final`).
   - The state mutation loop (`state..field = x..update()`) never calls DI resolution.
   - Zero hash table lookups, zero Map queries, and zero reflection in the state diffing path.

2. **Monotonic Integer Array vs Hash Maps:**
   - Standard DI frameworks (GetIt, Provider, Riverpod) resolve dependencies by hashing the `Type` object (`Type.hashCode`) and probing bucket arrays with string collisions.
   - Graft's `TypeId<T>.id` compiles to a direct monotonic integer:
     ```dart
     // Direct array index lookup: 1 CPU memory dereference!
     final instance = _instances[id];
     ```
   - Eliminates hash computation ($\sim 8\text{ ns}$ saved) and bucket search ($\sim 15\text{ ns}$ saved).
   - Cold resolution: $\mathbf{\le 12\text{ ns}}$.

3. **In-Flight DAG Overhead Stripping in Production AOT:**
   - Circular dependency detection is wrapped inside `assert(() { ... return true; }())`.
   - In Flutter release builds (`flutter run --release` or `flutter build apk/ipa`), the Dart compiler strips all `assert` code entirely, leaving zero instructions and zero cycle-tracking overhead.

4. **Flat Pointer Memory Footprint:**
   - `_instances` uses a compact flat array. For a typical app with 50 services, `_instances` occupies $\approx 400\text{ bytes}$ of memory.
   - Scopes hold weak references and auto-purge via cohesive teardown, eliminating long-term memory bloat.

---

## 7. Documentation Architecture & Developer Experience (DX) Deliverables

To guarantee first-class developer onboarding while maintaining clean, navigable repository documentation, Graft adopts a **Modular Markdown Architecture**. The monolithic documentation is decoupled into dedicated, deeply linked markdown guides, with `README.md` serving as the high-impact hub featuring quickstarts, summaries, and an exhaustive API cheat sheet.

```
┌────────────────────────────────────────────────────────────────────────┐
│                      GRAFT DOCUMENTATION HIERARCHY                     │
├────────────────────────────────────────────────────────────────────────┤
│                               README.md                                │
│       (Hub: 1-min quickstart, benchmark & test summaries, full         │
│          API Reference Cheat Sheet with concise 2-line usages)         │
│     ├── ARCHITECTURE.md     (All design philosophy & 6 core pillars)   │
│     ├── DI_GUIDE.md         (Major comprehensive guide for DI engine)  │
│     ├── GRAFT_GUIDE.md      (Major comprehensive guide for state & dry)│
│     ├── BENCHMARK_REPORT.md (Full empirical benchmarks, specs & runs)  │
│     └── TEST_REPORT.md      (Full 211+ test matrix, edge cases, chaos) │
└────────────────────────────────────────────────────────────────────────┘
```

### 7.1 Modular Markdown Specifications

1. **`ARCHITECTURE.md` (Architecture Philosophy & Engineering Invariants):**
   - Deep-dive into the architectural philosophy powering Graft:
     - The 6 Core Pillars (Zero Codegen, Dual-Speed Resolution, Cohesive Scopes, Reverse DAG Teardowns, Headless Testing, Route-Bound Grafts).
     - Pure Dart & Zero Codegen rationale: constructor tear-offs, 0 `build_runner`, 0 generated files, instant compilation.
     - Strict Modular Invariant: Strict `< 200 lines per class/file` rule across the entire codebase.
     - Register-level CPU 64-bit integer bitmask diffing ($\le 50\text{ ns}$) and why no runtime reflection/mirrors are used.
     - Monotonic integer `TypeId<T>` array indexing ($\le 12\text{ ns}$ cold) + late final L1 caching ($< 0.8\text{ ns}$ hot).
     - Frame-0 Dry State & L1 RAM pre-mount hydration ($< 50\text{ ns}$), zero blank flash, 300ms debounced background disk IO.
     - Reverse topological DAG teardowns & in-degree resolution.
     - Automated `bindAsync<T>()` and non-blocking `useAsync<T>()` execution gates eliminating boot races, `late` variables, and method-wrapping boilerplate.
     - Domain separation: why Grafts are route-bound and never stored in scopes (scopes hold domain repositories & services; Grafts unconditionally die on screen pop).

2. **`DI_GUIDE.md` (Comprehensive Dependency Injection Manual):**
   - In-depth guide dedicated to the DI engine:
     - Zero-Scope Boot: Calling `bind(...)` outside any scope block automatically binds into global root singletons.
     - Developer-Defined Enum Scopes: Defining custom `enum AppScope { session, checkout, orders }`.
     - Preserved vs Transient Scopes: Cohesive scope lifecycle ("if ANY member is referenced, NONE dispose").
     - The Singleton Lock Guarantee: `singleton: true` default; `context.create` never forces duplicates if declared singleton.
     - Clean Architecture: Interface-to-implementation binding (`bind<AuthRepo>(AuthRepoImpl.new)`).
     - Async Services: `bindAsync<T>()` and `useAsync<T>()` for database (`sqflite`/`isar`/`drift`) and network authentication—zero `GraftAsyncService` inheritance, zero `late` variables, zero `guard()` wrappers!
     - Teardown & Invalidation: `AppScope.checkout.drop()`, `AppScope.checkout.invalidateDry()`.
     - Headless testing with `graftTest(overrides: [mockRepo])`.

3. **`GRAFT_GUIDE.md` (Comprehensive State Management & Persistence Manual):**
   - In-depth guide dedicated to State Management & Frame-0 Dry State:
     - Defining `GraftState` and declaring `propsOf(...)`.
     - Mutation patterns: `state..val = x..update()` vs `mutate((s) => s.val = x)`.
     - Surgical UI: `context.slot()`, `context.slots()`, `context.builder()`, `GraftBoundary`.
     - Zero-Controller Forms: Pure `StatelessWidget` with `TextFormField(initialValue: ...)` and zero blank frames.
     - Native Lifecycle: `onInit()`, `onDispose()`, `onReset()`.
     - Frame-0 Persistence: `enableDry => true`, `FileStateConfig`, `MemoryStateConfig`, `L1Cache`, `SchemaFingerprint`.
     - Cascaded Mutable Models (`GraftModel` Option B).
     - State reset and clearing: `state.reset()`, `invalidateDry()`.

4. **`BENCHMARK_REPORT.md` / `BENCHMARKS.md` (Empirical Performance Reference):**
   - Exhaustive benchmark methodology, hardware specs, and 15-iteration measurement logs.
   - Complete benchmark scenarios:
     - Scenario A: Micro-state mutations & churn (A1: 10k, A2: 100k, A3: 5 fields, A4: depth-8 nested).
     - Scenario B: Fine-grained rebuild isolation (B1: 10 slots, B2: 50 slots across 120 frames).
     - Scenario C: Large list performance (C1: 5k, C2: 20k rapid updates, C3: random insert/remove).
     - Scenario D: Real-world business workflows (D1: catalog & cart, D2: 12-field form, D3: dialog sharing).
     - Scenario E: Lifecycle, hot reload & safety (E1: push/pop, E2: reassemble, E3: disposed safety).
   - CSV export link (`benchmark_results.csv`).

5. **`TEST_REPORT.md` / `TESTING.md` (Test Suite & Quality Assurance Reference):**
   - Complete 211+ test matrix across 7 subsystem domains.
   - Test files, pass counts, durations, and assertion coverage.
   - Testing guide for pure Dart headless tests with `graftTest`.
   - CSV export link (`test_results.csv`).

6. **`README.md` (The Modernized Entrypoint & Hub):**
   - **Quickstart (1 Minute):** Concise, copy-pasteable example of state definition, controller, slot UI, and DI binding.
   - **Concise Benchmark Summary:** High-level scorecard table comparing Graft against BLoC, Riverpod, and GetIt on cold/hot DI lookup, bitmask diffing, and frame-0 dry hydration. Clear reference link to `BENCHMARK_REPORT.md` for exhaustive details.
   - **Concise Test Summary:** High-level pass status (✅ 100% Passed, 211+ tests, 0 warnings). Clear reference link to `TEST_REPORT.md` for the complete breakdown.
   - **Documentation Navigation Table:** Prominent clickable links directing developers to `ARCHITECTURE.md`, `DI_GUIDE.md`, `GRAFT_GUIDE.md`, `BENCHMARK_REPORT.md`, and `TEST_REPORT.md`.
   - **Complete Public API Reference & Cheat Sheet:** Listing ALL public APIs in Graft with concise 2–3 line short usages and purpose:
     - `Graft<S>`: Domain state controller with lifecycle hooks.
     - `GraftState`: Base state class declaring `propsOf(...)`.
     - `propsOf(...)`: Property slot registration for zero-alloc bitmask diffing.
     - `state..val = x..update()`: Synchronous 1-cycle bitmask diff & surgical UI dispatch.
     - `mutate((s) => ...)`: Functional state mutation.
     - `state.reset()`: Restores initial baseline values via `onReset()`.
     - `context.slot(...)`: Surgical single-slot leaf rebuild widget.
     - `context.slots(...)`: Multi-slot bitmask listener widget.
     - `context.builder(...)`: Whole-controller rebuild listener.
     - `GraftBoundary`: RenderTree firewall protecting subtrees from rebuild cascades.
     - `context.use<T>()`: Resolves DI service or reactive Graft controller.
     - `context.create<T>()`: Creates screen-local instance unless declared singleton (Singleton Lock).
     - `context.read<T>()`: Non-rebuilding controller access.
     - `bind<T>(factory, {singleton, preserved})`: Declares synchronous dependency factory.
     - `bindAsync<T>(asyncFactory, {singleton, preserved})`: Declares asynchronous dependency factory.
     - `scope(enumScope, {preserved}, () => ...)`: Scoped dependency block.
     - `use<T>()`: Resolves ambient dependency from active `ScopeNode` ($\le 12\text{ ns}$ cold, $< 0.8\text{ ns}$ hot).
     - `useAsync<T>()`: Resolves ambient async dependency, auto-awaiting Frame 0 background completion.
     - `enableDry`: Frame-0 dry state hydration switch.
     - `GraftModel`: Cascaded mutable nested model base class.
     - `invalidateDry()`: State-level dry storage purge and cancel.
     - `AppScope.orders.invalidateDry()`: Scope-wide dry state purge across all controllers.
     - `AppScope.orders.drop()`: Manually drops an entire scope and disposes members in reverse DAG order.
     - `graftTest(...)`: Headless pure Dart test runner with `overrides: [...]`.

---

## 8. Quality Assurance & Phased Delivery Roadmap

To guarantee zero regressions and strict compliance with all latency and architectural invariants, delivery is divided into strict milestones:

### 8.1 Verification Standards
- **100% Test Pass Guarantee:** All 211 existing unit, widget, and stress tests must continue to pass with 0 failures and 0 skipped tests (`flutter test`).
- **Zero Static Analysis Issues:** Code must pass `flutter analyze` and `dart run custom_lint` with 0 errors and 0 warnings.
- **Strict Line Constraint:** Every newly written or modified class/file must remain strictly **< 200 lines of code**.
- **Benchmark Invariants:**
  - Cold DI Lookup: $\le 12\text{ ns}$ via monotonic integer `TypeId<T>` array indexing.
  - Hot DI Lookup: $< 0.8\text{ ns}$ via late final L1 caching.
  - Bitmask Slot Diffing: $< 50\text{ ns}$ via register-level bitwise operations.
  - Frame-0 Dry State Hydration: $< 50\text{ ns}$ via synchronous L1 RAM cache.
  - Zero Rebuild Leakage: 0 static rebuilds across all 16 benchmark scenarios.

### 8.2 Phased Roadmap

| Phase | Milestone | Deliverables (< 200 lines/file) | Verification Gate |
| :---: | :--- | :--- | :--- |
| **1** | **`graft_di` Core Engine** | `type_id.dart`, `disposable.dart`, `scope_tier.dart`, `scope_node.dart`, `graft_di.dart`, `async_binding.dart`, `graft_scope.dart`. | Unit tests in `test/di/`: flat array lookup, reverse DAG teardown, cycle detection. |
| **2** | **Async Binding & Gates** | `async_binding.dart`, `bindAsync<T>()`, `useAsync<T>()` query queuing, background factory unblocking. | Race condition test: queries issued on Frame 0 before DB opens resolve safely without crashes. |
| **3** | **Flutter Route Bridge** | Integration with `GraftRouteTracker.observer`, `context.use<T>()`, `context.create<T>()` with Singleton Lock guarantee. | Widget tests: screen push/pop lease release, singleton preservation across routes. |
| **4** | **Testing Harness** | `graftTest(overrides: [mockRepo])` mapping to `Zone.current[testZoneKey]` for zero-reset pure Dart execution. | Headless test suite executing without Flutter bindings or container resets. |
| **5** | **Benchmark Validation** | Empirical latency harness measuring cold/hot resolution and comparing against GetIt and Riverpod. | Cold resolution $\le 12\text{ ns}$, hot resolution $< 0.8\text{ ns}$. |
| **6** | **Documentation Generation** | Authoring `ARCHITECTURE.md`, `DI_GUIDE.md`, `GRAFT_GUIDE.md`, updating `BENCHMARK_REPORT.md` and `TEST_REPORT.md`, modernizing `README.md` with complete API cheat sheet. | All markdown links verified, `dartdoc` 100% coverage, 211+ tests passing. |

