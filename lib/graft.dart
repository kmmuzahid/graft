/// # Graft
///
/// **Self-optimizing, fine-grained reactive state management for Flutter with zero boilerplate.**
///
/// ---
///
/// ### Just 3 Core Concepts:
///
/// 1. **Atomic Mutation ([mutate]):**
///    Mutate domain state cleanly using native Dart cascades with automatic snapshotting:
///    ```dart
///    mutate((s) => s
///      ..name = 'Alice'
///      ..email = 'alice@example.com'
///    ); // Batched 64-bit bitmask diffing: notifies listeners once!
///    ```
///
/// 2. **Zero-Setup Dependency Injection ([BuildContext.use]):**
///    Instantiate and borrow controllers on-demand with zero configuration in `main.dart`:
///    ```dart
///    final graft = context.use(UserGraft.new);
///    ```
///    Automatically inherits along the route stack and self-disposes when the owning screen unmounts!
///
/// 3. **Surgical Slot Isolation ([GraftWidgetsX]):**
///    Isolate reactive subtrees down to the leaf Element without selector boilerplate:
///    - `graft((s) => Text(s.name))`: Callable syntax shortcut for single-child slots.
///    - `graft.slot(...)`: Isolated slot for any widget with automatic content equivalence.
///    - `graft.column(...)` & `graft.row(...)`: Multi-child layouts with 0-rebuild slot diffing.
///    - `GraftAsync<T>`: First-class pattern-matching for asynchronous operations.
library;

export 'src/context/graft_context.dart';
export 'src/core/graft.dart';
export 'src/core/graft_async.dart';
export 'src/core/graft_change.dart';
export 'src/core/graft_mask.dart';
export 'src/core/graft_observer.dart';
export 'src/core/graft_scope_tracker.dart';
export 'src/core/graft_state.dart';
export 'src/core/value_graft.dart';
export 'src/di/graft_registry.dart';
export 'src/route/graft_route_tracker.dart';
export 'src/widgets/child_slot_engine.dart'
    show GraftEquivalent, GraftMultiChildDiffEngine, GraftScopeGuard;
export 'src/widgets/graft_boundary.dart';
export 'src/widgets/graft_scope.dart' show GraftScope;
export 'src/widgets/graft_widgets.dart';

