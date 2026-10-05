import 'package:flutter/foundation.dart';
import 'graft.dart';
import 'graft_change.dart';
import 'graft_mask.dart';

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
///     ..update(); // Diffing + surgical leaf rebuild in 1 synchronous pass!
///   ```
/// - **Mandatory `props`:** Override [props] to declare domain properties. Calling [update]
///   computes an unbounded [GraftMask] bitset and triggers surgical leaf-rebuilds.
/// - **In-Place Reset:** Call [reset] to restore initial domain values via [onReset].
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = 'Alice';
///   String email = 'alice@example.com';
///   bool isOnline = false;
///
///   @override
///   List<Object?> get props => [name, email, isOnline];
/// }
/// ```
abstract class GraftState {
  Graft? _graft;
  List<Object?>? _baseline;
  GraftMask _dirtyMask = GraftMask.allDirty;

  /// Binds this state instance to its owning [Graft] controller.
  ///
  /// This method is called automatically by the [Graft] constructor.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void bindGraft(Graft graft) {
    _graft = graft;
    initBaseline();
  }

  /// Initializes the baseline snapshot of tracked properties with zero-copy primitives
  /// and shallow-cloned snapshots for collection types.
  ///
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void initBaseline() {
    final current = props;
    if (current.isNotEmpty) {
      _baseline = List<Object?>.generate(
        current.length,
        (i) => _snapshotValue(current[i]),
        growable: false,
      );
    }
  }

  /// Declares domain properties for fine-grained slot diffing and automated snapshots.
  ///
  /// **Mandatory override**: The Dart compiler enforces declaring properties here.
  List<Object?> get props;

  /// Backward-compatible alias for [props].
  @Deprecated('Use props instead.')
  List<Object?> get tracked => props;

  /// Returns an unmodifiable snapshot of the baseline property values before the current mutation pass.
  @internal
  List<Object?> get baselineSnapshot =>
      _baseline != null ? List<Object?>.unmodifiable(_baseline!) : const [];

  /// Returns the current dirty bitmask from the last diff pass.
  @nonVirtual
  GraftMask get dirtyMask => _dirtyMask;

  @pragma('vm:prefer-inline')
  static Object? _snapshotValue(Object? value) {
    if (value is List) return List<Object?>.of(value, growable: false);
    if (value is Set) return Set<Object?>.of(value);
    if (value is Map) return Map<Object?, Object?>.of(value);
    return value;
  }

  static bool _fastListEquals(List a, List b) {
    final len = a.length;
    for (int j = 0; j < len; j++) {
      final ejA = a[j];
      final ejB = b[j];
      if (!identical(ejA, ejB) && ejA != ejB) return false;
    }
    return true;
  }

  static bool _fastSetEquals(Set a, Set b) {
    for (final elem in b) {
      if (!a.contains(elem)) return false;
    }
    return true;
  }

  static bool _fastMapEquals(Map a, Map b) {
    for (final entry in b.entries) {
      final key = entry.key;
      if (!a.containsKey(key) || a[key] != entry.value) return false;
    }
    return true;
  }

  /// Compares current [props] against the in-place baseline snapshot.
  /// Returns [GraftMask.allDirty] on first evaluation, or a [GraftMask] of modified property indices.
  /// Handles in-place mutations on collections (List, Set, Map) transparently.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  GraftMask diffChanges() {
    final current = props;
    final len = current.length;
    if (len == 0) {
      _dirtyMask = GraftMask.allDirty;
      return GraftMask.allDirty;
    }

    final prev = _baseline;
    if (prev == null || prev.length != len) {
      _baseline = List<Object?>.generate(
        len,
        (i) => _snapshotValue(current[i]),
        growable: false,
      );
      _dirtyMask = GraftMask.allDirty;
      return GraftMask.allDirty;
    }

    var mask = GraftMask.empty;
    for (int i = 0; i < len; i++) {
      final p = prev[i];
      final c = current[i];

      bool isDirty = false;

      // Fast pointer identity first (1 CPU cycle for primitives and unmutated references)
      if (!identical(p, c)) {
        if (p is List && c is List) {
          isDirty = p.length != c.length || !_fastListEquals(p, c);
        } else if (p is Set && c is Set) {
          isDirty = p.length != c.length || !_fastSetEquals(p, c);
        } else if (p is Map && c is Map) {
          isDirty = p.length != c.length || !_fastMapEquals(p, c);
        } else {
          isDirty = (p != c);
        }
      } else if (c is Iterable) {
        // Fallback for mutable collection reference without prior snapshot
        isDirty = true;
      } else if (c is Map) {
        isDirty = true;
      }

      if (isDirty) {
        mask = mask.withBit(i);
        prev[i] = _snapshotValue(c);
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

  /// Resets this state by invoking [onReset] and triggering fine-grained diffing synchronously.
  @nonVirtual
  void reset() {
    onReset();
    update();
  }

  /// Optional lifecycle hook called during [reset] to restore domain field values.
  void onReset() {}

  void _flush() {
    final previousProps = _baseline != null
        ? List<Object?>.generate(
            _baseline!.length,
            (i) => _snapshotValue(_baseline![i]),
            growable: false,
          )
        : const <Object?>[];
    final mask = diffChanges();
    if (!mask.isEmpty) {
      final change = GraftChange<dynamic>(
        currentState: this,
        nextState: this,
        previousProps: previousProps,
        nextProps: List<Object?>.generate(
          props.length,
          (i) => _snapshotValue(props[i]),
          growable: false,
        ),
        dirtyMask: mask,
      );
      _graft?.notifyMask(mask, change: change);
    }
  }
}
