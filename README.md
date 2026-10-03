# Graft 🌱

**High-performance, fine-grained reactive state management for Flutter with zero boilerplate.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!IMPORTANT]
> ### 🚀 Graft is in Public Alpha (`0.1.0-alpha.1`) — Let's Have a Ride!
> Graft is actively evolving in its initial alpha release. It is **not yet declared production-ready**.
> We warmly invite the Flutter developer community to take it for a spin: test it in your projects, push its slot diffing and route scoping to the limits, and help us make it even better!
> 
> Share your feedback, edge cases, and ideas on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) or join the discussions as we march towards 1.0!

---

## 📦 Installation

Add `graft` to your `pubspec.yaml`:

```bash
flutter pub add graft
```

Or manually add it to `dependencies`:

```yaml
dependencies:
  graft: ^0.1.0-alpha.1
```

Import it in your Dart code:

```dart
import 'package:graft/graft.dart';
```

---

## 🌟 Why Graft?

Most Flutter state management solutions force you into an unpleasant compromise:

- **Flutter Bloc** gives you clean architecture and observability, but punishes you with a **"Pyramid of Doom"** (nesting 5 `BlocSelector` widgets just to avoid rebuilding 5 fields in a Column), plus heavy boilerplate.
- **Riverpod** offers dependency injection, but pushes heavily toward **code generation** (`@riverpod`, `build_runner`, `.g.dart` clutter), replaces standard `StatelessWidget` with `ConsumerWidget`, and requires threading `WidgetRef` everywhere.
- **Signals / Solidart** offer fine-grained rebuilds, but **fragment your state** into dozens of loose primitive variables, destroying cohesive domain models.
- **GetX** bypasses Flutter's Element tree and route lifecycles with global mutable state and untyped string lookups, leading to memory leaks.

**Graft solves all of this.**

| Feature / Metric | Flutter BLoC / Cubit | Riverpod | Provider | GetX | MobX | Signals | **Graft** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Fine-Grained Rebuilds** | ❌ Manual `BlocSelector` per field | ⚠️ Requires `ref.watch(p.select(...))` | ❌ Manual `Selector` per field | ⚠️ `Obx(() => ...)` wrappers everywhere | ⚠️ `Observer` wrappers everywhere | ✅ Micro-rebuild per signal | ✅ **Automatic**: `graft.slots(layout: ..., children: ...)` diffs slots with **zero manual selectors** |
| **Widget Tree Nesting** | ❌ Deep pyramid (`BlocProvider` → `BlocBuilder`) | ⚠️ `ConsumerWidget` or `Consumer` | ❌ Deep pyramid (`ChangeNotifierProvider` → `Consumer`) | ✅ Minimal | ⚠️ `Observer` wrappers | ⚠️ `Watch(...)` wrappers | ✅ **Zero Nesting**: `final graft = context.use<MyGraft>()` at top of standard `StatelessWidget` |
| **Code Generation** | ✅ None | ❌ Heavily pushed (`@riverpod`, `build_runner`) | ✅ None | ✅ None | ❌ Mandatory (`@observable`, `@action`) | ✅ None | ✅ **Strictly 0 Code-Gen** |
| **State Structure** | ✅ Single cohesive domain class | ✅ Single cohesive domain class | ✅ Single cohesive domain class | ❌ Fragmented reactive vars (`.obs`) | ❌ Fragmented observables | ❌ Fragmented loose signals (`signal()`) | ✅ **Single cohesive domain State** |
| **Route Stack Sharing** | ⚠️ Manual `BlocProvider.value` | ⚠️ `autoDispose` or manual overrides | ⚠️ Manual scoping | ❌ Global map (frequent memory leaks) | ⚠️ Manual `dispose()` | ⚠️ Manual disposal of effects | ✅ **Automatic**: Inherits from predecessor routes; auto-disposes when owner pops |
| **Subclass Boilerplate** | ⚠️ High (Events, States, Handlers) | ⚠️ High (family providers, code-gen) | ⚠️ Moderate (`ChangeNotifier`) | ⚠️ Moderate | ⚠️ High (`.g.dart` store files) | ⚠️ High (declaring 10+ signals) | ✅ **Zero**: `class InfoGraft extends Graft<InfoState>` |
| **Observability** | ✅ `BlocObserver` | ⚠️ `ProviderObserver` | ❌ None built-in | ⚠️ Basic prints | ⚠️ MobX spy | ❌ None built-in | ✅ **`GraftObserver` & colorized `GraftDevObserver`** |
| **Unit Testing** | ✅ Declarative `blocTest` | ⚠️ `ProviderContainer` manual tests | ⚠️ Manual mocks | ⚠️ Difficult to isolate | ⚠️ Manual harness | ⚠️ Manual effects | ✅ **Declarative `graftTest` (Pure Dart, sub-millisecond)** |

---

## ⚡ Developer Ergonomics: Column Rebuild Comparison

How do state management libraries compare when trying to achieve fine-grained, single-widget rebuilds in a multi-child `Column`?

### 1. Flutter BLoC / Cubit (Pyramid of Selectors):
```dart
// ❌ BLoC: Requires wrapping EVERY single dynamic widget in a verbose BlocSelector
Column(
  children: [
    const HeaderBanner(),
    BlocSelector<UserBloc, UserState, String>(
      selector: (s) => s.name,
      builder: (context, name) => CkText(text: name),
    ),
    BlocSelector<UserBloc, UserState, String>(
      selector: (s) => s.email,
      builder: (context, email) => Text(email),
    ),
    BlocSelector<UserBloc, UserState, bool>(
      selector: (s) => s.isVerified,
      builder: (context, verified) => verified ? const VerifiedBadge() : const SizedBox(),
    ),
  ],
)
```

### 2. Riverpod (Fragmented Consumers):
```dart
// ⚠️ Riverpod: Requires splitting into multiple Consumer widgets or writing ref.watch selectors
Column(
  children: [
    const HeaderBanner(),
    Consumer(builder: (context, ref, _) {
      final name = ref.watch(userProvider.select((s) => s.name));
      return CkText(text: name);
    }),
    Consumer(builder: (context, ref, _) {
      final email = ref.watch(userProvider.select((s) => s.email));
      return Text(email);
    }),
    Consumer(builder: (context, ref, _) {
      final isVerified = ref.watch(userProvider.select((s) => s.isVerified));
      return isVerified ? const VerifiedBadge() : const SizedBox();
    }),
  ],
)
```

### 3. With Graft (Clean, Harmonized Named Syntax):
```dart
// ✅ Graft: Zero selectors, zero boilerplate. 
// The slot engine automatically isolates each child widget!
graft.slots(
  layout: (children) => Column(children: children), // Explicit layout is required!
  children: (s) => [
    const HeaderBanner(), // 0 rebuilds (pointer match)
    CkText(text: s.name), // 0 rebuilds when name is unchanged (auto-unwrapped & diffed)
    Text(s.email),        // 0 rebuilds when email is unchanged
    if (s.isVerified) const VerifiedBadge(),
  ],
)
```

---

## 🏎️ Performance & Render Pipeline Benchmark

### The 10,000x Cost Difference:

In standard Flutter and BLoC (`BlocBuilder`), every state emission forces the entire child subtree through Flutter's expensive rendering pipeline:
1. `Widget.build()` allocation
2. `Element.update()` & `Element.rebuild()`
3. `RenderObject.markNeedsLayout()`
4. `RenderObject.performLayout()`
5. `RenderObject.markNeedsPaint()`
6. `RenderObject.paint()`

> **Cost of full Render Pipeline:** **~1.0 to 5.0 milliseconds** per frame.

In **Graft (`graft.slots`)**:
- Diffing occurs **strictly in memory before touching Flutter elements**:
  - `const` pointer check (`identical(a, b)`): **< 1 nanosecond**
  - Keyed check (`a.key == b.key`): **~5 nanoseconds**
  - Primitive property inspection (strings, padding, alignment): **~15 to 80 nanoseconds**
- If properties match, **Flutter's Element is never dirtied**. Layout is skipped, and paint is skipped completely!
- **Pure Dart diffing is ~10,000x faster than dirtying the Flutter RenderObject tree.**

### Verified Automated Benchmark (10-Slot Column, 60 State Updates):
From our automated benchmark test (`test/benchmark/column_rebuild_benchmark_test.dart`):

```
================================================================================
  GRAFT REBUILD BENCHMARK (10-Slot Column, 60 State Updates)
================================================================================
  Traditional / Monolithic Rebuild Model:
    - Children in Column: 10
    - Frames / Updates:   60
    - Total Child Builds: 600 rebuilds (10 children * 60 updates)

  Graft Fine-Grained slot engine:
    - Slot 0 (Changing):  60 rebuilds (1 per frame)
    - Slots 1-9 (Static): 0 rebuilds across all 60 frames
    - Total Child Builds: 60 rebuilds
    - Total Elapsed Time: ~51 ms
    - Rebuild Reduction:  90.0% LESS WORK!
================================================================================
```

---

## 🛠️ Quick Start

### 1. Define State & Controller:

```dart
class UserState extends GraftState {
  String name = 'Alice';
  String email = 'alice@example.com';
  bool isVerified = false;
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update(); // Batched diffing: notifies listeners and diffs UI slots
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
  // Optional: Enable dev telemetry
  Graft.observer = GraftDevObserver(logRebuilds: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Register route tracker to enable automatic route-scoped lifecycle disposal!
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
        layout: (children) => Column(children: children), // Required layout wrapper
        children: (s) => [
          const HeaderBanner(),
          Text('Email: ${s.email}'),
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

## 🎨 Harmonized Widget Slot API

Graft provides a clean, 100% named-parameter API:

### 1. `graft.slot({required builder, key})` (Single-Child Slot)
Isolates any single widget slot. Only rebuilds when the returned widget changes:
```dart
AppBar(
  title: graft.slot(
    builder: (s) => Text(s.title),
  ),
)

// Also handles full-page state switching:
graft.slot(
  builder: (s) {
    if (s.isLoading) return const CircularProgressIndicator();
    if (s.hasError) return Text(s.error);
    return ContentView(data: s.data);
  },
)
```

### 2. `graft.slots({required layout, required children, key})` (Multi-Child Diffing Layout)
Automatically diffs every child widget independently. `layout:` is **required** (no implicit layouts):
```dart
// Column layout:
graft.slots(
  layout: (children) => Column(children: children),
  children: (s) => [
    const HeaderBanner(),
    Text(s.name),
    if (s.isVerified) const VerifiedBadge(),
    Text(s.email),
  ],
)

// Custom Layout (Row, Wrap, Stack):
graft.slots(
  layout: (children) => Row(children: children),
  children: (s) => [
    const Icon(Icons.star),
    Text('${s.rating}'),
    Text('(${s.reviews})'),
  ],
)
```

### 3. `graft.compute<R>({required compute, required builder, key})` (Pre-Flight Derived Computation)
Computes a derived value from state first. If the computed value is unchanged, the widget builder is **never even executed**, saving CPU cycles on heavy subtrees:
```dart
graft.compute<int>(
  compute: (s) => s.notifications.length,
  builder: (count) => HeavyBadge(count: count),
)
```

### 4. `graft.builder<T>({required items, required itemBuilder, itemKey, layout, key})` (Virtualized Collections)
Zero-rebuild diffing for virtualized collections (`ListView`, `GridView`, `SliverList`).
- `items`: passed directly once.
- `itemBuilder`: receives `(item, index)` (no redundant `BuildContext`).
- `layout`: defaults automatically to `ListView.builder`.
```dart
graft.builder<TaskItem>(
  items: s.tasks,
  itemBuilder: (task, index) => ListTile(
    title: Text(task.title),
    trailing: Checkbox(
      value: task.isDone,
      onChanged: (_) => graft.toggleTask(task.id),
    ),
  ),
)

// Override layout for GridView or CustomScrollView:
graft.builder<Product>(
  items: s.products,
  layout: (itemCount, itemBuilder) => GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    itemCount: itemCount,
    itemBuilder: itemBuilder,
  ),
  itemBuilder: (product, index) => ProductCard(product: product),
)
```

### 5. `valueGraft.slot({required builder, key})` (Micro-State Cells)
For lightweight single primitives (`int`, `bool`, `String`):
```dart
final count = ValueGraft<int>(0);

count.slot(
  builder: (val) => Text('Count: $val'),
)
```

---

## ⌨️ Developer Ergonomics: IDE Snippets

Graft includes pre-configured snippets for VS Code / Cursor and live templates for Android Studio / IntelliJ:

Run the installer from your project root:
```bash
dart run graft:snippets
```

### Available Snippets:
- `graft-controller`: Scaffold `Graft` + `GraftState` pair.
- `graft-value`: Scaffold lightweight `ValueGraft`.
- `graft-slot`: Single-child isolated slot `graft.slot(builder: (s) => ...)`.
- `graft-slots`: Multi-child isolated slot layout with required `layout:` parameter.
- `graft-builder`: Virtualized collection builder `graft.builder<T>(items: ..., itemBuilder: ...)`.
- `graft-compute`: Pre-flight computed slot `graft.compute<T>(compute: ..., builder: ...)`.
- `graft-test`: Pure Dart declarative unit test template.

---

## 🔍 Compile-Time Lint Enforcement: `graft_lint`

Catch anti-patterns directly in your IDE with the official Graft analyzer plugin:

Add to `dev_dependencies`:
```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  graft_lint: ^0.1.0-alpha.1
```

Enable in `analysis_options.yaml`:
```yaml
analyzer:
  plugins:
    - custom_lint
```

### Included Rules:
- **`avoid_nested_graft_slot`**: Warns at compile-time if a `graft.slot()` is redundantly nested inside another slot or slots engine.
- **`require_graft_route_observer`**: Reminds you to register `GraftRouteTracker.observer` in `MaterialApp.navigatorObservers`.

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
