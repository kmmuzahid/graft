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
///   GraftProps get props => propsOf(name, email, isOnline);
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
  /// **Mandatory override**: Must return a [GraftProps] instance created via [propsOf] or [propsOfMany].
  /// Writing a `List` literal (e.g. `[a, b]`) is a compile-time error.
  GraftProps get props;

  /// Returns an unmodifiable snapshot of the baseline property values before the current mutation pass.
  @internal
  List<Object?> get baselineSnapshot =>
      _baseline != null ? List<Object?>.unmodifiable(_baseline!) : const [];

  /// Returns the current dirty bitmask from the last diff pass.
  @nonVirtual
  GraftMask get dirtyMask => _dirtyMask;

  static const Object _undefined = _Sentinel();

  List<Object?>? _propsBuffer;
  _GraftPropsBuffer? _propsView;

  /// High-performance zero-allocation register slot builder.
  ///
  /// Passes domain properties via CPU registers directly into a pre-allocated fixed buffer,
  /// completely eliminating heap List allocations during [update] and micro-mutations.
  ///
  /// ### Example:
  /// ```dart
  /// class UserState extends GraftState {
  ///   String name = 'Alice';
  ///   int count = 0;
  ///
  ///   @override
  ///   GraftProps get props => propsOf(name, count);
  /// }
  /// ```
  @protected
  @pragma('vm:prefer-inline')
  GraftProps propsOf([
    Object? p0 = _undefined,
    Object? p1 = _undefined,
    Object? p2 = _undefined,
    Object? p3 = _undefined,
    Object? p4 = _undefined,
    Object? p5 = _undefined,
    Object? p6 = _undefined,
    Object? p7 = _undefined,
    Object? p8 = _undefined,
    Object? p9 = _undefined,
    Object? p10 = _undefined,
    Object? p11 = _undefined,
    Object? p12 = _undefined,
    Object? p13 = _undefined,
    Object? p14 = _undefined,
    Object? p15 = _undefined,
  ]) {
    // ⚡ 1. 100% Dynamic Infinite Mode:
    // When passing a List or Iterable: propsOf([f1, f2, ... infinite fields])
    if (p0 is List<Object?>) {
      if (p0.isEmpty) return const _EmptyGraftProps();
      return _GraftPropsListView(p0);
    }
    if (p0 is Iterable && identical(p1, _undefined)) {
      if (p0.isEmpty) return const _EmptyGraftProps();
      return _GraftPropsListView(List<Object?>.of(p0, growable: false));
    }

    // ⚡ 2. Single Property Fast-Path (0 allocation):
    if (identical(p1, _undefined)) {
      if (identical(p0, _undefined)) return const _EmptyGraftProps();
      return _GraftPropsSingle(p0);
    }

    // ⚡ 3. Fast register-buffer path for comma-separated parameters:
    var view = _propsView;
    var buf = _propsBuffer;
    if (view == null || buf == null) {
      int count = 2;
      if (!identical(p15, _undefined)) {
        count = 16;
      } else if (!identical(p14, _undefined)) {
        count = 15;
      } else if (!identical(p13, _undefined)) {
        count = 14;
      } else if (!identical(p12, _undefined)) {
        count = 13;
      } else if (!identical(p11, _undefined)) {
        count = 12;
      } else if (!identical(p10, _undefined)) {
        count = 11;
      } else if (!identical(p9, _undefined)) {
        count = 10;
      } else if (!identical(p8, _undefined)) {
        count = 9;
      } else if (!identical(p7, _undefined)) {
        count = 8;
      } else if (!identical(p6, _undefined)) {
        count = 7;
      } else if (!identical(p5, _undefined)) {
        count = 6;
      } else if (!identical(p4, _undefined)) {
        count = 5;
      } else if (!identical(p3, _undefined)) {
        count = 4;
      } else if (!identical(p2, _undefined)) {
        count = 3;
      }
      buf = _propsBuffer = List<Object?>.filled(count, null);
      view = _propsView = _GraftPropsBuffer(buf, count);
    }

    final len = view._length;
    switch (len) {
      case 2:
        buf[0] = p0;
        buf[1] = p1;
        break;
      case 3:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        break;
      case 4:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        buf[3] = p3;
        break;
      case 5:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        buf[3] = p3;
        buf[4] = p4;
        break;
      case 6:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        buf[3] = p3;
        buf[4] = p4;
        buf[5] = p5;
        break;
      case 7:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        buf[3] = p3;
        buf[4] = p4;
        buf[5] = p5;
        buf[6] = p6;
        break;
      case 8:
        buf[0] = p0;
        buf[1] = p1;
        buf[2] = p2;
        buf[3] = p3;
        buf[4] = p4;
        buf[5] = p5;
        buf[6] = p6;
        buf[7] = p7;
        break;
      default:
        if (len > 0) buf[0] = p0;
        if (len > 1) buf[1] = p1;
        if (len > 2) buf[2] = p2;
        if (len > 3) buf[3] = p3;
        if (len > 4) buf[4] = p4;
        if (len > 5) buf[5] = p5;
        if (len > 6) buf[6] = p6;
        if (len > 7) buf[7] = p7;
        if (len > 8) buf[8] = p8;
        if (len > 9) buf[9] = p9;
        if (len > 10) buf[10] = p10;
        if (len > 11) buf[11] = p11;
        if (len > 12) buf[12] = p12;
        if (len > 13) buf[13] = p13;
        if (len > 14) buf[14] = p14;
        if (len > 15) buf[15] = p15;
    }
    return view;
  }

  /// Adapts an arbitrary [Iterable] or list of properties into [GraftProps].
  ///
  /// Useful for states with dynamic or large sets of properties.
  @protected
  @pragma('vm:prefer-inline')
  GraftProps propsOfMany(Iterable<Object?> items) {
    if (items.isEmpty) return const _EmptyGraftProps();
    if (items is List<Object?>) {
      return _GraftPropsListView(items);
    }
    return _GraftPropsListView(List<Object?>.of(items, growable: false));
  }

  @pragma('vm:prefer-inline')
  static Object? _snapshotValue(Object? value) {
    if (value == null ||
        value is num ||
        value is String ||
        value is bool ||
        value is Enum) {
      return value;
    }
    if (value is GraftState) {
      final subProps = value.props;
      return List<Object?>.generate(
        subProps.length,
        (i) => _snapshotValue(subProps[i]),
        growable: false,
      );
    }
    if (value is List) {
      return List<Object?>.of(value, growable: false);
    }
    if (value is Set) {
      return Set<Object?>.of(value);
    }
    if (value is Map) {
      return Map<Object?, Object?>.of(value);
    }
    return value;
  }

  @pragma('vm:prefer-inline')
  static bool _deepEquals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a is List && b is List) {
      final len = a.length;
      if (len != b.length) return false;
      for (int i = 0; i < len; i++) {
        if (!identical(a[i], b[i]) && a[i] != b[i]) return false;
      }
      return true;
    }
    if (a is Set && b is Set) {
      if (a.length != b.length) return false;
      for (final elem in b) {
        if (!a.contains(elem)) return false;
      }
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final entry in a.entries) {
        if (!b.containsKey(entry.key) ||
            !_deepEquals(entry.value, b[entry.key])) {
          return false;
        }
      }
      return true;
    }
    return a == b;
  }

  @pragma('vm:prefer-inline')
  static bool _isPropertyDirty(Object? p, Object? c) {
    if (identical(p, c)) {
      if (c is Iterable || c is Map) {
        return !_deepEquals(p, c);
      }
      return false;
    }
    if (c == null || p == null) return true;
    if (c is num || c is String || c is bool || c is Enum) {
      return p != c;
    }
    if (c is GraftState) {
      final subProps = c.props;
      if (p is List && p.length == subProps.length) {
        for (int j = 0; j < p.length; j++) {
          if (_isPropertyDirty(p[j], subProps[j])) {
            return true;
          }
        }
        return false;
      }
      return true;
    }
    if (p is List && c is List) {
      return p.length != c.length || !_deepEquals(p, c);
    }
    if (p is Set && c is Set) {
      return p.length != c.length || !_deepEquals(p, c);
    }
    if (p is Map && c is Map) {
      return p.length != c.length || !_deepEquals(p, c);
    }
    return p != c;
  }

  /// Compares current [props] against the in-place baseline snapshot.
  /// Returns [GraftMask.allDirty] on first evaluation, or a [GraftMask] of modified property indices.
  /// Handles in-place mutations on collections (List, Set, Map) and nested [GraftState] objects transparently.
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

    // ⚡ Hardware Fast-Path: Single-Property State (Counter, Toggle, Status)
    if (len == 1) {
      final p = prev[0];
      final c = current[0];
      if (_isPropertyDirty(p, c)) {
        prev[0] = _snapshotValue(c);
        final mask = GraftMask.fromIndex(0);
        _dirtyMask = mask;
        return mask;
      } else {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
    }

    // ⚡ Hardware Fast-Path: Dual-Property State
    if (len == 2) {
      final d0 = _isPropertyDirty(prev[0], current[0]);
      final d1 = _isPropertyDirty(prev[1], current[1]);

      if (!d0 && !d1) {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (d0 && !d1) {
        prev[0] = _snapshotValue(current[0]);
        final mask = GraftMask.fromIndex(0);
        _dirtyMask = mask;
        return mask;
      }
      if (!d0 && d1) {
        prev[1] = _snapshotValue(current[1]);
        final mask = GraftMask.fromIndex(1);
        _dirtyMask = mask;
        return mask;
      }
      prev[0] = _snapshotValue(current[0]);
      prev[1] = _snapshotValue(current[1]);
      final mask = GraftMask.fromWords(3, 0);
      _dirtyMask = mask;
      return mask;
    }

    int singleDirtyIndex = -1;
    int dirtyCount = 0;
    int w0 = 0;
    int w1 = 0;
    List<int>? extra;

    for (int i = 0; i < len; i++) {
      final p = prev[i];
      final c = current[i];

      if (!_isPropertyDirty(p, c)) {
        continue;
      }

      dirtyCount++;
      if (dirtyCount == 1) {
        singleDirtyIndex = i;
      }
      if (i < 32) {
        w0 |= (1 << i);
      } else if (i < 64) {
        w1 |= (1 << (i - 32));
      } else {
        final wordIdx = (i >> 5) - 2;
        extra ??= <int>[];
        while (extra.length <= wordIdx) {
          extra.add(0);
        }
        extra[wordIdx] |= (1 << (i & 31));
      }
      prev[i] = _snapshotValue(c);
    }

    if (dirtyCount == 0) {
      _dirtyMask = GraftMask.empty;
      return GraftMask.empty;
    }
    if (dirtyCount == 1 && singleDirtyIndex < 64) {
      final mask = GraftMask.fromIndex(singleDirtyIndex);
      _dirtyMask = mask;
      return mask;
    }
    final mask = GraftMask.fromWords(w0, w1, extra);
    _dirtyMask = mask;
    return mask;
  }

  /// Triggers fine-grained slot diffing and notifies all listeners synchronously.
  @nonVirtual
  @pragma('vm:prefer-inline')
  void update() {
    final hasObserver = Graft.observer != null;
    List<Object?>? prevSnapshot;
    if (hasObserver) {
      prevSnapshot = baselineSnapshot;
    }
    final mask = diffChanges();
    if (!mask.isEmpty) {
      if (hasObserver) {
        _graft?.notifyMask(
          mask,
          change: GraftChange<dynamic>(
            currentState: this,
            nextState: this,
            previousProps: prevSnapshot ?? const [],
            nextProps: List<Object?>.of(props, growable: false),
            dirtyMask: mask,
          ),
        );
      } else {
        _graft?.notifyMask(mask);
      }
    }
  }

  /// Resets this state by invoking [onReset] and triggering fine-grained diffing synchronously.
  @nonVirtual
  void reset() {
    onReset();
    update();
  }

  /// Optional lifecycle hook called during [reset] to restore domain field values.
  void onReset() {}
}

class _Sentinel {
  const _Sentinel();
}

/// Represents the hardware-aligned domain property container for [GraftState].
///
/// Guaranteed zero heap allocations when constructed via [propsOf].
/// Returning a `List` literal (e.g. `[a, b]`) is a compile-time error.
abstract final class GraftProps extends Iterable<Object?> {
  const GraftProps();

  /// Gets the property value at [index].
  Object? operator [](int index);

  @override
  int get length;

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length > 0;
}

final class _EmptyGraftProps extends GraftProps {
  const _EmptyGraftProps();

  @override
  Object? operator [](int index) => throw RangeError.index(index, this);

  @override
  int get length => 0;

  @override
  Iterator<Object?> get iterator => const <Object?>[].iterator;
}

final class _GraftPropsBuffer extends GraftProps {
  final List<Object?> _buffer;
  final int _length;

  const _GraftPropsBuffer(this._buffer, this._length);

  @override
  Object? operator [](int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this);
    }
    return _buffer[index];
  }

  @override
  int get length => _length;

  @override
  Iterator<Object?> get iterator => _GraftPropsIterator(_buffer, _length);
}

final class _GraftPropsIterator implements Iterator<Object?> {
  final List<Object?> _buffer;
  final int _length;
  int _index = -1;

  _GraftPropsIterator(this._buffer, this._length);

  @override
  Object? get current =>
      _index >= 0 && _index < _length ? _buffer[_index] : null;

  @override
  bool moveNext() {
    if (_index + 1 < _length) {
      _index++;
      return true;
    }
    return false;
  }
}

final class _GraftPropsListView extends GraftProps {
  final List<Object?> _list;

  const _GraftPropsListView(this._list);

  @override
  Object? operator [](int index) => _list[index];

  @override
  int get length => _list.length;

  @override
  Iterator<Object?> get iterator => _list.iterator;
}

