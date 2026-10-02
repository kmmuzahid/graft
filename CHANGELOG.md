# Changelog

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

---

## 0.1.0-alpha.1

*First public alpha release of **Graft** — high-performance, fine-grained reactive state management for Flutter.*

### ✨ Key Features

#### 1. Core State & Reactivity
- **Domain State Model (`Graft<S>`)**: Structured, immutable state containers powered by `GraftState`.
- **Batched Cascade Updates**: Mutate state cleanly using Dart cascades (`state..name = 'Alice'..update()`) with automatic single-pass change emission.
- **Single-Value State (`ValueGraft<T>`)**: Zero-boilerplate reactive wrappers for primitives and enums without declaring a dedicated state class.
- **Disposal & Safety Guardrails**: Hardened lifecycle guards preventing memory leaks and state updates to disposed controllers.

#### 2. Fine-Grained Rebuild & Slot Diffing Engine
- **Slot Isolation (`graft.slot`)**: Eliminates the "Pyramid of Selectors" by updating only specific subtrees on state changes.
- **Multi-Child Slot Diffing (`graft.slots`)**: Diff multi-child layouts (`Column`, `Row`, `Wrap`, `Stack`, `Flex`) without manual selector wrappers.
- **Collection Builder Support (`graft.builder` & `graft.item`)**: Micro-rebuild performance for `ListView.builder`, `GridView.builder`, `PageView.builder`, and `CustomScrollView` / `SliverList`.
- **Pre-Flight Derivation (`graft.compute`)**: Pure functional computation cache that skips widget builds when derived values remain unchanged.
- **Deep Property Diffing**: Native deep comparison for 25+ Flutter widgets (`Text`, `RichText`, `Icon`, `SizedBox`, `Padding`, `ColoredBox`, `Align`, `DecoratedBox`, `Opacity`, `ClipRRect`, `Flex`, `Flexible`, `FittedBox`, `Stack`, `Positioned`, `Wrap`, `GestureDetector`, `InkWell`, `IconButton`, `Image`, `ProgressIndicator`, `Checkbox`, `Switch`, `Slider`, and more).
- **Transparent Wrapper Unwrapping**: Automatically unwraps single-child wrappers (`Padding`, `Container`, `Card`, `Scrollbar`, `RefreshIndicator`) in layout contracts.
- **Anti-Pattern Guard (`GraftScopeGuard`)**: Developer-friendly error diagnostics preventing accidental nested slot creations.

#### 3. Fully UI-Agnostic & Flutter 3.47+ Ready
- Built directly on Flutter's core `package:flutter/widgets.dart` layer.
- Completely decoupled from `material.dart` — seamlessly integrates with:
  - Standard Material 2 and Material 3
  - Flutter 3.47+ decoupled `package:material_ui`
  - Cupertino (iOS / macOS)
  - Custom brand design systems

#### 4. Route-Stack Dependency Injection
- **Zero Provider Nesting**: Retrieve controllers via `context.use<T>()` without wrapping screens in `MultiProvider` or `BlocProvider`.
- **Stack-Aware Scope Sharing**: Sub-routes automatically borrow active controllers from predecessor routes in the navigation stack.
- **Automatic Lifecycle Disposal**: When a route pops, `GraftRouteTracker` automatically disposes any controller owned by that route.
- **Registry & Fallback Support (`GraftRegistry`)**: Global factory registration with eager or lazy instantiation, plus support for custom DI locators (e.g. `get_it`).

#### 5. Telemetry & Observability
- **Global Event Hooks (`GraftObserver`)**: Audit logging for controller creation, state changes, errors, and disposal.
- **Developer Console Logger (`GraftDevObserver`)**: Colorized, structured console telemetry.
- **Detailed State Diffs (`GraftChange<S>`)**: Full tracking of prior and subsequent states with transition metadata.

#### 6. Pure Dart Declarative Testing
- **Declarative Test Harness (`graftTest`)**: Sub-millisecond pure Dart unit testing with declarative `setUp`, `build`, `act`, `wait`, `expect`, `verify`, and `tearDown` stages.
- **100% Test Coverage**: Comprehensive test suite covering 100.0% of lines across all 11 library source files.
