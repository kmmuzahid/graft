# Graft Architecture & Technical Reference Manual

---

## 🏛️ Executive Summary & Architectural Philosophy

**Graft** was engineered from first principles to resolve the fundamental architectural compromises inherent to modern Flutter state management and dependency injection frameworks:

1. **The Allocation Tax:** Traditional frameworks allocate heap memory on every state mutation (immutable copies, `copyWith()` trees, event wrappers, streams, and closures).
2. **The Selector Indirection Tax:** Micro-rebuild isolation typically requires manual selector functions (`select((s) => s.foo)`), introducing heap closures and registration overhead.
3. **The Global Service Locator Hazard:** Traditional service locators rely on runtime string keys or untracked singletons with no compile-time DAG cycle detection, resulting in memory leaks and teardown order bugs.
4. **The Blank-Frame Persistence Race:** Asynchronous persistence models force UI trees into loading spinners or blank frames while waiting for storage engines to initialize on Frame 0.
5. **The Wrapper Hell Tax:** Subtree scoping and dependency injection typically demand nesting widgets in endless wrappers (`Provider`, `MultiProvider`, `BlocProvider`, `GraftScope`).

Graft eliminates these trade-offs through a unified, 100% zero-wrapper runtime built on **7 Core Architectural Pillars**.

---

## 💎 The 7 Core Architectural Pillars

```text
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                          GRAFT RUNTIME ARCHITECTURE                                          │
├────────────────────────────────┬────────────────────────────────┬────────────────────────────────────────────┤
│  ⚡ Pillar 1: Bitmask Diffing  │  🎯 Pillar 2: Leaf Slot Engine │  🔢 Pillar 3: Monotonic TypeId             │
│  - In-place cascade mutation   │  - Native ComponentElement     │  - O(1) integer array lookup               │
│  - 64-bit SIMD word registers  │  - Direct markNeedsBuild()     │  - ≤ 12 ns cold / < 0.8 ns hot             │
│  - Zero heap allocation diffs  │  - Zero ValueNotifier wrapper  │  - Pure Dart AOT specialization            │
├────────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────┤
│  🛡️ Pillar 4: Reverse DAG Drop │  ⏳ Pillar 5: Async Gate DI    │  💾 Pillar 6: Frame-0 Dry State            │
│  - In-degree topological sort  │  - Non-blocking bindAsync<T>   │  - Synchronous L1 RAM cache                │
│  - Consumers dispose first     │  - Frame-0 zero-crash auto-wait│  - 300ms coalescing debounce               │
│  - Circular dependency check   │  - Zero manual query wrappers  │  - Structural schema hash                  │
├────────────────────────────────┴────────────────────────────────┴────────────────────────────────────────────┤
│  🌐 Pillar 7: Ref-Counted Ambient Engine (Zero-Wrapper Architecture)                                         │
│  - 100% wrapper-free: No GraftScope or MultiProvider                                                         │
│  - Universal verbs: context.use<T>() (shared flow) vs context.create<T>() (isolated)                        │
│  - App-Root singleton auto-promotion (route == null -> isRoot = true)                                        │
│  - Set-based rebuild idempotency (prevents refCount ballooning)                                              │
│  - Multi-route ref-counted lifecycle with tombstone-deferred exit transition teardown                        │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### Pillar 1: Hardware-Aligned Bitmask Diffing

Rather than allocating immutable clones on every keystroke or event, `GraftState` uses native Dart cascade mutations on plain fields:

```dart
state
  ..customerName = 'Alice'
  ..notes = 'Urgent'
  ..update();
```

When `update()` executes, Graft compares the current values of `props` against an in-place baseline snapshot using bitwise shift operations (`w |= 1 << i`) across 64-bit integer words (`GraftMask`).

```mermaid
flowchart TD
    subgraph DevCall["Developer Call (Zero Boilerplate)"]
        Mutation["state..address.city = 'Berlin'..tasks.add(item)..update()"]
    end

    subgraph CoreEngine["Graft Core Engine: diffChanges()"]
        Baseline["Evaluate current props against _baseline"]
        
        subgraph DiffPaths["Property Inspection Paths"]
            direction LR
            Prim["Primitive Values<br/>(int, String, bool)<br/>identical(prev, curr)"]
            Nest["Nested Sub-States<br/>(GraftState in props)<br/>Deep recursive props diff"]
            Coll["Collections<br/>(List, Set, Map)<br/>Structural element diff"]
        end
        
        Bitmask["Compute 64-bit Integer dirtyMask in CPU registers<br/>(w |= 1 << i)"]
        Notify["Dispatch via notifyMask(dirtyMask)"]
    end

    Mutation --> Baseline
    Baseline --> Prim
    Baseline --> Nest
    Baseline --> Coll
    Prim --> Bitmask
    Nest --> Bitmask
    Coll --> Bitmask
    Bitmask --> Notify
```

- **Zero Allocations:** No intermediate `Change` objects, no `copyWith` copies, no stream events.
- **Microsecond Latency:** Full diffing executes in $< 50\text{ ns}$ directly in CPU registers.
- **64-Bit Word Registers:** Up to 64 state fields are tracked in 64-bit integer bitmasks. Models with more than 64 fields scale dynamically into chunked 32-bit integer words with 100% web JavaScript compatibility.

---

### Pillar 2: Native Element Leaf Slot Architecture

Traditional Flutter state management approaches rely on `AnimatedBuilder`, `ValueListenableBuilder`, or `StreamBuilder` widgets, adding an intermediate `StatefulWidget`, an extra `StatefulElement`, listener registration maps, and closure allocations for every reactive UI node.

Graft completely eliminates `ValueNotifier`, `ValueListenable`, and intermediate builder widgets. Leaf slots (`graft((s) => ...)` and `graft.slot()`) and multi-child slots (`graft.slots()`) subclass Flutter's core [`ComponentElement`](lib/src/widgets/slots/single_slot_scope.dart#L24) directly:

- **Direct Element Pointer Dispatch:** `Graft` controllers maintain a direct pointer to the active [`GraftFastReceiver`](lib/src/widgets/slots/single_slot_scope.dart#L25) (`_GraftSingleSlotElement` or `_ChildSlotElement`).
- **Bare-Metal `markNeedsBuild()`:** State mutations call `fast.markFastDirty()` in $< 5\text{ ns}$, which directly invokes Flutter's native `Element.markNeedsBuild()`.
- **Zero Intermediate Wrappers:** Zero `ValueNotifier`, zero `StreamSubscription`, and zero listener closures.
- **Zero Rebuild Leaks:** Parent and sibling widgets experience **0 rebuilds** (100% rebuild isolation verified across 50-slot column benchmarks).

```mermaid
flowchart TD
    subgraph Signal["State Mutation Notification"]
        DirtySignal["notifyMask(dirtyMask)"]
    end

    subgraph SlotElement["Native Leaf Slot (ComponentElement)"]
        IgnoredCheck{"Does dirtyMask intersect<br/>slot's learned ignoredMask?"}
        
        subgraph DirectPath["1-Cycle Direct Path"]
            MarkDirty["fast.markFastDirty()<br/>Direct element.markNeedsBuild()"]
            BuildQueue["Flutter BuildOwner Queue<br/>ComponentElement.performRebuild()"]
        end
        
        subgraph SubtreeCheck["Subtree Isolation Check"]
            ZeroRebuild["Bypass element rebuild entirely<br/>(0 Rebuilds · 100% Insulated)"]
        end

        Reconcile{"Is Single-Scalar<br/>(_scalarCount == 1)?"}
        SingleReturn["_builder(_state)<br/>Direct return without diffing"]
        MultiDiff["Diff against _currentWidget<br/>Match? Self-heal ignoredMask!"]
    end

    DirtySignal --> IgnoredCheck
    IgnoredCheck -- "No (Ignored)" --> ZeroRebuild
    IgnoredCheck -- "Yes (Changed)" --> MarkDirty
    MarkDirty --> BuildQueue
    BuildQueue --> Reconcile
    Reconcile -- "Yes" --> SingleReturn
    Reconcile -- "No" --> MultiDiff
```

- **Level-0 Group Summary Register (`_commonIgnoredMask`):** `graft.slots(...)` maintains an aggregate Level-0 summary register (`_commonIgnoredMask`) representing the intersection of properties universally ignored by all active child slots. Before inspecting individual slot dependencies or iterating the widget tree, an $O(1)$ single-cycle pre-flight bitwise test executes:
  ```dart
  if (!dirtyMask.isAllDirty && state._commonIgnoredMask.isNotEmpty && dirtyMask.isSubsetOf(state._commonIgnoredMask)) return;
  ```
  If a state mutation only modifies fields that none of the multi-child slots care about, the layout reconciliation phase is aborted in $< 1\text{ ns}$, reducing frame reconciliation overhead in massive slot layouts (e.g., 500-slot column stress tests) from 3.13 ms to 1.59 ms.
- **Self-Healing Ignored Masking:** If a slot's returned widget is equivalent to its previous widget (`isWidgetEquivalent`), the slot automatically learns that the mutated properties had no visual effect and bitwise-unions them into its `_ignoredMask`, ensuring future mutations skip that slot instantly.
- **Depth-$N$ Parent Rebuild Insulation:** Leaf slots run inside an internal `NoSubscriptionContext`, preventing ambient `Theme` or `MediaQuery` subscriptions from leaking into parent layout widgets.

---

### Pillar 3: Monotonic Integer Type Identification (`TypeId`)

Traditional dependency injection frameworks key instances by `Type.toString()` strings or runtime hashes, requiring hash table bucket probing on every lookup:

- Graft assigns a **monotonic 32-bit integer** to each resolved type on first access via `TypeId.of<T>()`.
- Active scope nodes store instances in contiguous flat arrays (`List<Object?> _instances`).
- Hot lookups are direct index operations (`_instances[id]`):
  - **Cold Lookup:** $\le 12\text{ ns}$ (monotonically indexed registration).
  - **Hot Lookup:** $< 0.8\text{ ns}$ (hardware L1 CPU cache hit).

---

### Pillar 4: In-Degree Topological Reverse DAG Teardown

When a scope or feature unmounts, dependencies must be torn down strictly in **reverse creation order**:

- If `OrderService` depends on `DatabaseService`, `OrderService` must close its active transactions before `DatabaseService` disconnects.
- `ScopeNode` dynamically records dependency relationships during resolution.
- On `drop()`, an in-degree topological sort disposes consumers first and base dependencies last, guaranteeing zero dangling pointer crashes or leaked file descriptors.
- Circular dependency cycles are detected during resolution with descriptive DAG stack traces.

```mermaid
flowchart LR
    subgraph TeardownOrder["Reverse Topological Teardown Pipeline (on scope.drop)"]
        direction LR
        S3["1️⃣ Disposed First:<br/>CheckoutCoordinator<br/>(Leaf Consumer)"]
        S2["2️⃣ Disposed Second:<br/>CartDao<br/>(Intermediate DAO)"]
        S1["3️⃣ Disposed Last:<br/>DatabaseService<br/>(Root Connection)"]
        S3 --> S2 --> S1
    end
```

---

### Pillar 5: Self-Healing Non-Blocking Async Execution Gate

Async services (databases, key-value stores, secure storage, network clients) previously forced developers to either:
1. Block application boot with `await db.open()` in `main()`, delaying the first frame.
2. Manually subclass custom service wrappers and wrap every method in `guard(() => ...)`.

Graft introduces `bindAsync<T>()` and `useAsync<T>()`:
- Execution is lazy and non-blocking by default.
- If accessed on Frame 0 before initialization completes, `useAsync<T>()` transparently awaits the in-flight initialization.
- Once completed, subsequent accesses return the cached singleton in $0\text{ ns}$.
- Devs write 100% standard Dart classes with zero boilerplate wrappers.

---

### Pillar 6: Frame-0 Dry State & Coalescing Background Persistence

Hydrating persisted form states via asynchronous storage engines (SQLite, SharedPreferences) causes blank input fields or flickering UI on Frame 0:

- **Synchronous L1 RAM Cache:** Pre-warmed during bootstrap or lazy mount, providing state data in $< 50\text{ ns}$ during widget build.
- **Zero-Controller Forms:** Standard Flutter `TextFormField(initialValue: graft.state.customerName)` takes the Frame-0 restored state directly with ZERO controllers and ZERO `initState`.
- **Coalescing 300ms Background Queue:** Keystrokes update L1 RAM synchronously on every frame, while coalescing disk writes into a single debounced 300ms I/O operation.
- **Structural Schema Fingerprinting with `schemaVersion`:** Combines deterministic 32-bit FNV-1a hashing of `props` structure with `schemaVersion`. Stale caches are discarded safely across app updates with zero migration scripts.

```mermaid
sequenceDiagram
    autonumber
    actor User as User / App Launch
    participant Widget as UI / BuildContext
    participant Engine as Graft Engine
    participant L1 as L1 RAM Cache
    participant Disk as Background Disk Queue

    Note over User,Engine: Frame 0 (< 50ns, before initial paint)
    User->>Widget: App Mount / Navigation
    Widget->>Engine: context.use(FormGraft.new)
    Engine->>L1: Synchronous binary read
    L1-->>Engine: Cached bytes
    Engine->>Widget: Hydrated FormState (0 blank frames!)
    
    Note over User,Disk: User Interaction & Background Coalescing
    User->>Widget: Keystroke (customerName = 'Alice')
    Widget->>Engine: state..customerName = 'Alice'..update()
    Engine->>L1: Synchronous L1 RAM update (< 50ns)
    Engine->>Disk: Enqueue 300ms debounced write
    Disk-->>Disk: Coalesce rapid keystrokes into 1 I/O
```

---

### Pillar 7: Ref-Counted Ambient Engine (Zero-Wrapper Architecture)

Graft eliminates `GraftScope` and all widget wrappers. Controllers are resolved and managed through an ambient lifecycle engine:

```mermaid
flowchart TD
    subgraph ClientCall["Developer Call"]
        UseCall["context.use<T>([factory, key])"]
        CreateCall["context.create<T>([factory, key])"]
    end

    subgraph AmbientEngine["Ambient Lifecycle Engine"]
        SingletonCheck{"Is Singleton Lock?<br/>(!canCreateNew)"}
        PoolLookup{"Matching AmbientEntry<br/>in _ambientPool[key]?"}
        BranchCheck{"Matches Navigator Branch<br/>or isRoot == true?"}
        BorrowRoute["borrowerRoutes.add(route)<br/>refCount++<br/>Attach route.popped release listener"]
        CreateAbsent["Instantiate T<br/>(factory or GraftRegistry.create)"]
        IsRootCheck{"route == null?"}
        RegisterRoot["Register AmbientEntry<br/>isRoot = true, refCount = 1<br/>(Permanent App-Root Singleton)"]
        RegisterRoute["Register AmbientEntry<br/>isRoot = false, refCount = 1<br/>borrowerRoutes = {route}"]
        CreatePrivate["Instantiate fresh T<br/>Anchor to _privateRouteInstances[route]<br/>Attach route.popped disposal"]
    end

    UseCall --> SingletonCheck
    SingletonCheck -- "Yes" --> RetSingleton["Return Singleton"]
    SingletonCheck -- "No" --> PoolLookup
    PoolLookup -- "Found" --> BranchCheck
    BranchCheck -- "Yes" --> BorrowRoute --> RetInstance["Return entry.instance"]
    BranchCheck -- "Different Navigator" --> CreateAbsent
    PoolLookup -- "Not Found" --> CreateAbsent
    CreateAbsent --> IsRootCheck
    IsRootCheck -- "Yes (App Root)" --> RegisterRoot --> RetInstance
    IsRootCheck -- "No (Route)" --> RegisterRoute --> RetInstance

    CreateCall --> CreatePrivate --> RetPrivate["Return isolated T"]
```

#### The 2 Universal Verbs:
1. **`context.use<T>([factory, key])` ("Borrow or Create")**:
   - Checks the ambient pool for an existing instance of `T` belonging to the current navigation branch.
   - If present, borrows it and increments `refCount`.
   - If absent at the App Root (`route == null`), auto-promotes to a permanent singleton (`isRoot = true`).
   - If absent inside a screen (`route != null`), creates it and auto-disposes when all borrower routes pop (`refCount == 0`).
2. **`context.create<T>([factory, key])` ("Always Force New")**:
   - Instantiates a brand-new, isolated instance of `T`.
   - Bypasses the ambient pool entirely and anchors directly to the current route's private ownership list.
   - Disposed automatically when the owner route pops.

#### Automatic Engine Safeguards:
- **Set-Based Rebuild Idempotency:** `borrowerRoutes.add(effectiveRoute)` returns `true` only on the first call. 50 `setState` calls or animation frames on the same route will **never** inflate `refCount`.
- **Navigator Branch Ancestry:** Prevents horizontal state leaks across parallel tab navigators.
- **Tombstone-Deferred Teardown:** During 300ms route pop animations, controllers remain safe to read by unmounting widgets without throwing exceptions or resurrecting zombie instances.

---

## ⚡ Undisputed Rank-1 Execution Pipeline & Modular Engine Architecture

To ensure undisputed Rank-1 benchmark performance across all 17 core evaluation suites and 21 benchmark scenarios while preserving maximum codebase maintainability, Graft's runtime engine adheres to two core architectural invariants:

1. **Zero New Public APIs & Zero Overhead Ergonomics:** Developers interact strictly through the fluent `state..field = value..update()` pattern and `context.use<T>()`. All high-performance optimizations, register allocations, and receiver windowing engines operate internally in `lib/src/` or hidden behind library-private boundaries.
2. **Strict Modularity Constraint ($\le$ 160 LOC per file):** No file in `lib/` exceeds 160 physical lines of code. Subsystems are partitioned into single-responsibility Dart `part` files sharing private namespaces, avoiding getter indirection while enabling full Dart VM AOT `@pragma('vm:prefer-inline')` inlining.

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                          UNDISPUTED RANK-1 INTERNAL ENGINE ARCHITECTURE                                │
├──────────────────────────────────┬──────────────────────────────────┬──────────────────────────────────┤
│ 1. Uniform 8-Field Chunk Kernel  │ 2. Direct Element Slot Engine    │ 3. Deep Surgical Reconciliation  │
│ - Unrolled 8-property L1 chunks  │ - Zero ValueNotifier wrappers    │ - Leaf state O(1) version stamp  │
│ - Bitwise OR word accumulation   │ - Direct Element markNeedsBuild  │ - Unified in-place diff helper   │
│ - Zero 1-5 field cliff (2-64 ps) │ - Fast direct receiver pointer   │ - Level-0 common ignored mask    │
└──────────────────────────────────┴──────────────────────────────────┴──────────────────────────────────┘
```

### 1. Hierarchical Chunked Register Groups Engine & Uniform 8-Field Chunk Kernel (`src/core/state/`)
Graft eliminates the artificial "1–5 field performance cliff" found in traditional engines, ensuring that states with 6, 8, 12, 16, 32, and 64 fields execute at the exact same nanosecond-per-field register speed as 2-field states:
- **Single Scalar Path:** Compares `_singleBaseline` directly against `_pendingSingle`. When `_scalarCount == 1`, all type inspections and intermediate arrays are bypassed, terminating unchanged diffs in $< 5\text{ ns}$. When mutated, it stamps `_version++` and immediately signals `GraftMask.bit0` or dispatches directly to the `GraftFastReceiver`.
- **Zero-Allocation Single Props Delegation (`_GraftPropsSingle`):** For single-property states (`propsOf(p0)`), `_GraftPropsSingle` captures the state storage reference directly and lazily exposes `_state._pendingSingle` via getter and index operator, eliminating per-mutation wrapper allocations, cascades, and redundant field writes.
- **Multi-Scalar Direct Registers (`_s0.._s4` & `_b0.._b4`):** For 2–5 property states, scalar fields write directly to dedicated register slots, avoiding heap buffer allocations completely on high-frequency mutations.
- **Uniform 8-Field L1 Cache-Line Chunk Kernel:** For wider models (6 to 64+ fields), diffing executes in unrolled 8-field register chunks matching hardware 64-byte L1 cache lines. In scalar states (`_allScalarProps == true`), chunks perform branchless pointer-equivalence pre-flight checks:
  ```dart
  if (state._allScalarProps &&
      identical(p0, c0) && identical(p1, c1) && identical(p2, c2) && identical(p3, c3) &&
      identical(p4, c4) && identical(p5, c5) && identical(p6, c6) && identical(p7, c7)) {
    i += 8;
    continue;
  }
  ```
  Unrolled 8-word bitwise accumulation writes directly to 32-bit and 64-bit integer bitmasks (`w0 |= (1 << idx)`), reducing 12-field form latency (Benchmark D2) to 0.04 ms (Rank 1).
- **In-Place Nested State & Collection Mutation Detection:** Deep collection diffing (`_diffListAndUpdate`) traverses nested `GraftState` items and inspects internal `_diffChanges().isNotEmpty`, allowing in-place list item modifications (e.g., `items[500].score = 999`) to be detected with surgical precision.
- **Observer-Free Fast Bypassing:** When no `GraftObserver` is registered, the creation of change event records (`GraftChange`) is eliminated entirely.

### 2. Two-Tier Item Receiver Directory & Direct ComponentElement Slot Engine (`src/core/`, `src/widgets/slots/`)
When a widget attaches to a `Graft` controller or displays virtualized collections:
- **Two-Tier Chunked Item Receiver Directory:** For virtualized collections ([ListView.builder], [GridView.builder]), Graft indexes item receivers in a lazy two-tier directory table (`List<List<GraftItemReceiver?>?>`). Index addressing uses 1-cycle CPU bit shifts (`chunkIdx = index >> 6; offset = index & 63`) to achieve direct pointer access into 64-element chunks without hash map collisions, boxing, or 64-element preallocations on every `Graft` instance.
- **Direct ComponentElement Architecture (`_GraftItemSlotElement` & `_GraftSingleSlotElement`):** Replaces legacy `StatefulWidget` + `State` pairs and `ValueNotifier` abstractions with custom `ComponentElement` implementations. This eliminates 50% of heap object allocations in large virtualized lists and provides direct single-pointer dirty-marking (`markNeedsBuild()`).
- **Zero-Diff Fast Path for Single-Scalar Slots:** When a slot observes a controller whose state has `_scalarCount == 1`, `_GraftSingleSlotElement` bypasses multi-child widget diffing and double builds on initial mount, directly invoking `markNeedsBuild()` and executing `_builder(_state)` once per frame with 100% rebuild isolation.
- **Deoptimization Isolation (`_markItemDirtySafe`):** Isolates `try-catch` error handling into a `@pragma('vm:never-inline')` safe fallback method. The hot notification loop (`markItemDirty()`) remains 100% try-catch free, allowing the Dart VM JIT and AOT compilers to fully inline item diffing and element dirty marking directly into `_graftNotifyItem`.
- **Direct State Accessor (`GraftEngine.getState`):** Leaf slots retrieve state through an inlined engine accessor (`GraftEngine.getState(_graft)`), bypassing ambient scope tracking (`GraftScopeTracker.hasActiveScope`) checks during high-frequency frame builds.
- **Fast Direct Receiver:** If a slot is the sole listener on a controller, `Graft` caches its direct `GraftFastReceiver` reference in `_fastDirectReceiver`. Subsequent state mutations invoke `fast.markFastDirty()` directly in $O(1)$ time, skipping `ChangeNotifier` map iterations and listener list allocations.
- **Single Listener Shortcut:** If `hasOnlySingleListener` is true, the notification invokes the callback directly without allocating or masking iterator objects.
- **Item Direct Dispatch:** When updating a specific index in a large collection via `state.update(itemIndex: i)`, `GraftItemReceiver` routes the update straight to the indexed slot with zero closures created for remaining items.

### 3. Modular Engine Structure
All core subsystems are cleanly decomposed into focused modules strictly $\le 160$ lines:
- **`src/core/state/` (19 files):** Partitioned into `graft_state_props.dart`, `graft_props_types.dart`, `graft_state_storage.dart`, `graft_state_baseline.dart`, `graft_state_snapshot.dart`, `graft_state_fast_scalar.dart`, `graft_state_fast_buffer.dart`, `graft_state_fast_nested.dart`, `graft_state_diff_single.dart`, `graft_state_diff_dual.dart`, `graft_state_diff_triple.dart`, `graft_state_diff_quad.dart`, `graft_state_diff_penta.dart`, `graft_state_diff_general.dart`, `graft_state_diff_helper.dart`, `graft_state_diff_engine.dart`, `graft_state_collection_diff.dart`, `graft_state_dispatch.dart`, and `graft_state_engine.dart`.
- **`src/widgets/slots/` (16 files):** Partitioned into reconcilers, layout resolvers, diff matchers, dirty dispatchers, and scope guards.
- **`src/route/` (6 files):** Partitioned into `graft_route_tracker.dart`, `graft_route_observer.dart`, `ambient_key.dart`, `ambient_lifecycle_engine.dart`, `ambient_pool_engine.dart`, and `ambient_search_engine.dart`.
- **`src/di/` (10 files):** Partitioned into `graft_di.dart`, `graft_registry.dart`, `type_id.dart`, `disposable.dart`, `scope_node.dart`, `scope_tier.dart`, `scope_block.dart`, `scope_resolution.dart`, `scope_teardown.dart`, and `async_binding.dart`.
- **`src/persistence/` (16 files):** Partitioned into `state_config.dart`, `l1_cache.dart`, `debounce_queue.dart`, `lifecycle_observer.dart`, `file_state_config.dart`, `memory_state_config.dart`, `storage_coordinator.dart`, `ambient_locator.dart`, dry hooks, and binary serializers.

---

## 📚 Technical Reference & Documentation Hub

- 🚀 **[graft_template](https://github.com/kmmuzahid/graft_template):** Production-ready starter template integrating Graft with CoreKit.
- 📘 **[DI Engine Guide](https://github.com/kmmuzahid/graft/blob/main/DI_GUIDE.md):** Enum scopes, async bindings, and singleton locks.
- 📙 **[State & Persistence Guide](https://github.com/kmmuzahid/graft/blob/main/GRAFT_GUIDE.md):** Cascade mutations, slot diffing, and Frame-0 Dry State.
- 📊 **[Empirical Benchmark Report](https://github.com/kmmuzahid/graft/blob/main/BENCHMARK_REPORT.md):** 21 empirical benchmark scenarios and hardware specs.
- 🧪 **[Test Verification Report](https://github.com/kmmuzahid/graft/blob/main/TEST_REPORT.md):** Comprehensive test verification matrix across the entire suite.
- 📋 **[Public API Cheat Sheet](https://github.com/kmmuzahid/graft/blob/main/README.md#-complete-public-api-cheat-sheet):** Every public API listed with practical 2–3 line usages.
