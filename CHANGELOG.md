# Changelog

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
