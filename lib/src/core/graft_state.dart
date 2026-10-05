import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft.dart';

/// Base class for domain states that enables direct cascade mutation with zero boilerplate.
///
/// ### Why extend GraftState?
/// - **Zero Boilerplate:** No immutable `copyWith` methods, no `Equatable` boilerplate, and
///   no code generation (`build_runner` is never required).
/// - **Fluent Cascade Updates:** Modify multiple fields cleanly using Dart's native cascade operator:
///   ```dart
///   state
///     ..name = 'Alice'
///     ..avatarUrl = 'https://...'
///     ..isLoading = false
///     ..update(); // Batched diffing: notifies listeners once!
///   ```
/// - **Fine-Grained Slot Diffing:** Override [tracked] to declare domain fields. Calling [update]
///   computes a 64-bit integer dirty bitmask in CPU registers and triggers surgical leaf-rebuilds.
/// - **Internal Binding:** Automatically linked to its owning [Graft] controller upon construction.
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = '';
///   String email = '';
///   bool isOnline = false;
///
///   @override
///   List<Object?> get tracked => [name, email, isOnline];
/// }
/// ```
abstract class GraftState {
  Graft? _graft;
  List<Object?>? _baseline;
  int _dirtyMask = -1;
  bool _microtaskScheduled = false;

  /// Binds this state instance to its owning [Graft] controller.
  ///
  /// This method is called automatically by the [Graft] constructor and [Graft.emit].
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void bindGraft(Graft graft) {
    _graft = graft;
    initBaseline();
  }

  /// Initializes the baseline snapshot of tracked fields.
  ///
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void initBaseline() {
    final current = _effectiveFields;
    if (current.isNotEmpty) {
      _baseline = List<Object?>.of(current, growable: false);
    }
  }

  /// Override this getter to declare tracked fields for fine-grained slot diffing.
  /// Example:
  /// ```dart
  /// @override
  /// List<Object?> get tracked => props;
  /// ```
  List<Object?> get tracked => props;

  /// Backward-compatible alias for [tracked].
  List<Object?> get props => const [];

  List<Object?> get _effectiveFields {
    final t = tracked;
    if (t.isNotEmpty) return t;
    return props;
  }

  /// Returns an unmodifiable snapshot of the baseline tracked values before the current mutation pass.
  @internal
  List<Object?> get baselineSnapshot =>
      _baseline != null ? List<Object?>.unmodifiable(_baseline!) : const [];

  /// Optional hook to create a cloned snapshot of this state.
  ///
  /// By default, Graft automatically snapshots [tracked] fields before mutation so
  /// overriding this method is **completely optional** and never required.
  GraftState copy() => this;

  /// Returns the current dirty bitmask from the last diff pass.
  @nonVirtual
  int get dirtyMask => _dirtyMask;

  /// Compares current [tracked] fields against the in-place baseline snapshot.
  /// Returns -1 on first evaluation (all dirty), or a 64-bit bitmask of modified field indices.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  int diffChanges() {
    final current = _effectiveFields;
    final len = current.length;
    if (len == 0) {
      _dirtyMask = -1;
      return -1;
    }

    final prev = _baseline;
    if (prev == null || prev.length != len) {
      _baseline = List<Object?>.of(current, growable: false);
      _dirtyMask = -1;
      return -1;
    }

    int mask = 0;
    for (int i = 0; i < len; i++) {
      final p = prev[i];
      final c = current[i];

      // Fast pointer identity first (1 CPU cycle), then value equality
      if (!identical(p, c) && p != c) {
        mask |= (1 << i);
        prev[i] = c; // In-place update to baseline: 0 GC heap allocations
      }
    }
    _dirtyMask = mask;
    return mask;
  }

  /// Triggers fine-grained slot diffing and notifies all listeners synchronously.
  @nonVirtual
  void update() {
    _flush();
  }

  /// Triggers fine-grained slot diffing coalesced in the microtask queue.
  /// Useful when performing bulk asynchronous or rapid iterative updates.
  @nonVirtual
  void updateCoalesced() {
    if (_microtaskScheduled) return;
    _microtaskScheduled = true;
    scheduleMicrotask(_flush);
  }

  /// Flushes state updates immediately and synchronously. Useful in unit tests.
  @nonVirtual
  void updateImmediate() {
    _flush();
  }

  void _flush() {
    _microtaskScheduled = false;
    final mask = diffChanges();
    if (mask != 0) {
      _graft?.notifyMask(mask);
    }
  }
}
