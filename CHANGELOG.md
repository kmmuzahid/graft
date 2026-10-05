# Changelog

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
