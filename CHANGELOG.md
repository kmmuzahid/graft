# Changelog

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 0.1.2-alpha.4

### ⚡ Adaptive Pre-Flight Bypass & Zero-Allocation Nested Diffing
- **Adaptive Multi-Slot Pre-Flight Bypass (`ignoredMask`)**:
  - Added `ignoredMask` tracking to `SlotMetadata` to cache domain property indices that have been proven not to affect a slot's rendered output.
  - Implemented whole-layout pre-flight short-circuiting in `GraftMultiChildDiffEngineState._onStateDirty`: skips calling `childrenBuilder` and avoids all widget heap allocations when the active `dirtyMask` is covered by all slots' learned ignore masks.
  - Added slot-level ignore checks inside the reconciliation loop, eliminating redundant `isWidgetEquivalent` evaluations once a slot's ignore mask is cached.
  - Added automatic ignore mask invalidation on `reassemble()` and `didUpdateWidget()` for full Flutter hot reload safety.
  - Verified in `test/adaptive_slot_preflight_test.dart`.
- **Zero-Allocation Nested State Diffing**:
  - Optimized `GraftState.diffChanges` for nested `GraftState` models: compares sub-props directly against baseline snapshots, eliminating redundant snapshot list allocations on unchanged frames.
  - Inlined `_deepEquals` with `@pragma('vm:prefer-inline')` for sub-microsecond collection equality checks.
  - Verified in `test/nested_substate_mutation_test.dart`.
- **Streamlined Public API Surface**:
  - Removed redundant layout aliases (`graft.column` and `graft.row`).
  - Unified multi-child slot diffing exclusively under `graft.slots(layout: ..., children: ...)`, keeping layout concerns orthogonal to state management while preserving 100% of the underlying slot-diffing engine and philosophy.
- **Benchmark Performance Verification**:
  - Multi-child slot pipeline execution time improved by **16.3%** (75.88 ms → 63.47 ms) with 0 wasted builds in `test/benchmark/widget_rebuild_benchmark_test.dart`.
  - Average diff pass latency reduced to **1,227.6 ns** across 10,000 passes with 0 GC pauses.
  - All **185 test cases** passing with 100% green status.

---

## 0.1.2-alpha.3

### ⚡ Declarative Async Pattern-Matching & Structural Fingerprint Expansion
- **Declarative Async Pattern-Matching (`graft.async` & `GraftAsync.when`)**:
  - Added `.when<R>()` pattern-matching method to sealed `GraftAsync<T>` hierarchy for type-safe, exhaustive handling of `idle`, `loading`, `data`, and `error` states.
  - Introduced `graft.async<T>()` widget extension on `Graft<S>`, enabling fine-grained, isolated slot rendering bound to asynchronous state transitions with zero selector boilerplate.
  - Verified in `test/graft_async_widget_test.dart`.
- **Extended Layout Primitive Fingerprinting (`SlotMetadata.computeFingerprint`)**:
  - Expanded sub-nanosecond integer hashing in `SlotMetadata` to deeply fingerprint common layout primitives: `SizedBox`, `Padding`, `ColoredBox`, `Align`, and `Opacity`.
  - Enables instant 1-cycle bypass (< 5 ns) for structural layout containers during slot reconciliation passes.
- **Self-Healing Adaptive Bitmask Test Harness**:
  - Added comprehensive test suite `test/self_healing_bitmask_test.dart` covering multi-slot layouts, rapid single-field and multi-field mutation bursts, and verified zero-rebuild isolation for unmutated slots.
- **Architecture & Lifecycle Documentation**:
  - Updated runtime lifecycle flow and slot diffing diagrams in `README.md` to document the unified `runAsync` binding and self-healing bitmask reconciliation pipeline.

---

## 0.1.2-alpha.2

### ⚡ Core Engine Hardening & Context Decoupling
- **Recursive Snapshot Contract & Nested State Diffing**:
  - Upgraded `GraftState`'s snapshot engine to recursively clone nested `GraftState` sub-states via their `props`, alongside deep snapshots of `List`, `Set`, and `Map` collections.
  - Deep-equality diffing in `diffChanges` detects in-place cascade mutations on nested models (`state..address.city = 'Berlin'..update()`) with 100% snapshot integrity, eliminating the need for `copyWith` boilerplate.
  - Verified in `test/nested_inplace_mutation_test.dart`.
- **Safe AST Reconciliation with `NoSubscriptionContext`**:
  - Introduced `NoSubscriptionContext`, a specialized proxy `BuildContext` that safely resolves `InheritedWidget`s (such as `Theme.of(context)` or `MediaQuery.of(context)`) during fine-grained widget diffing without registering the underlying element in `InheritedElement._dependents`.
  - Guarantees zero context dependency leaks and prevents out-of-band rebuild cascades during background slot evaluation.
  - Verified in `test/context_isolation_leak_test.dart`.
- **Transient Route Lifecycle Protection (`PopupRoute`)**:
  - Enhanced `GraftRouteTracker` with `resolveOwnerRoute` to distinguish host screen routes (`PageRoute`) from transient overlay routes (`PopupRoute`, such as `showDialog` or `showModalBottomSheet`).
  - When dialogs or bottom sheets borrow or instantiate controllers via `context.use<T>()`, ownership is cleanly anchored to the hosting `PageRoute`. Dismissing the popup no longer triggers premature controller disposal.
  - Verified in `test/dialog_popup_lifecycle_test.dart`.
- **Deterministic Multi-Field Bitmask Union**:
  - Upgraded `GraftBoundary`'s backward adaptive dependency learning to accumulate observed field bitmasks via bitwise union (`_learnedDependencies[graft] |= fieldMask`) across all builder passes, preventing multi-field dependency dropping.
  - Verified in `test/deterministic_slot_bitmask_test.dart`.
- **Comprehensive Test Suite Expansion**:
  - Expanded test coverage from 116 to **164 test cases** (100% pass rate) with 0 static analysis warnings across unit, widget, and hardware benchmark suites.

---

## 0.1.2-alpha.1

### ⚡ Hardware-Aligned Engine & Self-Optimizing Architecture
- **Multi-Field Bitmask Tracking (`fieldDependenciesMask`)**: Upgraded `SlotMetadata` to accumulate multi-field dependencies into a cumulative 64-bit integer bitmask, completely resolving the single-bit locking bug and guaranteeing zero stale UI occurrences when slots depend on multiple domain fields.
- **Copy-on-Write State Transitions (`produce`)**: Added `produce((s) => s..field = x)` method to `Graft<S>`, combining zero-boilerplate cascade syntax with distinct immutable `currentState` and `nextState` snapshots for auditable logging and time-travel testing.
- **First-Class Async Engine (`GraftAsync<T>` & `runAsync`)**: Added sealed `GraftAsync<T>` hierarchy (`idle`, `loading`, `data`, `error`) and `runAsync()` automated task runner.
- **Subtree Scoping for Modern Routing (`GraftScope`)**: Added `GraftScope` widget to support `GoRouter`'s `StatefulShellRoute`, persistent bottom navigation tabs, and modal dialogs with automatic subtree lifecycle cleanup.
- **64-Bit Integer Dirty Bitmask**: Replaced synthetic context reflection hacks with hardware-level integer bitmasks evaluated in CPU registers.
- **Zero-Allocation In-Place Snapshots**: State diffing mutates baseline snapshots in-place with 0 GC heap allocations. Verified in `test/zero_allocation_benchmark_test.dart` (~750–1,300 ns per pass in debug VM, < 50 ns in AOT compiled mode).
- **Self-Optimizing Slot Table (`SlotMetadata`)**: Each slot retains lightweight metadata that adaptively correlates to domain field indices during mutation bursts, escalating from structural inspection to 1-cycle CPU bitwise checks: `(dirtyMask & fieldDependenciesMask) != 0`.
- **Depth-$N$ Rebuild Insulation (`graft((s) => ...)` & `graft.slot`)**: Unified single-slot leaf rendering with the ultra-clean callable syntax `graft((s) => ...)`, providing complete Element-level rebuild insulation for intermediate parent containers (`Card`, `Container`, `Padding`).
- **Synchronous & Coalesced Updates**: Direct cascade updates via `state..update()` notify synchronously for zero-latency UI updates; added `state..updateCoalesced()` for microtask debouncing in rapid loops.
- **Disordered Slot Resolution**: Full support for UI slot layouts that differ in order from state `tracked` definitions, verified in `test/disordering_test.dart` and `test/multi_field_slot_test.dart`.
- **Dynamic Branch Reconciliation**: Slot table dynamically expands and contracts on conditional branches (`if`, collection-`for`), properly disposing dropped slot notifiers to prevent memory leaks.
- **100% Verified Test Suite**: 116 test cases passing with zero warnings and zero analyzer issues across the entire workspace.

### 🔍 Tooling & Linter Updates (`graft_lint`)
- **New Rule (`prefer_tracked_in_graft_state`)**: Warns when a domain state class extending `GraftState` declares fields without overriding `tracked`, prompting developers to declare `List<Object?> get tracked => [...]` to unlock hardware-aligned 1-cycle bitmask execution.
- **Enhanced `avoid_nested_graft_slot`**: Flags illegal nesting of slots and layout scopes.

---

## 0.1.1-alpha.1

### 🔍 Tooling & Linter Updates (`graft_lint`)
- **Promoted `avoid_nested_graft_slot` to Error**: Redundant slot nesting is now flagged as a compile-time analyzer `Error` (`ErrorSeverity.ERROR`) by default to prevent anti-patterns early in IDEs and CI.
- **Fixed Ambiguous Import**: Resolved `LintCode` collision between `analyzer` and `custom_lint_builder`.
- **Published `graft_lint` on pub.dev**: Package is now publicly distributed via [pub.dev/packages/graft_lint](https://pub.dev/packages/graft_lint).
- **Documentation**: Expanded setup guides, added Bad vs. Good code examples, and documented `analysis_options.yaml` configuration patterns.

---

## 0.1.0-alpha.1

*First public alpha release of **Graft** — high-performance, fine-grained reactive state management for Flutter.*

> 🚀 **Alpha Release Notice — Let's Have a Ride!**
> Graft is in its initial alpha release and is **not yet declared production-ready**.
> We invite developers to take it for a spin, test its slot diffing and route-scoping capabilities across diverse architectures, and help us discover edge cases, ideas, and feedback on [GitHub Issues](https://github.com/kmmuzahid/graft/issues) as we march toward 1.0!

### ✨ Key Features

#### 1. Core State & Reactivity
- **Domain State Model (`Graft<S>`)**: Structured, cohesive state containers powered by `GraftState`.
- **Batched Cascade Updates**: Mutate state cleanly using Dart cascades (`state..name = 'Alice'..update()`) with automatic single-pass change emission.
- **Single-Value State (`ValueGraft<T>`)**: Zero-boilerplate reactive wrappers for primitives and enums without declaring a dedicated state class.
- **Disposal & Safety Guardrails**: Hardened lifecycle guards preventing memory leaks and state updates to disposed controllers.
- **Reentrancy Guard & Microtask Batching**: Multiple synchronous `notify()` calls during an active transition are batched into a single microtask emission.

#### 2. Fine-Grained Rebuild & Slot Diffing Engine
- **Slot Isolation (`graft.slot({required builder})`)**: Eliminates the "Pyramid of Selectors" by updating only specific subtrees on state changes.
- **Multi-Child Slot Diffing (`graft.slots({required layout, required children})`)**: Diff multi-child layouts (`Column`, `Row`, `Wrap`, `Stack`, `Flex`) without manual selector wrappers.
- **Collection Builder Support (`graft.builder<T>({required items, itemBuilder})`)**: Virtualized collection diffing with zero `itemCount` boilerplate; automatically defaults layout to `ListView.builder` with customizable layout overrides (`GridView.builder`, `SliverList`).
- **Pre-Flight Derivation (`graft.compute<R>({required compute, required builder})`)**: Pure functional computation cache that skips widget builds entirely when derived values remain unchanged.
- **100% Named Parameter Harmonization**: Consistent developer ergonomics across all widget slot methods (`slot`, `slots`, `compute`, `builder`, `item`, `valueGraft.slot`).
- **Deep Property Diffing**: Native deep comparison for 25+ Flutter widgets (`Text`, `RichText`, `Icon`, `SizedBox`, `Padding`, `ColoredBox`, `Align`, `DecoratedBox`, `Opacity`, `ClipRRect`, `Flex`, `Flexible`, `FittedBox`, `Stack`, `Positioned`, `Wrap`, `GestureDetector`, `InkWell`, `IconButton`, `Image`, `ProgressIndicator`, `Checkbox`, `Switch`, `Slider`, and more).
- **Transparent Wrapper Unwrapping**: Automatically unwraps single-child wrappers (`Padding`, `Container`, `Card`, `Scrollbar`, `RefreshIndicator`) in layout contracts.
- **Anti-Pattern Cycle Guard (`GraftScopeGuard`)**: Developer-friendly error diagnostics preventing accidental nested slot creations.

#### 3. Route-Stack Dependency Injection
- **Zero Provider Nesting**: Retrieve controllers via `context.use<T>()` without wrapping screens in `MultiProvider` or `BlocProvider`.
- **Stack-Aware Scope Sharing**: Sub-routes automatically borrow active controllers from predecessor routes in the navigation stack (`ModalRoute.of(this) ?? GraftRouteTracker.currentRoute`).
- **Automatic Lifecycle Disposal**: When a route pops, `GraftRouteTracker` automatically disposes any controller owned by that route.
- **Registry & Fallback Support (`GraftRegistry`)**: Global factory registration with eager or lazy instantiation, plus support for custom DI locators (e.g. `get_it`).

#### 4. Observability & Telemetry
- **Global Event Hooks (`GraftObserver`)**: Audit logging for controller creation, state changes, slot rebuilds (`onSlotRebuild`), errors, and disposal.
- **Developer Console Logger (`GraftDevObserver`)**: Colorized, structured console telemetry with optional slot-rebuild logging (`logRebuilds: true`).
- **Detailed State Diffs (`GraftChange<S>`)**: Full tracking of prior and subsequent states with transition metadata.

#### 5. Developer Ergonomics & Tooling
- **IDE Snippets Generator (`bin/snippets.dart`)**: Quick installer for VS Code / Cursor snippets (`.vscode/graft.code-snippets`) and Android Studio / IntelliJ live templates (`graft-controller`, `graft-slot`, `graft-slots`, `graft-builder`, `graft-compute`, `graft-test`).
- **Custom Linter Package (`packages/graft_lint`)**: Dedicated compile-time analyzer plugin providing rules:
  - `avoid_nested_graft_slot`: Warns against redundant nested slot invocations.
  - `require_graft_route_observer`: Suggests registering `GraftRouteTracker.observer` in `MaterialApp.navigatorObservers`.

#### 6. Benchmarking & Pure Dart Declarative Testing
- **Automated Rebuild Benchmark (`test/benchmark/column_rebuild_benchmark_test.dart`)**: Formally asserts 90.0% rebuild reduction in 10-slot layout (60 rebuilds vs 600 rebuilds).
- **Declarative Test Harness (`graftTest`)**: Sub-millisecond pure Dart unit testing with declarative `setUp`, `build`, `act`, `wait`, `expect`, `verify`, and `tearDown` stages.
- **100% Test Coverage**: Comprehensive test suite covering 100.0% of lines across all library source files.
