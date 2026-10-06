# Graft 🌱

**Graft is the first self-optimizing state management engine for Flutter: providing the clean domain architecture of BLoC, the micro-rebuild precision of Signals, and the register-level diffing speed of a hardware bitmask.**

[![pub package](https://img.shields.io/pub/v/graft.svg?include_prereleases&color=blue)](https://pub.dev/packages/graft)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/kmmuzahid/graft/blob/main/LICENSE)
[![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kmmuzahid/graft)
[![Flutter 3.10+](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

> [!IMPORTANT]
> ### 🚀 Graft is in Public Alpha (`0.1.2-alpha.3`) — Let's Have a Ride!
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
2. **Mandatory `props` & Recursive Snapshot Contract:** Domain properties are declared via `List<Object?> get props;`, an abstract compiler-enforced contract. Graft uses recursive deep snapshotting for nested `GraftState` sub-states and collections, eliminating forgotten fields and ensuring 100% snapshot integrity during in-place cascade mutations.
3. **Unbounded Hardware-Aligned `GraftMask`:** State field modifications are mapped into an unbounded, 32-bit chunked word-based bitset (`GraftMask`). It diffs $\le 64$ fields in CPU registers and effortlessly scales to 128, 500, or 1000+ fields with 100% web JS compatibility and 0 GC heap allocations.
4. **Synchronous In-Place Mutation & Reset:** Direct synchronous updates via `state..field = val..update()` and complete baseline resets via `state.reset()`. Primitives, nested models, and collection items are accurately diffed without requiring immutable `copyWith` methods.
5. **Two-Wrapper Architecture & Context Decoupling:**
   - **`GraftBoundary`**: High-level subtree rebuild barrier featuring **Ambient Auto-Discovery** (zero manual lists via `GraftScopeTracker`) and **Backward Adaptive Learning** with multi-field bitwise union accumulation.
   - **`graft((s) => ...)`**: Fine-grained surgical leaf slot with Depth-$N$ parent rebuild insulation, powered by `NoSubscriptionContext` to prevent `Theme`/`MediaQuery` subscription bleeding during widget diffing.
6. **Automatic Route-Aware Lifecycle & PopupRoute Protection:** Controllers automatically inherit down predecessor routes and cleanly self-dispose when their owning screen route pops. Transient routes (`showDialog`, `showModalBottomSheet`) borrow safely without prematurely disposing host controllers via `resolveOwnerRoute`.

---

## 🏗️ Architecture: Hardware-Aligned Pipeline

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      DEVELOPER CALL (ZERO BOILERPLATE)                 │
│         state..address.city = 'Berlin'..tasks.add(item)..update()      │
│                                  OR                                    │
│             produce((s) => s..address.city = 'Munich')                 │
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
│            (Fast in-place cascade OR Copy-on-Write produce)            │
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

---

## 🔄 Unified End-to-End Runtime Lifecycle

```text
Navigator / UI                 Graft Tracker & Context           Graft Controller & State          UI Slot Reconciliation            Remote API
      │                                   │                                  │                               │                           │
      │── 1. ROUTE SCOPING & TRANSIENT POPUP PROTECTION (context.use<T>()) ─│───────────────────────────────│───────────────────────────│
      │   Push Route A (PageRoute) ──────►│                                  │                               │                           │
      │   context.use<UserGraft>() ──────►│── Instantiate UserGraft() ──────►│                               │                           │
      │   Open Dialog (PopupRoute) ──────►│   resolveOwnerRoute(PopupRoute)  │                               │                           │
      │   dialog.use<UserGraft>() ───────►│   Anchors ownership to Route A!  │                               │                           │
      │   Dismiss Dialog ────────────────►│   Dialog closes, Graft remains!  │                               │                           │
      │                                   │                                  │                               │                           │
      │── 2. ATOMIC CASCADE MUTATION & SELF-HEALING OPTIMIZATION ────────────│───────────────────────────────│───────────────────────────│
      │── state..city = 'Berlin'..update()┼─────────────────────────────────►│                               │                           │
      │                                   │                                  │── diffChanges() vs baseline   │                           │
      │                                   │                                  │   Compute dirtyMask bitset    │                           │
      │                                   │                                  │── notifyMask(dirtyMask) ─────►│                           │
      │                                   │                                  │                               ├── [Known Clean (mask=0)]  │
      │                                   │                                  │                               │   ⚡ 1-cycle bypass (0 bld)│
      │                                   │                                  │                               ├── [Known Dirty (mask!=0)] │
      │                                   │                                  │                               │   🔄 Surgical leaf rebuild│
      │                                   │                                  │                               └── [Unlearned Field]       │
      │                                   │                                  │                                   🔬 Fingerprint check    │
      │                                   │                                  │                                   🩹 Self-heal mask union │
      │                                   │                                  │                                                           │
      │── 3. ASYNC CONCURRENCY & DECLARATIVE BINDING (runAsync) ─────────────│───────────────────────────────│───────────────────────────│
      │── Keystroke 1 ("da") ─────────────┼─────────────────────────────────►│── runAsync() [Task #1] ───────┼──────────────────────────►│
      │── Keystroke 2 ("dart") ───────────┼─────────────────────────────────►│── runAsync() [Task #2] ───────┼──────────────────────────►│
      │                                   │                                  │                               │◄── Task #1 finishes late ─│
      │                                   │                                  │   TaskId #1 != current (#2)   │    (STALE: DROPPED!)      │
      │                                   │                                  │                               │◄── Task #2 finishes fresh │
      │                                   │                                  │   TaskId #2 == current (#2)   │    (FRESH: ACCEPTED)      │
      │                                   │                                  │── emit(data: resultDart) ────►│── Update leaf results ────►│
      │                                   │                                  │                               │                           │
      │── 4. POP ROUTE & AUTOMATIC LEAK-FREE DISPOSAL ───────────────────────│───────────────────────────────│───────────────────────────│
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

All benchmark metrics in Graft are backed by reproducible test suites checked directly into the repository in [`test/benchmark/`](test/benchmark).

### 🏆 Cross-Framework Benchmarks: Graft vs BLoC vs Riverpod vs Signals vs GetX

Tested on Flutter 3.47.6 / Dart 3.13.5 (macOS ARM64):

| Benchmark Scenario | 🥇 1st Place | 🥈 2nd Place | 3rd Place | 4th Place | 5th Place |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Diamond Dependency DAG** (5k updates) | BLoC (1.89 ms) | **Graft (4.19 ms) ⚡** | Signals (15.97 ms) | Riverpod (54.62 ms) | GetX (5,000 glitches ⚠️) |
| **Deep Reactive Chain** (10 lvl, 5k updates)| BLoC (2.14 ms) | **Graft (4.42 ms) ⚡** | GetX (6.45 ms) | Signals (29.77 ms) | Riverpod (150.06 ms) |
| **Multi-Field Batching** (2k batches) | BLoC (0.56 ms) | **Graft (3.68 ms) ⚡** | Riverpod (5.16 ms) | Signals (10.06 ms) | GetX (0% batched ⚠️) |
| **Real 5-Field Domain Model** (10k ops) | GetX (2.42 ms) | **Graft (4.73 ms) ⚡** | BLoC (5.07 ms) | Riverpod (10.28 ms)| Signals (17.33 ms) |
| **Fine-Grained (50 Nodes)** (5k ops) | GetX (2.42 ms) | **Graft (7.19 ms) ⚡** | Signals (10.73 ms) | BLoC (25.10 ms) | Riverpod (30.70 ms) |
| **16-Field Enterprise GC Churn** (20k ops) | GetX (0 GC) | **Graft (0 GC) ⚡** | Signals (0 GC) | BLoC (20k objs ⚠️) | Riverpod (20k objs ⚠️) |
| **60-Frame Widget Tree Rebuilds** | GetX (0 wasted) | **Graft (0 wasted) ⚡** | Signals (0 wasted) | Riverpod (0 wasted)| Vanilla (540 wasted ⚠️)|

#### A. The Reactive Diamond Dependency & Glitch-Free Test (`test/benchmark/reactive_diamond_and_dag_benchmark_test.dart`)
Root node `A` branches to `B` and `C`, which both merge into `D`. Measures topological propagation consistency.

| Framework | Total Time (ms) | Evals of D | Glitches Detected | Consistency Status | Rank |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BLoC** | **1.89 ms** | 5,000 | 0 | 100% Glitch-Free | 🥇 1st |
| **Graft** | **4.19 ms** | 5,000 | **0** | **100% Glitch-Free** ⚡ | 🥈 **2nd** |
| **GetX** | **5.45 ms** | 10,000 | **5,000 Glitches** | ⚠️ **FAILED (Inconsistent)** | 5th |
| **Signals** | **15.97 ms** | 5,001 | 0 | 100% Glitch-Free (DAG) | 3rd |
| **Riverpod** | **54.62 ms** | 5,001 | 0 | 100% Glitch-Free (Graph) | 4th |

#### B. Deep Reactive Computed Chain (`test/benchmark/reactive_deep_chain_benchmark_test.dart`)
10 consecutive computed derived levels (`L1 -> L2 -> ... -> L10`) evaluated over 5,000 updates.

| Framework | Total Time (ms) | Latency / Update | Propagation Model | Rank |
| :--- | :--- | :--- | :--- | :--- |
| **BLoC** | **2.14 ms** | 0.43 µs | Synchronous event pipeline | 🥇 1st |
| **Graft** | **4.42 ms** | **0.88 µs** | **In-place computed propagation** ⚡ | 🥈 **2nd** |
| **GetX** | **6.45 ms** | 1.29 µs | Reactive callbacks | 🥉 3rd |
| **Signals** | **29.77 ms** | 5.95 µs | Dynamic DAG traversal | 4th |
| **Riverpod** | **150.06 ms** | 30.01 µs | ProviderContainer graph | 5th |

#### C. Transactional Multi-Field Batching (`test/benchmark/reactive_batching_benchmark_test.dart`)
2,000 transactions modifying 5 fields simultaneously (10,000 total mutations).

| Framework | Total Time (ms) | Notifications Fired | Batching Mechanism | Efficiency | Rank |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BLoC** | **0.56 ms** | 2,000 | Event-based emit | 100% Batched | 🥇 1st |
| **Graft** | **3.68 ms** | 2,000 | **Automatic Fluent Cascade** ⚡ | **100% Batched** | 🥈 **2nd** |
| **Riverpod** | **5.16 ms** | 2,000 | StateNotifier copyWith | 100% Batched | 🥉 3rd |
| **Signals** | **10.06 ms** | 2,000 | Manual `batch(() { ... })` | 100% Batched | 4th |
| **GetX** | **2.50 ms** | 10,000 | Individual `obs` assignments | ⚠️ **0% Batched (5x fires)** | 5th |

#### D. 16-Field Enterprise GC Churn (`test/benchmark/sixteen_field_deep_tree_gc_benchmark_test.dart`)
20,000 rapid mutations across a 16-field domain model measuring memory allocation pressure and GC pauses.

| Framework | Total Time (ms) | Heap Allocations Generated | GC Churn Status |
| :--- | :--- | :--- | :--- |
| **GetX** | **6.24 ms** | **0 Objects** | Clean |
| **Graft** | **13.46 ms** | **0 Objects (ZERO GC)** ⚡ | **Clean (In-Place Mutation)** |
| **Signals** | **24.95 ms** | **0 Objects** | Clean |
| **BLoC** | **5.60 ms** | **20,000 State Objects** | ⚠️ High Heap Allocation |
| **Riverpod** | **25.79 ms** | **20,000 State Objects** | ⚠️ High Heap Allocation |

#### E. Fine-Grained 50-Node Reactivity (`test/benchmark/fine_grained_reactivity_benchmark_test.dart`)
50 independent state fields observed by 50 independent consumer nodes across 5,000 targeted mutations.

| Framework | Total Time (ms) | Consumer Dispatches | Check Mechanism | Rank |
| :--- | :--- | :--- | :--- | :--- |
| **GetX** | **2.42 ms** | 5,000 | Direct callback list | 🥇 1st |
| **Graft** | **7.19 ms** | 5,000 | **1-Cycle Hardware Bitmask (`_w0 & mask`)** ⚡ | 🥈 **2nd** |
| **Signals** | **10.73 ms** | 5,000 | Node subscriber list | 🥉 3rd |
| **BLoC** | **25.10 ms** | 5,000 | 250,000 selector closures (50x/emit) | 4th |
| **Riverpod** | **30.70 ms** | 5,000 | 250,050 selector closures (50x/emit) | 5th |

---

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
# 00:24 +181: All tests passed!
```

```bash
fvm dart analyze
# No issues found!
```

### 📋 Test Suite Breakdown (181 / 181 Tests Passing)

| Architectural Domain | Test Suite Files | What Is Verified |
| :--- | :--- | :--- |
| **State & Collections** | `test/graft_state_test.dart`<br>`test/nested_inplace_mutation_test.dart`<br>`test/collection_mutation_test.dart`<br>`test/graft_mask_test.dart`<br>`test/large_state_bitmask_test.dart` | In-place baseline mutations (`List`, `Set`, `Map`), recursive deep snapshotting for nested `GraftState` sub-states, 64-bit integer bitmasks, unbounded mask growth to 1,000+ fields, and synchronous reset. |
| **Rebuild Firewall & Diff Engine** | `test/context_isolation_leak_test.dart`<br>`test/deterministic_slot_bitmask_test.dart`<br>`test/bitmask_preflight_test.dart`<br>`test/safe_ast_context_test.dart`<br>`test/depth_n_isolation_test.dart`<br>`test/slot_engine_test.dart`<br>`test/slot_engine_deep_diff_test.dart`<br>`test/multi_field_slot_test.dart`<br>`test/disordering_test.dart`<br>`test/dynamic_branch_test.dart` | `NoSubscriptionContext` preventing `Theme`/`MediaQuery` dependency leaks during AST diffing, multi-field bitmask union accumulation, 1-cycle bitmask pre-flight bypass, safe AST widget diffing without out-of-band builds, Depth-$N$ parent container insulation, dynamic if/else branching, and multi-field bitmask accumulation. |
| **Auto-Discovery & Tickers** | `test/graft_boundary_test.dart`<br>`test/multi_graft_combinator_test.dart`<br>`test/animation_isolation_test.dart` | Ambient auto-discovery across multiple controllers, backward adaptive learning, 60fps/120fps continuous animation isolation, and ticker lifecycle safety. |
| **Routing & Lifecycle** | `test/dialog_popup_lifecycle_test.dart`<br>`test/graft_route_test.dart`<br>`test/graft_route_extended_test.dart`<br>`test/nested_route_isolation_test.dart`<br>`test/lifecycle_test.dart` | `context.use<T>()` route-stack borrowing, transient `PopupRoute` dialog and bottom sheet safety with `resolveOwnerRoute` anchoring, parallel navigator isolation (bottom navigation tabs & GoRouter `StatefulShellRoute`), and automatic leak-free disposal on host `route.popped`. |
| **Async Concurrency & Slots** | `test/async_concurrency_race_test.dart`<br>`test/coalescing_test.dart`<br>`test/graft_async_widget_test.dart` | Internal task token guard (`_currentAsyncTaskId`), automatic dropping of out-of-order stale responses, declarative pattern-matched `graft.async` slots, and synchronous microtask reentrancy coalescing. |
| **Comparative Benchmarks & Tooling** | `test/benchmark/reactive_diamond_and_dag_benchmark_test.dart`<br>`test/benchmark/reactive_deep_chain_benchmark_test.dart`<br>`test/benchmark/reactive_batching_benchmark_test.dart`<br>`test/benchmark/fine_grained_reactivity_benchmark_test.dart`<br>`test/benchmark/sixteen_field_deep_tree_gc_benchmark_test.dart`<br>`test/benchmark/real_world_production_benchmark_test.dart`<br>`test/benchmark/widget_rebuild_benchmark_test.dart`<br>`test/zero_allocation_benchmark_test.dart`<br>`test/benchmark/column_rebuild_benchmark_test.dart`<br>`test/large_list_benchmark_test.dart` | Cross-framework comparison against BLoC, Riverpod, Signals, and GetX (Diamond DAG, deep chains, multi-field cascade batching, fine-grained 50-node reactivity, 16-field 0-GC churn, 60-frame widget rebuilds, 10,000-item virtualized list diffing). |

---

## 📄 License

MIT License. Free to use, modify, and distribute.
