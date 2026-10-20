# Graft Dependency Injection (DI) Engine: Complete Developer Guide

---

## 🚀 Overview

Graft includes a specialized, high-performance Dependency Injection engine engineered specifically for Flutter:
- **Sub-Nanosecond Lookups:** Monotonic 32-bit integer indexing (`TypeId.of<T>()`) eliminates string hashing and runtime reflection ($\le 12\text{ ns}$ cold lookup, $< 0.8\text{ ns}$ hot lookup).
- **In-Degree Topological Reverse DAG Teardown:** Dependent consumers are guaranteed to be disposed **before** their underlying dependencies, preventing dangling pointer crashes and connection leaks.
- **Self-Healing Non-Blocking Async Gates:** `bindAsync<T>()` and `useAsync<T>()` allow lazy database, network, and storage services to initialize in the background without blocking application startup on Frame 0 or forcing developers to write boilerplate method wrappers.
- **Developer Enum Scopes:** Group dependencies under type-safe enums (`enum AppScope { auth, checkout }`) with declarative `scope(...)` blocks and flow-wide `AppScope.checkout.drop()`.
- **Route Leasing:** Automatically bind services to navigation routes and release them when the route pops.

---

## 📖 Table of Contents
1. [Core DI Principles & Performance](#core-di-principles--performance)
2. [Registering Dependencies (`bind` & `bindAsync`)](#registering-dependencies-bind--bindasync)
3. [Resolving Dependencies (`use` & `useAsync`)](#resolving-dependencies-use--useasync)
4. [Developer Enum Scopes & Flow Management](#developer-enum-scopes--flow-management)
5. [Route Leasing & Automatic Route Disposal](#route-leasing--automatic-route-disposal)
6. [Non-Blocking Async Database & Network Services](#non-blocking-async-database--network-services)
7. [In-Degree Reverse DAG Teardown](#in-degree-reverse-dag-teardown)
8. [Testing, Zone Mock Overrides & Real Database Verification](#testing-zone-mock-overrides--real-database-verification)
9. [Complete Real-World Example (Production Architecture)](#complete-real-world-example-production-architecture)
10. [Related Technical Guides & Reports](#related-technical-guides--reports)

---

## Core DI Principles & Performance

| Metric / Feature | Graft DI Engine | Traditional Service Locators |
|---|---|---|
| **Lookup Mechanism** | Monotonic Integer (`TypeId.of<T>()`) Flat Array | String Hash Map / Bucket Probe |
| **Hot Lookup Latency** | **$< 0.8\text{ ns}$** | $\sim 25\text{ ns} - 80\text{ ns}$ |
| **Cold Lookup Latency** | **$\le 12\text{ ns}$** | $\sim 150\text{ ns} - 400\text{ ns}$ |
| **Teardown Ordering** | Topological Reverse DAG | LIFO / Arbitrary Unordered |
| **Circular Dependency Check** | Automatic cycle detection with DAG path | Stack Overflow Crash / None |
| **Async Frame-0 Protection** | Automated non-blocking gate (`useAsync`) | Manual `await` in `main()` or custom wrappers |
| **Route Stack Integration** | Automatic route leasing via `GraftScope` | Manual registration & manual unregister |

---

## Registering Dependencies (`bind` & `bindAsync`)

Graft provides two primary registration functions: `bind<T>()` for synchronous factories, and `bindAsync<T>()` for asynchronous operations.

### Synchronous Registration (`bind`)
```dart
// Singleton by default (cached in active scope, instantiated on first access)
bind<ApiClient>(() => ApiClient(baseUrl: 'https://api.example.com'));

// Factory (new instance on every lookup)
bind<TransientHelper>(() => TransientHelper(), singleton: false);

// Preserved (survives route pop cleanup until explicitly dropped)
bind<AuthTokenManager>(() => AuthTokenManager(), preserved: true);
```

### Asynchronous Registration (`bindAsync`)
```dart
// Lazy by default: starts on first useAsync<Database>() call
bindAsync<Database>(() async {
  return await openDatabase('app.db', version: 1);
});

// Eager: starts immediately in the background without blocking startup
bindAsync<SharedPreferences>(() async {
  return await SharedPreferences.getInstance();
}, eager: true);
```

---

## Resolving Dependencies (`use` & `useAsync`)

### Synchronous Resolution (`use<T>()`)
Call `use<T>()` from anywhere in your codebase or Flutter build methods:
```dart
// Ambient global resolution
final api = use<ApiClient>();

// In Flutter BuildContext:
final userGraft = context.use(UserGraft.new);
```

### Asynchronous Resolution (`useAsync<T>()`)
Call `useAsync<T>()` to automatically await in-flight asynchronous initialization on Frame 0 without blocking:
```dart
// Frame 0: awaits initialization if in-flight, returns immediately if completed
final db = await useAsync<Database>();
final results = await db.query('SELECT * FROM users');
```

---

## Developer Enum Scopes & Flow Management

Group related services into type-safe scope blocks bound to your own domain `enum`:

```dart
enum AppScope { auth, checkout, profile }

// Declare cohesive scope blocks:
scope(AppScope.checkout, () {
  bind<CartRepository>(() => CartRepository());
  bind<CheckoutCoordinator>(() => CheckoutCoordinator(use<CartRepository>()));
});
```

### Dropping Scopes Flow-Wide
When an order is submitted or cancelled, drop the entire scope and dispose all services in reverse DAG order with a single line:
```dart
void onOrderCompleted() {
  AppScope.checkout.drop(); // Disposes CheckoutCoordinator THEN CartRepository!
}
```

---

## Route Leasing & Automatic Route Disposal

Graft integrates seamlessly with Flutter's navigation system to eliminate manual controller memory management:

### 1. Route-Stack Lifecycle (`context.use<T>()`)
Calling `context.use<T>()` automatically binds the controller's lifecycle to the active route:
- **Automatic Ownership**: The first screen that calls `context.use<T>()` becomes the **Owner**.
- **Stack Borrowing**: Child screens pushed on top automatically inherit and borrow the existing instance.
- **Auto-Disposal**: When the owner route pops from the `Navigator`, Graft automatically calls `dispose()` on the controller.
- **Popup Protection**: Dialogs (`showDialog`) and modal bottom sheets (`showModalBottomSheet`) borrow safely without prematurely disposing the host screen's controller.

### 2. Subtree Scoping (`GraftScope`)
For localized subtrees like `GoRouter` shell routes, persistent bottom navigation tabs, or modal sheets:

```dart
GraftScope(
  factories: [
    () => CheckoutGraft(
      coordinator: use<CheckoutCoordinator>(),
      cartDao: use<CartDao>(),
    ),
  ],
  child: const CheckoutForm(),
);
```

Or for a pre-existing single instance:
```dart
GraftScope.single(
  graft: checkoutGraft,
  child: const CheckoutForm(),
);
```
When `GraftScope` unmounts from the element tree, all managed controllers are disposed automatically.

---

## Non-Blocking Async Database & Network Services

Developers write 100% standard Dart classes with zero wrappers:

```dart
class AppDatabase {
  final Database _db;
  AppDatabase(this._db);

  static Future<AppDatabase> open() async {
    final rawDb = await openDatabase('app.db');
    return AppDatabase(rawDb);
  }

  Future<List<Map<String, Object?>>> queryOrders() => _db.query('orders');
}

// In setup / main:
bindAsync<AppDatabase>(() => AppDatabase.open());

// In your controller / screen:
Future<void> loadOrders() async {
  final db = await useAsync<AppDatabase>(); // Frame 0 safe!
  final orders = await db.queryOrders();
}
```

---

## In-Degree Reverse DAG Teardown

If `ServiceB` consumes `ServiceA`:
```
ServiceA (Database) ◀──── ServiceB (OrderService) ◀──── ServiceC (UI Controller)
```
When the scope is dropped:
1. `ServiceC` is disposed first.
2. `ServiceB` is disposed second.
3. `ServiceA` is disposed last.

Any circular dependency is trapped on resolution:
```
StateError: Graft DI Circular Dependency: TypeId#1 ──▶ TypeId#2 ──▶ TypeId#1
```

---

## Testing, Zone Mock Overrides & Real Database Verification

### 1. Mocking with `GraftDI.withOverrides()`
Isolate tests without leaking state across test runs using `GraftDI.withOverrides()`:

```dart
test('mock database test', () async {
  await GraftDI.withOverrides(
    overrides: {
      TypeId.of<ApiClient>(): () => MockApiClient(),
    },
    body: () async {
      final client = use<ApiClient>();
      expect(client, isA<MockApiClient>());
    },
  );
});
```

### 2. Zone-Isolated Mock Testing (`GraftDI.testZoneKey`)
For concurrent or isolated tests where global state must not bleed between test cases:
```dart
test('zone isolated test', () {
  final isolatedScope = ScopeNode(ScopeTier.root);
  isolatedScope.bind<AuthTokenManager>(() => MockAuthTokenManager());

  runZoned(() {
    expect(use<AuthTokenManager>(), isA<MockAuthTokenManager>());
  }, zoneValues: {GraftDI.testZoneKey: isolatedScope});
});
```

### 3. Real SQLite Verification Patterns
Graft DI is verified against real SQLite in `test/di/real_sqlite_di_test.dart` for enterprise production workloads:
- **Multi-Tier DAOs**: `Database` ◀── `UserDao` ◀── `OrderDao` ◀── `CheckoutCoordinator`.
- **Topological Teardown**: Calling `scope.drop()` disposes `CheckoutCoordinator` and DAOs *before* executing `db.dispose()`, eliminating `SqliteException: Cannot operate on closed database` crashes.
- **Rollback Integrity**: Atomic transaction failures roll back dirty states while preserving scope graph stability.
- **Persistence Across Restarts**: File-based `.db` databases survive teardown and reopen cleanly with 100% data fidelity.

Reset ambient state between test runs when using global bindings:
```dart
tearDown(() {
  GraftDI.reset();
});
```

---

## 🌟 Complete Real-World Example (Production Architecture)

Here is a complete, production-ready example demonstrating how all parts of Graft DI work harmoniously together: **asynchronous database initialization**, **type-safe enum scoping**, **injected services**, **reactive Graft controllers**, **route-bound Flutter UI**, and **clean topological teardown**.

### 1. Define Enum Scopes & Domain Services with `Disposable`

```dart
import 'package:flutter/material.dart';
import 'package:graft/graft.dart';

// 1. Type-safe scope enum for feature flows:
enum AppScope { auth, checkout }

// 2. Underlying asynchronous database service:
class DatabaseService implements Disposable {
  bool isClosed = false;

  DatabaseService._();

  static Future<DatabaseService> open() async {
    // Simulates opening SQLite / native local database asynchronously:
    await Future.delayed(const Duration(milliseconds: 50));
    return DatabaseService._();
  }

  void execute(String sql) {
    if (isClosed) throw StateError('Cannot operate on closed database!');
  }

  @override
  void dispose() {
    isClosed = true;
    debugPrint('📦 [DI Teardown 3] DatabaseService closed safely.');
  }
}

// 3. Data Access Object depending directly on DatabaseService:
class CartDao implements Disposable {
  final DatabaseService _db;
  CartDao(this._db);

  List<String> getCartItems() {
    _db.execute('SELECT * FROM cart');
    return ['Espresso Blend', 'V60 Dripper'];
  }

  @override
  void dispose() {
    debugPrint('🛒 [DI Teardown 2] CartDao disposed.');
  }
}

// 4. Feature coordinator depending on CartDao:
class CheckoutCoordinator implements Disposable {
  final CartDao _cartDao;
  CheckoutCoordinator(this._cartDao);

  Future<void> submitOrder() async {
    final items = _cartDao.getCartItems();
    debugPrint('🚀 Processing order for items: $items');
  }

  @override
  void dispose() {
    debugPrint('💳 [DI Teardown 1] CheckoutCoordinator disposed.');
  }
}
```

### 2. Configure Dependency Registration & Bind the Graft Controller

Register dependencies in `main.dart` or during app bootstrap. Notice how `CheckoutGraft` itself is registered with its dependencies cleanly injected:

```dart
void configureAppDependencies() {
  // Global Singleton: Database starts asynchronously without blocking startup Frame 0:
  bindAsync<DatabaseService>(() => DatabaseService.open());

  // Scoped Services: Grouped strictly within AppScope.checkout:
  scope(AppScope.checkout, () {
    // 1. Bind DAOs:
    bind<CartDao>(() => CartDao(use<DatabaseService>()));

    // 2. Bind Coordinators:
    bind<CheckoutCoordinator>(() => CheckoutCoordinator(use<CartDao>()));

    // 🎯 3. BIND THE GRAFT CONTROLLER WITH ITS INJECTED DEPENDENCIES:
    bind<CheckoutGraft>(() => CheckoutGraft(
      coordinator: use<CheckoutCoordinator>(),
      cartDao: use<CartDao>(),
    ));
  });
}
```

### 3. Define Domain State & Graft Controller with Constructor Injection

`CheckoutGraft` declares its dependencies as clean constructor parameters. This makes the controller 100% testable in unit tests without any global mocks or magic:

```dart
class CheckoutState extends GraftState {
  List<String> items = const [];
  bool isSubmitting = false;

  @override
  GraftProps get props => propsOf(items, isSubmitting);
}

class CheckoutGraft extends Graft<CheckoutState> {
  final CheckoutCoordinator _coordinator;
  final CartDao _cartDao;

  // 💉 Clean Constructor Injection:
  // Provided directly by DI via bind<CheckoutGraft>() above!
  CheckoutGraft({
    required CheckoutCoordinator coordinator,
    required CartDao cartDao,
  })  : _coordinator = coordinator,
        _cartDao = cartDao,
        super(CheckoutState());

  @override
  void onInit() {
    super.onInit();
    // Load initial cart data:
    state..items = _cartDao.getCartItems()..update();
  }

  Future<void> completeCheckout(BuildContext context) async {
    state..isSubmitting = true..update();
    await _coordinator.submitOrder();

    // ⚡ Drop the entire checkout scope flow-wide (all services cleaned up):
    AppScope.checkout.drop();

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
```

### 4. Build the Flutter UI Screen with Route-Stack Borrowing

Because `CheckoutGraft` is registered in `bind<CheckoutGraft>()`, the screen does not need any constructor parameters or service locator plumbing. It simply calls `context.use<CheckoutGraft>()`:

```dart
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 Zero boilerplate! Automatically resolves or borrows CheckoutGraft across the route stack:
    final checkout = context.use<CheckoutGraft>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Surgical leaf slot 1: Items list
            Expanded(
              child: checkout((s) => ListView.builder(
                itemCount: s.items.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(s.items[i]),
                ),
              )),
            ),

            // Surgical leaf slot 2: Submit button with loading state
            checkout((s) => ElevatedButton(
              onPressed: s.isSubmitting
                  ? null
                  : () => checkout.completeCheckout(context),
              child: s.isSubmitting
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Place Order'),
            )),
          ],
        ),
      ),
    );
  }
}
```

### 5. Guaranteed Reverse DAG Teardown Trace

When `AppScope.checkout.drop()` is called or `CheckoutScreen` is popped from the Navigator, Graft's in-degree topological sorter automatically disposes instances in the exact reverse creation order:

```text
[DI Teardown 1] CheckoutCoordinator disposed.  ➔ Consumers teardown first!
[DI Teardown 2] CartDao disposed.              ➔ Intermediate DAOs teardown second!
[DI Teardown 3] DatabaseService closed safely. ➔ Root connection closed last!
```

> [!TIP]
> Notice how `DatabaseService` is closed **only after** all consumers (`CheckoutCoordinator` and `CartDao`) have finished disposing. This 100% eliminates `SqliteException: Cannot operate on closed database` crashes!

---

### 💡 The 3 Ways to Inject Dependencies into a Graft Controller

Graft supports 3 flexible injection patterns to fit any team or project architecture:

#### 1. Pure Constructor Injection via `bind<G>()` (Recommended for Clean Architecture)
Declare dependencies in the controller's constructor and register the controller in `bind<G>()`. The controller remains 100% pure and decoupled from any service locator, making unit testing trivial:
```dart
// 1. In main.dart / DI setup:
bind<UserGraft>(() => UserGraft(
  api: use<ApiClient>(),
  cache: use<CacheDao>(),
));

// 2. In your Widget (zero arguments needed!):
final user = context.use<UserGraft>();
```

#### 2. Route-Level Inline Binding (`context.use(() => ...)`)
If a controller requires runtime arguments from route parameters or widget properties:
```dart
// In your Widget:
final profile = context.use(() => ProfileGraft(
  api: use<ApiClient>(),
  userId: widget.userId, // Runtime route parameter
));
```

#### 3. Ambient Service Resolution Inside Controller (`use<T>()`)
For simple controllers where you prefer default no-argument constructors:
```dart
class UserGraft extends Graft<UserState> {
  final ApiClient _api;

  UserGraft()
      : _api = use<ApiClient>(),
        super(UserState());
}

// In your Widget:
final user = context.use(UserGraft.new);
```

---

## 📚 Related Technical Guides & Reports

- 🏛️ **[ARCHITECTURE.md](https://github.com/kmmuzahid/graft/blob/main/ARCHITECTURE.md):** Deep dive into the 6 Core Engineering Pillars, monotonic TypeId, in-degree reverse DAG teardowns, and non-blocking async execution gates.
- 💾 **[GRAFT_GUIDE.md](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md):** Major dedicated guide for State Management & Frame-0 Persistence (propsOf, surgical slots, zero-controller forms, and Frame-0 dry state).
- 📊 **[BENCHMARK_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** Empirical benchmark methodology and full logs (including **Scenario F2**: DI Engine lookups $\le 12$ ns cold, $< 0.8$ ns hot V-table access).
- 🧪 **[TEST_REPORT.md](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Comprehensive test verification report across 283 passing tests (including 22 Dependency Injection engine tests).

