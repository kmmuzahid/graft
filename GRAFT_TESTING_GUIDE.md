# Graft Testing Guide: Declarative Unit, Mock & Widget Testing

---

## 🚀 Overview

Graft provides a dedicated, zero-overhead testing harness strictly segregated in **`package:graft/testing.dart`**:
- **Blazing Fast (Sub-Millisecond):** Executes pure Dart unit tests without pumping widgets or inflating elements.
- **Hermetic Test Isolation:** `GraftTesting.resetAll()` wipes all DI scopes, ambient route pools, persistence caches, and observers in a single call.
- **Built-in Mock Dependency Injection:** Mock ambient services and repositories in `graftTest` via `overrides: { Repo: MockRepo() }` without manual Zone boilerplate.
- **Widget Test Controller Injection:** `GraftTesting.overrideController<G>(mockGraft)` effortlessly pre-seeds mock controllers for `context.use<G>()` in widget tests with zero widget tree wrappers.
- **Error Assertion:** Captures errors dispatched via `graft.addError` with `errors: () => [...]`.
- **Bitmask & Transition Spying:** Directly verify 64-bit dirty masks (`change.isDirty(i)`) and inspect transition history via `GraftTesting.recordChanges`.
- **Frame-0 Dry Persistence Testing:** Synchronously flush debounced disk writes via `await GraftTesting.flushPersistence()`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart'; // 👈 Dedicated testing suite
```

---

## 📖 Table of Contents
1. [Hermetic Test Isolation (`GraftTesting.resetAll`)](#hermetic-test-isolation-grafttestingresetall)
2. [Unit Testing Controllers (`graftTest`)](#unit-testing-controllers-grafttest)
3. [Mocking Dependency Injection (`overrides` & `GraftTesting.override`)](#mocking-dependency-injection-overrides--grafttestingoverride)
4. [Pre-seeding Baseline State (`seed`)](#pre-seeding-baseline-state-seed)
5. [Error Boundary & Exception Testing (`errors`)](#error-boundary--exception-testing-errors)
6. [Surgical Reactivity & Dirty Bitmask Testing (`expectChanges`)](#surgical-reactivity--dirty-bitmask-testing-expectchanges)
7. [Widget Testing & Controller Injection (`GraftTesting.overrideController`)](#widget-testing--controller-injection-grafttestingoverridecontroller)
8. [Frame-0 Dry Persistence Testing (`flushPersistence`)](#frame-0-dry-persistence-testing-flushpersistence)
9. [Feature Comparison: Graft vs. Bloc vs. Riverpod](#feature-comparison-graft-vs-bloc-vs-riverpod)
10. [Testing Best Practices & Anti-Patterns](#testing-best-practices--anti-patterns)

---

## Hermetic Test Isolation (`GraftTesting.resetAll`)

In Flutter test suites, test cases run sequentially in a single Dart VM process. Any retained singleton, DI scope, or L1 persistence cache from a previous test can cause subtle test pollution and flaky tests.

To guarantee **100% hermetic isolation**, add `setUp(GraftTesting.resetAll)` to your test suites:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/testing.dart';

void main() {
  setUp(() {
    // 🧹 Wipes DI scopes, ambient route tracker, L1 dry persistence, and observers:
    GraftTesting.resetAll();
  });

  // Individual tests run in clean, hermetic isolation...
}
```

### Granular Resets
When fine-grained control is preferred, `GraftTesting` provides targeted reset methods:
- `GraftTesting.resetDI()`: Clears all active scopes and root singleton bindings.
- `GraftTesting.resetRoutes()`: Resets the ambient route registry and ownership pool.
- `GraftTesting.resetPersistence()`: Purges L1 RAM caches and closes the active storage coordinator.

---

## Unit Testing Controllers (`graftTest`)

`graftTest` is a declarative, structured testing utility for `Graft` controllers modeled after `blocTest`. It standardizes tests into distinct lifecycle phases:

```
┌────────────────────────────────────────────────────────┐
│                      graftTest                         │
│   1. overrides  ──►  Zone-isolated mock injection      │
│   2. build      ──►  Instantiates fresh Graft instance │
│   3. setUp      ──►  Configures mocks & stubs          │
│   4. seed       ──►  Applies initial state baseline    │
│   5. act        ──►  Executes controller business logic│
│   6. wait       ──►  Awaits async delay / debouncing   │
│   7. expect     ──►  Asserts state matchers            │
│   8. errors     ──►  Asserts captured errors           │
│   9. verify     ──►  Final assertions & mock verifications│
│  10. tearDown   ──►  Auto-removes listeners & disposes │
└────────────────────────────────────────────────────────┘
```

### Basic Synchronous Test

```dart
class CounterState extends GraftState {
  int count = 0;
  @override
  GraftProps get props => propsOf(count);
}

class CounterGraft extends Graft<CounterState> {
  CounterGraft() : super(CounterState());

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

void main() {
  group('CounterGraft', () {
    graftTest<CounterGraft, CounterState>(
      'increments count and notifies listeners',
      build: () => CounterGraft(),
      act: (graft) => graft.increment(),
      expect: () => [
        isA<CounterState>().having((s) => s.count, 'count', 1),
      ],
      verify: (graft) {
        expect(graft.state.count, 1);
      },
    );
  });
}
```

### Asynchronous Transitions & Delays (`wait`)

When testing debounced search inputs, network latency, or streaming operations, use `wait` to pause execution before running assertions:

```dart
graftTest<SearchGraft, SearchState>(
  'debounces search queries by 300ms',
  build: () => SearchGraft(),
  act: (graft) => graft.search('Flutter'),
  wait: const Duration(milliseconds: 350),
  expect: () => [
    isA<SearchState>().having((s) => s.query, 'query', 'Flutter'),
  ],
);
```

---

## Mocking Dependency Injection (`overrides` & `GraftTesting.override`)

In real-world applications, controllers depend on external repositories, HTTP clients, or databases accessed via `use<T>()`.

### 1. Declarative Mocking with `overrides` in `graftTest`

Pass a `Map<Type, Object?>` to `overrides`. `graftTest` automatically mounts them into the execution Zone and unmounts them after the test:

```dart
abstract class UserRepository {
  Future<String> fetchUserName(int id);
}

class MockUserRepository implements UserRepository {
  @override
  Future<String> fetchUserName(int id) async => 'Alice';
}

class ProfileGraft extends Graft<ProfileState> {
  ProfileGraft() : super(ProfileState());

  Future<void> loadProfile(int id) async {
    // Ambient dependency lookup:
    final repo = use<UserRepository>();
    final name = await repo.fetchUserName(id);
    state..name = name..update();
  }
}

void main() {
  graftTest<ProfileGraft, ProfileState>(
    'loads user profile via mock repository',
    overrides: {
      UserRepository: MockUserRepository(), // 👈 Mock injected cleanly!
    },
    build: () => ProfileGraft(),
    act: (graft) => graft.loadProfile(42),
    expect: () => [
      isA<ProfileState>().having((s) => s.name, 'name', 'Alice'),
    ],
  );
}
```

### 2. Imperative Mocking (`GraftTesting.override`)

For standard Dart unit tests outside `graftTest`:

```dart
test('loads user profile imperatively', () async {
  GraftTesting.override<UserRepository>(MockUserRepository());

  final graft = ProfileGraft();
  await graft.loadProfile(42);

  expect(graft.state.name, 'Alice');
});
```

### 3. Scoped Execution (`GraftTesting.runWithOverrides`)

```dart
await GraftTesting.runWithOverrides(
  {UserRepository: MockUserRepository()},
  () async {
    final graft = ProfileGraft();
    await graft.loadProfile(42);
    expect(graft.state.name, 'Alice');
  },
);
```

---

## Pre-seeding Baseline State (`seed`)

Use `seed` to configure an initial state baseline immediately after `build` and `setUp`, but before `act` runs:

```dart
graftTest<CartGraft, CartState>(
  'clears existing cart items',
  build: () => CartGraft(),
  seed: (graft) {
    graft.state
      ..items.addAll(['Apple', 'Banana'])
      ..totalPrice = 15.0
      ..update();
  },
  act: (graft) => graft.clearCart(),
  expect: () => [
    isA<CartState>()
        .having((s) => s.items, 'items', isEmpty)
        .having((s) => s.totalPrice, 'totalPrice', 0.0),
  ],
);
```

---

## Error Boundary & Exception Testing (`errors`)

Controllers dispatch business logic errors using `graft.addError(error, [stackTrace])`. In production, these flow to `GraftObserver.onError` (e.g. Sentry or Firebase).

In tests, `graftTest` captures all dispatched errors and verifies them using `errors: () => [...]`:

```dart
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthGraft extends Graft<AuthState> {
  AuthGraft() : super(AuthState());

  void login(String username, String password) {
    if (password.isEmpty) {
      addError(AuthException('Password cannot be empty'));
      return;
    }
    // Proceed with login...
  }
}

void main() {
  graftTest<AuthGraft, AuthState>(
    'dispatches AuthException when password is empty',
    build: () => AuthGraft(),
    act: (graft) => graft.login('admin', ''),
    errors: () => [
      isA<AuthException>().having((e) => e.message, 'message', 'Password cannot be empty'),
    ],
  );
}
```

---

## Surgical Reactivity & Dirty Bitmask Testing (`expectChanges`)

Graft computes 64-bit integer bitmasks to identify exactly which properties changed. Developers can verify that a mutation dirties **only** the intended property indices and leaves other indices clean:

```dart
class UserState extends GraftState {
  String name = 'Alice'; // Index 0
  int age = 25;          // Index 1
  String email = '';     // Index 2

  @override
  GraftProps get props => propsOf(name, age, email);
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateEmail(String email) {
    state
      ..email = email
      ..update();
  }
}

void main() {
  graftTest<UserGraft, UserState>(
    'updates only email property index 2',
    build: () => UserGraft(),
    act: (graft) => graft.updateEmail('alice@example.com'),
    expectChanges: () => [
      predicate<GraftChange>((change) {
        return change.isDirty(2) && !change.isDirty(0) && !change.isDirty(1);
      }),
    ],
  );
}
```

### Imperative Inspection (`GraftTesting.recordChanges`)

```dart
test('records state transitions imperatively', () {
  final graft = UserGraft();

  final changes = GraftTesting.recordChanges(graft, () {
    graft.updateEmail('test@domain.com');
  });

  expect(changes, hasLength(1));
  expect(changes.first.isDirty(2), isTrue);
  expect(changes.first.isDirty(0), isFalse);
});
```

---

## Widget Testing & Controller Injection (`GraftTesting.overrideController`)

In Flutter widget tests, screens consume controllers via `context.use(UserGraft.new)` or `context.use<UserGraft>()`.

With Graft, you do **not** wrap widgets in artificial testing scopes. Simply call `GraftTesting.overrideController<G>(mock)` before pumping the widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

// Screen under test:
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userGraft = context.use(UserGraft.new);
    return Scaffold(
      body: graft.slot(
        builder: (s) => Text('User: ${userGraft.state.name}'),
      ),
    );
  }
}

void main() {
  setUp(GraftTesting.resetAll);

  testWidgets('renders pre-configured mock controller state', (tester) async {
    // 1. Create and configure mock controller:
    final mockGraft = UserGraft();
    mockGraft.state..name = 'Bob'..update();

    // 2. Inject override:
    GraftTesting.overrideController<UserGraft>(mockGraft);

    // 3. Pump widget naturally — zero testing wrapper widgets needed!
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    // 4. Verify rendered output:
    expect(find.text('User: Bob'), findsOneWidget);
  });
}
```

---

## Frame-0 Dry Persistence Testing (`flushPersistence`)

In production, Frame-0 persistence debounces disk writes (e.g. 300ms) to maximize frame rates and avoid I/O starvation.

In unit tests, waiting for real wall-clock delays slows test execution. `GraftTesting.flushPersistence()` **immediately flushes all queued writes synchronously**:

```dart
test('persists state and flushes queue immediately', () async {
  final graft = UserGraft();
  graft.state
    ..name = 'Persisted User'
    ..update();

  // Flush debounced queue synchronously:
  await GraftTesting.flushPersistence();

  // Persistence is guaranteed to be saved; verify immediate hydration:
  GraftTesting.resetRoutes();
  final reloadedGraft = UserGraft();
  expect(reloadedGraft.state.name, 'Persisted User');
});
```

---

## Feature Comparison: Graft vs. Bloc vs. Riverpod

| Capability | Bloc (`bloc_test`) | Riverpod (`ProviderContainer`) | Graft (`package:graft/testing.dart`) |
| :--- | :---: | :---: | :---: |
| **Declarative Unit Test** | `blocTest` | Custom / `providerTest` | **`graftTest`** |
| **Mock Dependency Injection** | Manual constructor injection | `ProviderContainer(overrides: [...])` | **`overrides: { Repo: MockRepo() }`** |
| **Widget Test Mocking** | `BlocProvider.value(...)` | `ProviderScope(overrides: [...])` | **`GraftTesting.overrideController`** (0 wrappers) |
| **State Emission Matching** | `expect: () => [...]` | `container.listen(...)` | **`expect: () => [...]`** |
| **Error Boundary Testing** | `errors: () => [...]` | Manual try/catch | **`errors: () => [...]`** |
| **Initial State Baseline** | `seed: () => State` | Manual override | **`seed: (graft) => ...`** |
| **Surgical Dirty Mask Spying**| ❌ Not supported | ❌ Not supported | **`expectChanges` / `change.isDirty(i)`** |
| **Hermetic Reset** | Manual bloc disposal | `container.dispose()` | **`GraftTesting.resetAll()`** (1 line) |
| **Persistence Verification** | Manual mock storage | Manual mock storage | **`await GraftTesting.flushPersistence()`** |

---

## Testing Best Practices & Anti-Patterns

### ✅ Best Practices
1. **Always call `setUp(GraftTesting.resetAll)`:** Keeps test runs deterministic and completely immune to state leakage across cases.
2. **Use native cascade mutations in `act`:** `act: (graft) => graft.state..field = x..update()`.
3. **Use `errors: () => [...]` for failure branches:** Verifies that your controllers properly route business exceptions via `graft.addError`.
4. **Flush persistence before asserting storage:** Use `await GraftTesting.flushPersistence()` to bypass debounce timers.

### ❌ Anti-Patterns to Avoid
1. **Do not wrap widgets in artificial scopes during testing:** Never create fake provider wrappers in widget tests. Use `GraftTesting.overrideController` or `GraftTesting.override`.
2. **Do not use `Future.delayed` for persistence:** Never wait for 300ms in tests to let debounce queues flush. Call `await GraftTesting.flushPersistence()`.
3. **Do not import `package:graft/testing.dart` in production code:** Keep testing harnesses inside `test/`. Production files only import `package:graft/graft.dart`.

