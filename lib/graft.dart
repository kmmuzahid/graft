/// # Graft
///
/// **High-performance, fine-grained reactive state management for Flutter with zero boilerplate.**
///
/// ---
///
/// ### Core Architectural Concepts:
///
/// 1. **Domain State ([GraftState]):**
///    Extend [GraftState] to hold state variables. Mutate cleanly with Dart cascades:
///    ```dart
///    state
///      ..name = 'Alice'
///      ..email = 'alice@example.com'
///      ..update(); // Batched diffing: notifies listeners once!
///    ```
///
/// 2. **Single Value State ([ValueGraft]):**
///    For primitive types (`int`, `bool`, `String`) and enums, use [ValueGraft<T>] with zero state class:
///    ```dart
///    class CounterGraft extends ValueGraft<int> {
///      CounterGraft() : super(0);
///      void increment() => value++;
///    }
///    ```
///
/// 3. **Fine-Grained Slot Isolation ([GraftWidgetsX]):**
///    Instead of rebuilding the whole screen on every emission, isolate slots:
///    - `graft.slot(...)`: Isolated single-child slot for any Flutter widget.
///    - `graft.slots(...)`: Multi-child slot diffing with explicit layout (e.g. `(children) => Column(children: children)`).
///    - `graft.compute(...)`: Pre-flight data computation; skips building if the derived value is unchanged.

///
/// 4. **Route-Stack Dependency Injection ([GraftContextX]):**
///    Zero `MultiProvider` widget nesting. Declare factories once in [GraftRegistry]:
///    - `context.use<T>()`: Borrows an active instance from ancestor routes or instantiates a route-scoped owner.
///    - `context.create<T>()`: Force-creates an isolated, route-scoped instance.
///    - Grafts are automatically disposed when their owner route pops!
///
/// 5. **Observability & Telemetry ([GraftObserver]):**
///    Attach [GraftDevObserver] or custom observers in `main()` for full audit logging of creations,
///    transitions, errors, and disposals.
///
/// 6. **Declarative Testing ([graftTest]):**
///    Sub-millisecond pure Dart unit tests with declarative lifecycle phases.
library;

export 'src/context/graft_context.dart';
export 'src/core/graft.dart';
export 'src/core/graft_change.dart';
export 'src/core/graft_observer.dart';
export 'src/core/graft_state.dart';
export 'src/core/value_graft.dart';
export 'src/di/graft_registry.dart';
export 'src/route/graft_route_tracker.dart';
export 'src/widgets/child_slot_engine.dart';
export 'src/widgets/graft_boundary.dart';
export 'src/widgets/graft_widgets.dart';

