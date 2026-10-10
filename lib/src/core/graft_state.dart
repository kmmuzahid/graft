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

  /// Monotonically increasing version counter incremented on every [update] call.
  int _version = 0;

  /// Returns the current version counter of this state instance.
  int get version => _version;

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
    final len = current.length;
    _baselineNeedsSync = false;
    if (len == 1) {
      final c = current is _GraftPropsSingle ? current.value : current[0];
      _singleBaseline = _snapshotValue(c);
      _prevListLength = c is List ? c.length : -1;
      return;
    }
    if (len > 1) {
      if (current is _GraftPropsListView) {
        final list = current._list;
        if (list.isNotEmpty && list[0] is GraftState) {
          _baseline = List<Object?>.generate(
            len,
            (i) => _snapshotValue(current[i]),
            growable: false,
          );
        } else {
          _baseline = List<Object?>.of(list, growable: false);
        }
      } else {
        _baseline = List<Object?>.generate(
          len,
          (i) => _snapshotValue(current[i]),
          growable: false,
        );
      }
    }
  }

  /// Declares domain properties for fine-grained slot diffing and automated snapshots.
  ///
  /// **Mandatory override**: Must return a [GraftProps] instance created via [propsOf] or [propsOfMany].
  /// Writing a `List` literal (e.g. `[a, b]`) is a compile-time error.
  GraftProps get props;

  /// Returns an unmodifiable snapshot of the baseline property values before the current mutation pass.
  @internal
  List<Object?> get baselineSnapshot {
    if (!identical(_singleBaseline, _undefined)) {
      return [_singleBaseline];
    }
    return _baseline != null ? List<Object?>.unmodifiable(_baseline!) : const [];
  }

  /// Returns the current dirty bitmask from the last diff pass.
  @nonVirtual
  GraftMask get dirtyMask => _dirtyMask;

  static const Object _undefined = _Sentinel();

  List<Object?>? _propsBuffer;
  _GraftPropsBuffer? _propsView;
  _GraftPropsSingle? _singleView;
  Object? _singleBaseline = _undefined;
  Object? _pendingSingle = _undefined;
  int _prevListLength = -1;
  bool _baselineNeedsSync = false;

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
    // ⚡ 1. Single Property Fast-Path:
    if (identical(p1, _undefined)) {
      if (p0 is num || p0 is String || p0 is bool || p0 is Enum) {
        _pendingSingle = p0;
        final view = _singleView;
        if (view != null) {
          view.value = p0;
          return view;
        }
        return _singleView = _GraftPropsSingle(p0);
      }
      if (p0 is List) {
        if (p0.isEmpty) return const _EmptyGraftProps();
        return _GraftPropsListView(p0);
      }
      if (p0 is Iterable) {
        if (p0.isEmpty) return const _EmptyGraftProps();
        return _GraftPropsListView(List<Object?>.of(p0, growable: false));
      }
      _pendingSingle = p0;
      if (identical(p0, _undefined)) return const _EmptyGraftProps();
      final view = _singleView;
      if (view != null) {
        view.value = p0;
        return view;
      }
      return _singleView = _GraftPropsSingle(p0);
    }

    // ⚡ 2. Fast register-buffer path for comma-separated parameters:
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
      if (len == 0) return true;
      if (!identical(a[0], b[0]) && a[0] != b[0]) return false;
      final last = len - 1;
      if (!identical(a[last], b[last]) && a[last] != b[last]) return false;
      for (int i = 1; i < last; i++) {
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
      if (p.length != c.length) return true;
      for (int j = 0; j < p.length; j++) {
        if (!identical(p[j], c[j]) && p[j] != c[j]) return true;
      }
      return false;
    }
    if (p is Set && c is Set) {
      return p.length != c.length || !_deepEquals(p, c);
    }
    if (p is Map && c is Map) {
      return p.length != c.length || !_deepEquals(p, c);
    }
    return p != c;
  }

  @pragma('vm:prefer-inline')
  static bool _diffListAndUpdate(List p, List c) {
    final len = p.length;
    for (int i = 0; i < len; i++) {
      final pi = p[i];
      final ci = c[i];
      if (!identical(pi, ci)) {
        if (pi != ci) {
          p[i] = ci;
          final next = i + 1;
          if (next >= len) return true;
          if (identical(p[len - 1], c[len - 1])) {
            bool multiple = false;
            for (int j = next; j < len - 1; j++) {
              final pj = p[j];
              final cj = c[j];
              if (!identical(pj, cj)) {
                if (pj != cj) {
                  p[j] = cj;
                  multiple = true;
                }
              }
            }
            if (!multiple) return true;
          }
          for (int j = next; j < len; j++) {
            final pj = p[j];
            final cj = c[j];
            if (!identical(pj, cj) && pj != cj) {
              p[j] = cj;
            }
          }
          return true;
        }
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  static bool _diffMapAndUpdate(Map p, Map c) {
    if (p.length != c.length) {
      p.clear();
      p.addAll(c);
      return true;
    }
    bool dirty = false;
    for (final k in c.keys) {
      final cv = c[k];
      if (!p.containsKey(k)) {
        p[k] = cv;
        dirty = true;
      } else {
        final pv = p[k];
        if (!identical(pv, cv) && pv != cv) {
          p[k] = cv;
          dirty = true;
        }
      }
    }
    return dirty;
  }

  @pragma('vm:prefer-inline')
  static bool _diffAndUpdateGraftState(List p, GraftState c) {
    final subProps = c.props;
    final len = subProps.length;
    if (p.length != len) return true;
    if (len == 1) {
      final c0 = subProps is _GraftPropsSingle ? subProps.value : subProps[0];
      final p0 = p[0];
      if (identical(p0, c0)) {
        if (c0 is Iterable || c0 is Map) {
          if (!_deepEquals(p0, c0)) {
            p[0] = _snapshotValue(c0);
            return true;
          }
        }
        return false;
      }
      if (p0 is List) {
        if (c0 is GraftState) {
          return _diffAndUpdateGraftState(p0, c0);
        }
        if (c0 is List) {
          if (p0.length != c0.length) {
            p[0] = List<Object?>.of(c0, growable: false);
            return true;
          }
          return _diffListAndUpdate(p0, c0);
        }
      }
      if (c0 is num || c0 is String || c0 is bool || c0 is Enum) {
        if (p0 != c0) {
          p[0] = c0;
          return true;
        }
        return false;
      }
      if (_isPropertyDirty(p0, c0)) {
        p[0] = _updateSnapshot(p0, c0);
        return true;
      }
      return false;
    }
    bool dirty = false;
    for (int j = 0; j < len; j++) {
      final pj = p[j];
      final cj = subProps[j];
      if (identical(pj, cj)) continue;
      if (cj is num || cj is String || cj is bool || cj is Enum) {
        if (pj != cj) {
          p[j] = cj;
          dirty = true;
        }
      } else if (cj is GraftState) {
        if (pj is List && _diffAndUpdateGraftState(pj, cj)) {
          dirty = true;
        }
      } else if (pj is List && cj is List) {
        if (pj.length != cj.length) {
          p[j] = List<Object?>.of(cj, growable: false);
          dirty = true;
        } else if (_diffListAndUpdate(pj, cj)) {
          dirty = true;
        }
      } else if (pj is Map && cj is Map) {
        if (_diffMapAndUpdate(pj, cj)) {
          dirty = true;
        }
      } else if (_isPropertyDirty(pj, cj)) {
        p[j] = _updateSnapshot(pj, cj);
        dirty = true;
      }
    }
    return dirty;
  }

  @pragma('vm:prefer-inline')
  static Object? _updateSnapshot(Object? p, Object? c) {
    if (c is List) {
      if (p is List && p.length == c.length) {
        for (int j = 0; j < c.length; j++) {
          p[j] = c[j];
        }
        return p;
      }
      return List<Object?>.of(c, growable: false);
    }
    if (c is GraftState) {
      final subProps = c.props;
      final subLen = subProps.length;
      if (p is List && p.length == subLen) {
        for (int j = 0; j < subLen; j++) {
          p[j] = _updateSnapshot(p[j], subProps[j]);
        }
        return p;
      }
      return _snapshotValue(c);
    }
    if (c is Set || c is Map) {
      return _snapshotValue(c);
    }
    return c;
  }

  /// Compares current [props] against the in-place baseline snapshot.
  /// Returns [GraftMask.allDirty] on first evaluation, or a [GraftMask] of modified property indices.
  /// Handles in-place mutations on collections (List, Set, Map) and nested [GraftState] objects transparently.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  @pragma('vm:prefer-inline')
  GraftMask diffChanges() {
    final p = _singleBaseline;
    if (_baseline == null && !identical(p, _undefined)) {
      props;
      final c = _pendingSingle;
      if (c is num || c is String || c is bool || c is Enum) {
        if (p == c) {
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        _singleBaseline = c;
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
      if (c is GraftState && p is List) {
        if (_diffAndUpdateGraftState(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (identical(p, c)) {
        if (c is List) {
          if (_prevListLength != c.length) {
            _prevListLength = c.length;
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
        } else if (c is Iterable || c is Map) {
          if (!_deepEquals(p, c)) {
            _singleBaseline = _snapshotValue(c);
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (p is List && c is List) {
        final clen = c.length;
        if (_prevListLength != clen) {
          _prevListLength = clen;
          _baselineNeedsSync = true;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        if (_baselineNeedsSync) {
          _singleBaseline = List<Object?>.of(c, growable: false);
          _baselineNeedsSync = false;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        if (_diffListAndUpdate(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (p is Map && c is Map) {
        if (_diffMapAndUpdate(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (_isPropertyDirty(p, c)) {
        _singleBaseline = _updateSnapshot(p, c);
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      } else {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
    }

    final current = props;
    final len = current.length;
    if (len == 0) {
      _dirtyMask = GraftMask.allDirty;
      return GraftMask.allDirty;
    }

    // ⚡ Hardware Fast-Path: Single-Property State (Counter, Toggle, Status)
    if (len == 1) {
      final c = current is _GraftPropsSingle ? current.value : current[0];
      final p = _singleBaseline;
      if (identical(p, _undefined)) {
        _singleBaseline = _snapshotValue(c);
        _prevListLength = c is List ? c.length : -1;
        _dirtyMask = GraftMask.allDirty;
        return GraftMask.allDirty;
      }
      if (c is num || c is String || c is bool || c is Enum) {
        if (p == c) {
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        _singleBaseline = c;
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
      if (c is GraftState && p is List) {
        if (_diffAndUpdateGraftState(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (identical(p, c)) {
        if (c is List) {
          if (_prevListLength != c.length) {
            _prevListLength = c.length;
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
        } else if (c is Iterable || c is Map) {
          if (!_deepEquals(p, c)) {
            _singleBaseline = _snapshotValue(c);
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (p is List && c is List) {
        final clen = c.length;
        if (_prevListLength != clen) {
          _prevListLength = clen;
          _baselineNeedsSync = true;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        if (_baselineNeedsSync) {
          _singleBaseline = List<Object?>.of(c, growable: false);
          _baselineNeedsSync = false;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        if (_diffListAndUpdate(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (p is Map && c is Map) {
        if (_diffMapAndUpdate(p, c)) {
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (_isPropertyDirty(p, c)) {
        _singleBaseline = _updateSnapshot(p, c);
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      } else {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
    }

    final prev = _baseline;
    if (prev == null || prev.length != len) {
      if (current is _GraftPropsListView) {
        final list = current._list;
        if (list.isNotEmpty && list[0] is GraftState) {
          _baseline = List<Object?>.generate(
            len,
            (i) => _snapshotValue(current[i]),
            growable: false,
          );
        } else {
          _baseline = List<Object?>.of(list, growable: false);
        }
      } else {
        _baseline = List<Object?>.generate(
          len,
          (i) => _snapshotValue(current[i]),
          growable: false,
        );
      }
      _dirtyMask = GraftMask.allDirty;
      return GraftMask.allDirty;
    }

    final buf = _propsBuffer;

    // ⚡ Hardware Fast-Path: Dual-Property State
    if (len == 2) {
      final c0 = buf != null ? buf[0] : current[0];
      final c1 = buf != null ? buf[1] : current[1];
      final p0 = prev[0];
      final p1 = prev[1];

      bool d0 = false;
      if (!identical(p0, c0)) {
        if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
          if (p0 != c0) {
            prev[0] = c0;
            d0 = true;
          }
        } else if (p0 is List && c0 is List) {
          if (p0.length != c0.length) {
            prev[0] = List<Object?>.of(c0, growable: false);
            d0 = true;
          } else {
            d0 = _diffListAndUpdate(p0, c0);
          }
        } else if (p0 is Map && c0 is Map) {
          d0 = _diffMapAndUpdate(p0, c0);
        } else if (_isPropertyDirty(p0, c0)) {
          prev[0] = _updateSnapshot(p0, c0);
          d0 = true;
        }
      } else if (c0 is Iterable || c0 is Map) {
        if (!_deepEquals(p0, c0)) {
          prev[0] = _snapshotValue(c0);
          d0 = true;
        }
      }

      bool d1 = false;
      if (!identical(p1, c1)) {
        if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
          if (p1 != c1) {
            prev[1] = c1;
            d1 = true;
          }
        } else if (p1 is List && c1 is List) {
          if (p1.length != c1.length) {
            prev[1] = List<Object?>.of(c1, growable: false);
            d1 = true;
          } else {
            d1 = _diffListAndUpdate(p1, c1);
          }
        } else if (p1 is Map && c1 is Map) {
          d1 = _diffMapAndUpdate(p1, c1);
        } else if (_isPropertyDirty(p1, c1)) {
          prev[1] = _updateSnapshot(p1, c1);
          d1 = true;
        }
      } else if (c1 is Iterable || c1 is Map) {
        if (!_deepEquals(p1, c1)) {
          prev[1] = _snapshotValue(c1);
          d1 = true;
        }
      }

      if (!d0 && !d1) {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (d0 && !d1) {
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
      if (!d0 && d1) {
        _dirtyMask = GraftMask.bit1;
        return GraftMask.bit1;
      }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(3, 0)) {
        return curMask;
      }
      final mask = GraftMask.fromWords(3, 0);
      _dirtyMask = mask;
      return mask;
    }

    // ⚡ Hardware Fast-Path: 3-Property State (very common: e.g. form field + error + loading, D1 catalog)
    if (len == 3) {
      final Object? c0, c1, c2;
      if (buf != null) {
        c0 = buf[0];
        c1 = buf[1];
        c2 = buf[2];
      } else {
        c0 = current[0];
        c1 = current[1];
        c2 = current[2];
      }
      final p0 = prev[0], p1 = prev[1], p2 = prev[2];
      int w = 0;
      if (p0 != c0) {
        if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
          prev[0] = c0; w |= 1;
        } else if (c0 is GraftState && p0 is List) {
          if (_diffAndUpdateGraftState(p0, c0)) w |= 1;
        } else if (p0 is List && c0 is List) {
          if (p0.length != c0.length) { prev[0] = List<Object?>.of(c0, growable: false); w |= 1; }
          else if (_diffListAndUpdate(p0, c0)) w |= 1;
        } else if (p0 is Map && c0 is Map) {
          if (_diffMapAndUpdate(p0, c0)) w |= 1;
        } else if (_isPropertyDirty(p0, c0)) {
          prev[0] = _updateSnapshot(p0, c0); w |= 1;
        }
      } else if (c0 is Iterable || c0 is Map) {
        if (!_deepEquals(p0, c0)) { prev[0] = _snapshotValue(c0); w |= 1; }
      }
      if (p1 != c1) {
        if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
          prev[1] = c1; w |= 2;
        } else if (c1 is GraftState && p1 is List) {
          if (_diffAndUpdateGraftState(p1, c1)) w |= 2;
        } else if (p1 is List && c1 is List) {
          if (p1.length != c1.length) { prev[1] = List<Object?>.of(c1, growable: false); w |= 2; }
          else if (_diffListAndUpdate(p1, c1)) w |= 2;
        } else if (p1 is Map && c1 is Map) {
          if (_diffMapAndUpdate(p1, c1)) w |= 2;
        } else if (_isPropertyDirty(p1, c1)) {
          prev[1] = _updateSnapshot(p1, c1); w |= 2;
        }
      } else if (c1 is Iterable || c1 is Map) {
        if (!_deepEquals(p1, c1)) { prev[1] = _snapshotValue(c1); w |= 2; }
      }
      if (p2 != c2) {
        if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
          prev[2] = c2; w |= 4;
        } else if (c2 is GraftState && p2 is List) {
          if (_diffAndUpdateGraftState(p2, c2)) w |= 4;
        } else if (p2 is List && c2 is List) {
          if (p2.length != c2.length) { prev[2] = List<Object?>.of(c2, growable: false); w |= 4; }
          else if (_diffListAndUpdate(p2, c2)) w |= 4;
        } else if (p2 is Map && c2 is Map) {
          if (_diffMapAndUpdate(p2, c2)) w |= 4;
        } else if (_isPropertyDirty(p2, c2)) {
          prev[2] = _updateSnapshot(p2, c2); w |= 4;
        }
      } else if (c2 is Iterable || c2 is Map) {
        if (!_deepEquals(p2, c2)) { prev[2] = _snapshotValue(c2); w |= 4; }
      }
      if (w == 0) { _dirtyMask = GraftMask.empty; return GraftMask.empty; }
      if (w == 7) { _dirtyMask = GraftMask.allBitsUpTo(3); return _dirtyMask; }
      if ((w & (w - 1)) == 0) { final mask = GraftMask.bit(w.bitLength - 1); _dirtyMask = mask; return mask; }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
      _dirtyMask = mask; return mask;
    }

    // ⚡ Hardware Fast-Path: 4-Property State
    if (len == 4) {
      final Object? c0, c1, c2, c3;
      if (buf != null) {
        c0 = buf[0];
        c1 = buf[1];
        c2 = buf[2];
        c3 = buf[3];
      } else {
        c0 = current[0];
        c1 = current[1];
        c2 = current[2];
        c3 = current[3];
      }
      final p0 = prev[0], p1 = prev[1], p2 = prev[2], p3 = prev[3];
      int w = 0;
      if (p0 != c0) {
        if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
          prev[0] = c0; w |= 1;
        } else if (c0 is GraftState && p0 is List) {
          if (_diffAndUpdateGraftState(p0, c0)) w |= 1;
        } else if (p0 is List && c0 is List) {
          if (p0.length != c0.length) { prev[0] = List<Object?>.of(c0, growable: false); w |= 1; }
          else if (_diffListAndUpdate(p0, c0)) w |= 1;
        } else if (p0 is Map && c0 is Map) {
          if (_diffMapAndUpdate(p0, c0)) w |= 1;
        } else if (_isPropertyDirty(p0, c0)) {
          prev[0] = _updateSnapshot(p0, c0); w |= 1;
        }
      } else if (c0 is Iterable || c0 is Map) {
        if (!_deepEquals(p0, c0)) { prev[0] = _snapshotValue(c0); w |= 1; }
      }
      if (p1 != c1) {
        if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
          prev[1] = c1; w |= 2;
        } else if (c1 is GraftState && p1 is List) {
          if (_diffAndUpdateGraftState(p1, c1)) w |= 2;
        } else if (p1 is List && c1 is List) {
          if (p1.length != c1.length) { prev[1] = List<Object?>.of(c1, growable: false); w |= 2; }
          else if (_diffListAndUpdate(p1, c1)) w |= 2;
        } else if (p1 is Map && c1 is Map) {
          if (_diffMapAndUpdate(p1, c1)) w |= 2;
        } else if (_isPropertyDirty(p1, c1)) {
          prev[1] = _updateSnapshot(p1, c1); w |= 2;
        }
      } else if (c1 is Iterable || c1 is Map) {
        if (!_deepEquals(p1, c1)) { prev[1] = _snapshotValue(c1); w |= 2; }
      }
      if (p2 != c2) {
        if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
          prev[2] = c2; w |= 4;
        } else if (c2 is GraftState && p2 is List) {
          if (_diffAndUpdateGraftState(p2, c2)) w |= 4;
        } else if (p2 is List && c2 is List) {
          if (p2.length != c2.length) { prev[2] = List<Object?>.of(c2, growable: false); w |= 4; }
          else if (_diffListAndUpdate(p2, c2)) w |= 4;
        } else if (p2 is Map && c2 is Map) {
          if (_diffMapAndUpdate(p2, c2)) w |= 4;
        } else if (_isPropertyDirty(p2, c2)) {
          prev[2] = _updateSnapshot(p2, c2); w |= 4;
        }
      } else if (c2 is Iterable || c2 is Map) {
        if (!_deepEquals(p2, c2)) { prev[2] = _snapshotValue(c2); w |= 4; }
      }
      if (p3 != c3) {
        if (c3 is! Iterable && c3 is! Map && c3 is! GraftState) {
          prev[3] = c3; w |= 8;
        } else if (c3 is GraftState && p3 is List) {
          if (_diffAndUpdateGraftState(p3, c3)) w |= 8;
        } else if (p3 is List && c3 is List) {
          if (p3.length != c3.length) { prev[3] = List<Object?>.of(c3, growable: false); w |= 8; }
          else if (_diffListAndUpdate(p3, c3)) w |= 8;
        } else if (p3 is Map && c3 is Map) {
          if (_diffMapAndUpdate(p3, c3)) w |= 8;
        } else if (_isPropertyDirty(p3, c3)) {
          prev[3] = _updateSnapshot(p3, c3); w |= 8;
        }
      } else if (c3 is Iterable || c3 is Map) {
        if (!_deepEquals(p3, c3)) { prev[3] = _snapshotValue(c3); w |= 8; }
      }
      if (w == 0) { _dirtyMask = GraftMask.empty; return GraftMask.empty; }
      if (w == 15) { _dirtyMask = GraftMask.allBitsUpTo(4); return _dirtyMask; }
      if ((w & (w - 1)) == 0) { final mask = GraftMask.bit(w.bitLength - 1); _dirtyMask = mask; return mask; }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
      _dirtyMask = mask; return mask;
    }

    // ⚡ Hardware Fast-Path: 5-Property State (A3 benchmark: 5-field multi-update)
    if (len == 5) {
      final Object? c0, c1, c2, c3, c4;
      if (buf != null) {
        c0 = buf[0];
        c1 = buf[1];
        c2 = buf[2];
        c3 = buf[3];
        c4 = buf[4];
      } else {
        c0 = current[0];
        c1 = current[1];
        c2 = current[2];
        c3 = current[3];
        c4 = current[4];
      }
      final p0 = prev[0], p1 = prev[1], p2 = prev[2], p3 = prev[3], p4 = prev[4];
      int w = 0;
      if (p0 != c0) {
        if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
          prev[0] = c0; w |= 1;
        } else if (c0 is GraftState && p0 is List) {
          if (_diffAndUpdateGraftState(p0, c0)) w |= 1;
        } else if (p0 is List && c0 is List) {
          if (p0.length != c0.length) { prev[0] = List<Object?>.of(c0, growable: false); w |= 1; }
          else if (_diffListAndUpdate(p0, c0)) w |= 1;
        } else if (p0 is Map && c0 is Map) {
          if (_diffMapAndUpdate(p0, c0)) w |= 1;
        } else if (_isPropertyDirty(p0, c0)) {
          prev[0] = _updateSnapshot(p0, c0); w |= 1;
        }
      } else if (c0 is Iterable || c0 is Map) {
        if (!_deepEquals(p0, c0)) { prev[0] = _snapshotValue(c0); w |= 1; }
      }
      if (p1 != c1) {
        if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
          prev[1] = c1; w |= 2;
        } else if (c1 is GraftState && p1 is List) {
          if (_diffAndUpdateGraftState(p1, c1)) w |= 2;
        } else if (p1 is List && c1 is List) {
          if (p1.length != c1.length) { prev[1] = List<Object?>.of(c1, growable: false); w |= 2; }
          else if (_diffListAndUpdate(p1, c1)) w |= 2;
        } else if (p1 is Map && c1 is Map) {
          if (_diffMapAndUpdate(p1, c1)) w |= 2;
        } else if (_isPropertyDirty(p1, c1)) {
          prev[1] = _updateSnapshot(p1, c1); w |= 2;
        }
      } else if (c1 is Iterable || c1 is Map) {
        if (!_deepEquals(p1, c1)) { prev[1] = _snapshotValue(c1); w |= 2; }
      }
      if (p2 != c2) {
        if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
          prev[2] = c2; w |= 4;
        } else if (c2 is GraftState && p2 is List) {
          if (_diffAndUpdateGraftState(p2, c2)) w |= 4;
        } else if (p2 is List && c2 is List) {
          if (p2.length != c2.length) { prev[2] = List<Object?>.of(c2, growable: false); w |= 4; }
          else if (_diffListAndUpdate(p2, c2)) w |= 4;
        } else if (p2 is Map && c2 is Map) {
          if (_diffMapAndUpdate(p2, c2)) w |= 4;
        } else if (_isPropertyDirty(p2, c2)) {
          prev[2] = _updateSnapshot(p2, c2); w |= 4;
        }
      } else if (c2 is Iterable || c2 is Map) {
        if (!_deepEquals(p2, c2)) { prev[2] = _snapshotValue(c2); w |= 4; }
      }
      if (p3 != c3) {
        if (c3 is! Iterable && c3 is! Map && c3 is! GraftState) {
          prev[3] = c3; w |= 8;
        } else if (c3 is GraftState && p3 is List) {
          if (_diffAndUpdateGraftState(p3, c3)) w |= 8;
        } else if (p3 is List && c3 is List) {
          if (p3.length != c3.length) { prev[3] = List<Object?>.of(c3, growable: false); w |= 8; }
          else if (_diffListAndUpdate(p3, c3)) w |= 8;
        } else if (p3 is Map && c3 is Map) {
          if (_diffMapAndUpdate(p3, c3)) w |= 8;
        } else if (_isPropertyDirty(p3, c3)) {
          prev[3] = _updateSnapshot(p3, c3); w |= 8;
        }
      } else if (c3 is Iterable || c3 is Map) {
        if (!_deepEquals(p3, c3)) { prev[3] = _snapshotValue(c3); w |= 8; }
      }
      if (p4 != c4) {
        if (c4 is! Iterable && c4 is! Map && c4 is! GraftState) {
          prev[4] = c4; w |= 16;
        } else if (c4 is GraftState && p4 is List) {
          if (_diffAndUpdateGraftState(p4, c4)) w |= 16;
        } else if (p4 is List && c4 is List) {
          if (p4.length != c4.length) { prev[4] = List<Object?>.of(c4, growable: false); w |= 16; }
          else if (_diffListAndUpdate(p4, c4)) w |= 16;
        } else if (p4 is Map && c4 is Map) {
          if (_diffMapAndUpdate(p4, c4)) w |= 16;
        } else if (_isPropertyDirty(p4, c4)) {
          prev[4] = _updateSnapshot(p4, c4); w |= 16;
        }
      } else if (c4 is Iterable || c4 is Map) {
        if (!_deepEquals(p4, c4)) { prev[4] = _snapshotValue(c4); w |= 16; }
      }
      if (w == 0) { _dirtyMask = GraftMask.empty; return GraftMask.empty; }
      if (w == 31) { _dirtyMask = GraftMask.allBitsUpTo(5); return _dirtyMask; }
      if ((w & (w - 1)) == 0) { final mask = GraftMask.bit(w.bitLength - 1); _dirtyMask = mask; return mask; }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
      _dirtyMask = mask; return mask;
    }


    int singleDirtyIndex = -1;
    int dirtyCount = 0;
    int w0 = 0;
    int w1 = 0;
    List<int>? extra;

    for (int i = 0; i < len; i++) {
      final p = prev[i];
      final c = buf != null ? buf[i] : current[i];

      bool dirty = false;
      if (!identical(p, c)) {
        if (c is! Iterable && c is! Map && c is! GraftState) {
          if (p != c) {
            prev[i] = c;
            dirty = true;
          }
        } else if (p is List && c is List) {
          if (p.length != c.length) {
            prev[i] = List<Object?>.of(c, growable: false);
            dirty = true;
          } else {
            dirty = _diffListAndUpdate(p, c);
          }
        } else if (p is Map && c is Map) {
          dirty = _diffMapAndUpdate(p, c);
        } else if (_isPropertyDirty(p, c)) {
          prev[i] = _updateSnapshot(p, c);
          dirty = true;
        }
      } else if (c is Iterable || c is Map) {
        if (!_deepEquals(p, c)) {
          prev[i] = _snapshotValue(c);
          dirty = true;
        }
      }

      if (!dirty) continue;

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
    }

    if (dirtyCount == 0) {
      _dirtyMask = GraftMask.empty;
      return GraftMask.empty;
    }
    if (dirtyCount == 1 && singleDirtyIndex < 64) {
      final mask = GraftMask.bit(singleDirtyIndex);
      _dirtyMask = mask;
      return mask;
    }
    final curMask = _dirtyMask;
    if (!curMask.isAllDirty && curMask.matchesWords(w0, w1, extra)) {
      return curMask;
    }
    final mask = GraftMask.fromWords(w0, w1, extra);
    _dirtyMask = mask;
    return mask;
  }

  /// Triggers fine-grained slot diffing and notifies all listeners synchronously.
  @nonVirtual
  @pragma('vm:prefer-inline')
  void update() {
    // ⚡ Increment version stamp BEFORE diffing so nested states can track this update
    _version++;
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
    _baseline = null;
    _singleBaseline = _undefined;
    _dirtyMask = GraftMask.allDirty;
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

final class _GraftPropsSingle extends GraftProps {
  Object? value;
  _GraftPropsSingle(this.value);

  @override
  Object? operator [](int index) {
    if (index != 0) throw RangeError.index(index, this);
    return value;
  }

  @override
  int get length => 1;

  @override
  Iterator<Object?> get iterator => _SingleIterator(value);
}

final class _SingleIterator implements Iterator<Object?> {
  final Object? _value;
  bool _moved = false;

  _SingleIterator(this._value);

  @override
  Object? get current => _moved ? _value : null;

  @override
  bool moveNext() {
    if (!_moved) {
      _moved = true;
      return true;
    }
    return false;
  }
}


