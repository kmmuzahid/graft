import 'package:flutter/foundation.dart';
import 'graft.dart';
import 'graft_change.dart';
import 'graft_mask.dart';
import '../persistence/dry/dry_state_hook.dart';
import '../persistence/model/graft_model.dart';

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
  @nonVirtual
  int get version => _version;

  List<Object?>? _hydrationBuffer;
  int _hydrationReadIndex = 0;
  List<Object?>? _probeProps;
  bool _isDryEnabled = false;
  String? _customDryKey;
  bool _isCapturingDry = false;
  final List<Object?> _capturedDry = [];

  /// Whether dry persistence has been activated.
  @internal
  bool get isDryEnabled => _isDryEnabled;

  /// Internal engine hook to activate dry persistence.
  @internal
  void setDryEnabledInternal(bool enabled) {
    _isDryEnabled = enabled;
  }

  /// Internal engine hook to configure custom dry storage key.
  @internal
  void setCustomDryKeyInternal(String? key) {
    _customDryKey = key;
  }

  /// Optional storage key identifying this state in persistence.
  /// Defaults to the class name ([runtimeType.toString()]).
  String get dryKey => _customDryKey ?? runtimeType.toString();

  /// Primary lifecycle hook called during Frame-0 dry hydration to map persistent fields.
  ///
  /// Overriding this method automatically activates Frame-0 dry persistence with zero boilerplate:
  /// ```dart
  /// @override
  /// void onDry() {
  ///   name = dry(name);
  ///   score = dry(score);
  /// }
  /// ```
  void onDry() => onHydrate();

  /// Legacy hydration hook. Prefer [onDry].
  void onHydrate() {}

  /// Declares and restores a persistent domain property during [onDry].
  ///
  /// Automatically infers type [T] from [fallback] with zero magic strings:
  /// ```dart
  /// name = dry(name);
  /// score = dry(score);
  /// ```
  T dry<T>(T fallback) {
    if (_isCapturingDry) {
      _capturedDry.add(fallback);
      return fallback;
    }
    return read<T>(fallback);
  }

  /// Declares and restores a nested [GraftModel] during [onDry].
  M dryModel<M extends GraftModel>(M model) {
    if (_isCapturingDry) {
      _capturedDry.add(model);
      return model;
    }
    readModel(model);
    return model;
  }

  /// Captures values declared via [dry] in [onDry].
  @internal
  List<Object?> captureDryValues() {
    _capturedDry.clear();
    _isCapturingDry = true;
    final p = props;
    _probeProps =
        List<Object?>.generate(p.length, (i) => p[i], growable: false);
    _hydrationReadIndex = 0;
    try {
      onDry();
      if (_capturedDry.isNotEmpty) {
        _isDryEnabled = true;
        return List<Object?>.from(_capturedDry);
      }
      if (_hydrationReadIndex > 0) {
        _isDryEnabled = true;
      }
      return const [];
    } finally {
      _isCapturingDry = false;
      _probeProps = null;
    }
  }

  /// Type-safe auto-incrementing property reader for Frame-0 hydration.
  T read<T>([T? fallback]) {
    final buf = _hydrationBuffer;
    if (buf != null) {
      if (_hydrationReadIndex < buf.length) {
        final val = buf[_hydrationReadIndex++];
        if (val == null && fallback != null) return fallback;
        if (val is T) return val;
        if (fallback != null) return fallback;
        return val as T;
      }
      _hydrationReadIndex++;
      if (fallback != null) return fallback;
      throw StateError(
        'read() called at index ${_hydrationReadIndex - 1}, but only ${buf.length} values exist in hydration payload.',
      );
    }
    final p = _probeProps;
    if (p != null && _hydrationReadIndex < p.length) {
      final val = p[_hydrationReadIndex++];
      if (val is T) return val;
      if (fallback != null) return fallback;
      return val as T;
    }
    _hydrationReadIndex++;
    if (fallback != null) return fallback;
    return null as T;
  }

  /// Hydrates a nested [GraftModel] using the next value in the hydration sequence.
  void readModel(GraftModel model) {
    final buf = _hydrationBuffer;
    if (buf != null) {
      if (_hydrationReadIndex < buf.length) {
        final val = buf[_hydrationReadIndex++];
        if (val is List) {
          model.hydrate(val.cast<Object?>());
        } else if (val is GraftProps) {
          model.hydrate(val.cast<Object?>().toList());
        }
        return;
      }
      _hydrationReadIndex++;
      return;
    }
    final p = _probeProps;
    if (p != null && _hydrationReadIndex < p.length) {
      _hydrationReadIndex++;
      model.probeModel();
      return;
    }
    _hydrationReadIndex++;
  }

  /// Restores domain properties and nested models from [tuple] during Frame-0 hydration.
  @internal
  void hydrate(List<Object?> tuple) {
    _hydrationBuffer = tuple;
    _hydrationReadIndex = 0;
    try {
      onDry();
      if (_hydrationReadIndex > 0) {
        _isDryEnabled = true;
      }
      final currentProps = props;
      for (int i = _hydrationReadIndex;
          i < currentProps.length && i < tuple.length;
          i++) {
        final prop = currentProps[i];
        final val = tuple[i];
        if (prop is GraftModel && val is List) {
          prop.hydrate(val.cast<Object?>());
        }
      }
    } finally {
      _hydrationBuffer = null;
    }
  }

  /// Probes whether [onDry] or [onHydrate] is overridden when no cached data exists.
  @internal
  void probeWithoutCache() {
    final dryVals = captureDryValues();
    if (dryVals.isNotEmpty) {
      _isDryEnabled = true;
      return;
    }
    final p = props;
    _probeProps =
        List<Object?>.generate(p.length, (i) => p[i], growable: false);
    _hydrationReadIndex = 0;
    try {
      onDry();
      if (_hydrationReadIndex > 0) {
        _isDryEnabled = true;
      }
      final currentProps = props;
      for (int i = _hydrationReadIndex; i < currentProps.length; i++) {
        final prop = currentProps[i];
        if (prop is GraftModel) {
          prop.probeModel();
        }
      }
    } finally {
      _probeProps = null;
    }
  }

  /// Permanently deactivates and invalidates dry state persistence for this session.
  void invalidateDry() => DryStateHook.invalidate(this);

  /// Binds this state instance to its owning [Graft] controller.
  ///
  /// This method is called automatically by the [Graft] constructor.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void bindGraft(Graft graft) {
    _graft = graft;
    DryStateHook.hydrateSync(this);
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
      _allScalarProps = c is num || c is String || c is bool || c is Enum;
      // Capture version for O(1) nested GraftState detection.
      _singleNestedVersion = c is GraftState ? c._version : -1;
      if (c is GraftState) {
        c.initBaseline();
        c._graft = _graft;
        GraftState cur = c;
        while (cur.props.length == 1) {
          final next = cur.props is _GraftPropsSingle
              ? (cur.props as _GraftPropsSingle).value
              : cur.props[0];
          if (next is GraftState) {
            next.initBaseline();
            next._graft = _graft;
            cur = next;
          } else {
            break;
          }
        }
        _leafState = cur;
        cur._graft = _graft;
        GraftState chain = c;
        while (!identical(chain, cur)) {
          chain._leafState = cur;
          chain._graft = _graft;
          final next = chain.props is _GraftPropsSingle
              ? (chain.props as _GraftPropsSingle).value
              : chain.props[0];
          if (next is GraftState) {
            chain = next;
          } else {
            break;
          }
        }
      }
      return;
    }
    if (len > 1) {
      List<int>? nestedVers;
      if (current is _GraftPropsListView) {
        final list = current._list;
        if (list.isNotEmpty && list[0] is GraftState) {
          nestedVers = List<int>.filled(len, -1);
          _baseline = List<Object?>.generate(
            len,
            (i) {
              final v = current[i];
              if (v is GraftState) nestedVers![i] = v._version;
              return _snapshotValue(v);
            },
            growable: false,
          );
        } else {
          _baseline = List<Object?>.of(list, growable: false);
        }
      } else {
        bool hasNested = false;
        _baseline = List<Object?>.generate(
          len,
          (i) {
            final v = current[i];
            if (v is GraftState) hasNested = true;
            return _snapshotValue(v);
          },
          growable: false,
        );
        if (hasNested) {
          nestedVers = List<int>.filled(len, -1);
          for (int i = 0; i < len; i++) {
            final v = current[i];
            if (v is GraftState) nestedVers[i] = v._version;
          }
        }
      }
      _nestedVersions = nestedVers;
      bool allScalar = true;
      for (int i = 0; i < len; i++) {
        final v = current[i];
        if (v is! num && v is! String && v is! bool && v is! Enum) {
          allScalar = false;
          break;
        }
      }
      _allScalarProps = allScalar;
      if (allScalar && len >= 2 && len <= 5) {
        _scalarCount = len;
        _s0 = _b0 = current[0];
        _s1 = _b1 = current[1];
        if (len > 2) _s2 = _b2 = current[2];
        if (len > 3) _s3 = _b3 = current[3];
        if (len > 4) _s4 = _b4 = current[4];
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
    if (_scalarCount >= 2 && _scalarCount <= 5) {
      return [
        _b0,
        _b1,
        if (_scalarCount > 2) _b2,
        if (_scalarCount > 3) _b3,
        if (_scalarCount > 4) _b4,
      ];
    }
    return _baseline != null
        ? List<Object?>.unmodifiable(_baseline!)
        : const [];
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

  /// Captured _version of a single nested GraftState prop at baseline time.
  /// When non-negative, used for O(1) nested state change detection instead
  /// of recursive [diffChanges] traversal.
  int _singleNestedVersion = -1;

  /// Parallel version-stamp array for multi-prop nested [GraftState] entries.
  /// Index i mirrors [_baseline][i] when that entry is a [GraftState].
  List<int>? _nestedVersions;

  /// Direct pointer to leaf GraftState in nested hierarchy for zero-hop O(1) leaf mutations.
  GraftState? _leafState;

  /// Whether all properties are scalar primitives (num, String, bool, Enum).
  /// Enables zero-branch pure scalar diff fast-paths.
  bool _allScalarProps = false;
  int _scalarCount = 0;
  Object? _s0, _s1, _s2, _s3, _s4;
  Object? _b0, _b1, _b2, _b3, _b4;

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
  @nonVirtual
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
      if (p0 is List && p0.isNotEmpty && p0[0] is GraftState) {
        return _GraftPropsListView(p0);
      }
      _pendingSingle = p0;
      final view = _singleView;
      if (view != null) {
        view.value = p0;
        return view;
      }
      if (identical(p0, _undefined)) return const _EmptyGraftProps();
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
        _s0 = buf[0] = p0;
        _s1 = buf[1] = p1;
        break;
      case 3:
        _s0 = buf[0] = p0;
        _s1 = buf[1] = p1;
        _s2 = buf[2] = p2;
        break;
      case 4:
        _s0 = buf[0] = p0;
        _s1 = buf[1] = p1;
        _s2 = buf[2] = p2;
        _s3 = buf[3] = p3;
        break;
      case 5:
        _s0 = buf[0] = p0;
        _s1 = buf[1] = p1;
        _s2 = buf[2] = p2;
        _s3 = buf[3] = p3;
        _s4 = buf[4] = p4;
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

  /// Unpacks an arbitrary [Iterable] or list of properties into individual bitmask property slots.
  ///
  /// ### Why use `propsOfMany` instead of `propsOf`?
  /// 1. **Massive or Dynamic States (>16 Fields):**
  ///    [propsOf] accepts up to 16 comma-separated arguments via CPU registers. If your state
  ///    has more than 16 fields (e.g. 50 form fields, dynamic grids, or 1000 items), pass the
  ///    collection here.
  /// 2. **Prevents Ambiguity with List Fields:**
  ///    When a property in [propsOf] is a `List` (e.g. `propsOf(name, items)`), it is treated as
  ///    a single property. Use [propsOfMany] only when each item in the collection should be
  ///    tracked as an independent bitmask slot.
  @protected
  @nonVirtual
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
      value.diffChanges();
      return value;
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
    if (value is GraftModel) {
      final p = value.props;
      return List<Object?>.generate(
        p.length,
        (i) => _snapshotValue(p[i]),
        growable: false,
      );
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
    if (a is List && b is GraftModel) {
      final bp = b.props;
      final len = a.length;
      if (len != bp.length) return false;
      for (int i = 0; i < len; i++) {
        if (!_deepEquals(a[i], bp[i])) return false;
      }
      return true;
    }
    if (a is GraftModel && b is List) {
      final ap = a.props;
      final len = ap.length;
      if (len != b.length) return false;
      for (int i = 0; i < len; i++) {
        if (!_deepEquals(ap[i], b[i])) return false;
      }
      return true;
    }
    if (a is GraftModel && b is GraftModel) {
      final ap = a.props;
      final bp = b.props;
      final len = ap.length;
      if (len != bp.length) return false;
      for (int i = 0; i < len; i++) {
        if (!_deepEquals(ap[i], bp[i])) return false;
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
      if (c is GraftState) {
        return c.diffChanges().isNotEmpty;
      }
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
      return c.diffChanges().isNotEmpty;
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
    int i = 0;
    while (i + 15 < len) {
      if ((identical(p[i], c[i]) || p[i] == c[i]) &&
          (identical(p[i + 1], c[i + 1]) || p[i + 1] == c[i + 1]) &&
          (identical(p[i + 2], c[i + 2]) || p[i + 2] == c[i + 2]) &&
          (identical(p[i + 3], c[i + 3]) || p[i + 3] == c[i + 3]) &&
          (identical(p[i + 4], c[i + 4]) || p[i + 4] == c[i + 4]) &&
          (identical(p[i + 5], c[i + 5]) || p[i + 5] == c[i + 5]) &&
          (identical(p[i + 6], c[i + 6]) || p[i + 6] == c[i + 6]) &&
          (identical(p[i + 7], c[i + 7]) || p[i + 7] == c[i + 7]) &&
          (identical(p[i + 8], c[i + 8]) || p[i + 8] == c[i + 8]) &&
          (identical(p[i + 9], c[i + 9]) || p[i + 9] == c[i + 9]) &&
          (identical(p[i + 10], c[i + 10]) || p[i + 10] == c[i + 10]) &&
          (identical(p[i + 11], c[i + 11]) || p[i + 11] == c[i + 11]) &&
          (identical(p[i + 12], c[i + 12]) || p[i + 12] == c[i + 12]) &&
          (identical(p[i + 13], c[i + 13]) || p[i + 13] == c[i + 13]) &&
          (identical(p[i + 14], c[i + 14]) || p[i + 14] == c[i + 14]) &&
          (identical(p[i + 15], c[i + 15]) || p[i + 15] == c[i + 15])) {
        i += 16;
        continue;
      }
      break;
    }
    while (i + 7 < len) {
      if ((identical(p[i], c[i]) || p[i] == c[i]) &&
          (identical(p[i + 1], c[i + 1]) || p[i + 1] == c[i + 1]) &&
          (identical(p[i + 2], c[i + 2]) || p[i + 2] == c[i + 2]) &&
          (identical(p[i + 3], c[i + 3]) || p[i + 3] == c[i + 3]) &&
          (identical(p[i + 4], c[i + 4]) || p[i + 4] == c[i + 4]) &&
          (identical(p[i + 5], c[i + 5]) || p[i + 5] == c[i + 5]) &&
          (identical(p[i + 6], c[i + 6]) || p[i + 6] == c[i + 6]) &&
          (identical(p[i + 7], c[i + 7]) || p[i + 7] == c[i + 7])) {
        i += 8;
        continue;
      }
      break;
    }
    for (; i < len; i++) {
      final pi = p[i];
      final ci = c[i];
      if (!identical(pi, ci)) {
        if (pi != ci) {
          p[i] = ci;
          final next = i + 1;
          if (next >= len) return true;
          int end = len - 1;
          while (end - 15 >= next) {
            if ((identical(p[end], c[end]) || p[end] == c[end]) &&
                (identical(p[end - 1], c[end - 1]) ||
                    p[end - 1] == c[end - 1]) &&
                (identical(p[end - 2], c[end - 2]) ||
                    p[end - 2] == c[end - 2]) &&
                (identical(p[end - 3], c[end - 3]) ||
                    p[end - 3] == c[end - 3]) &&
                (identical(p[end - 4], c[end - 4]) ||
                    p[end - 4] == c[end - 4]) &&
                (identical(p[end - 5], c[end - 5]) ||
                    p[end - 5] == c[end - 5]) &&
                (identical(p[end - 6], c[end - 6]) ||
                    p[end - 6] == c[end - 6]) &&
                (identical(p[end - 7], c[end - 7]) ||
                    p[end - 7] == c[end - 7]) &&
                (identical(p[end - 8], c[end - 8]) ||
                    p[end - 8] == c[end - 8]) &&
                (identical(p[end - 9], c[end - 9]) ||
                    p[end - 9] == c[end - 9]) &&
                (identical(p[end - 10], c[end - 10]) ||
                    p[end - 10] == c[end - 10]) &&
                (identical(p[end - 11], c[end - 11]) ||
                    p[end - 11] == c[end - 11]) &&
                (identical(p[end - 12], c[end - 12]) ||
                    p[end - 12] == c[end - 12]) &&
                (identical(p[end - 13], c[end - 13]) ||
                    p[end - 13] == c[end - 13]) &&
                (identical(p[end - 14], c[end - 14]) ||
                    p[end - 14] == c[end - 14]) &&
                (identical(p[end - 15], c[end - 15]) ||
                    p[end - 15] == c[end - 15])) {
              end -= 16;
              continue;
            }
            break;
          }
          while (end - 7 >= next) {
            if ((identical(p[end], c[end]) || p[end] == c[end]) &&
                (identical(p[end - 1], c[end - 1]) ||
                    p[end - 1] == c[end - 1]) &&
                (identical(p[end - 2], c[end - 2]) ||
                    p[end - 2] == c[end - 2]) &&
                (identical(p[end - 3], c[end - 3]) ||
                    p[end - 3] == c[end - 3]) &&
                (identical(p[end - 4], c[end - 4]) ||
                    p[end - 4] == c[end - 4]) &&
                (identical(p[end - 5], c[end - 5]) ||
                    p[end - 5] == c[end - 5]) &&
                (identical(p[end - 6], c[end - 6]) ||
                    p[end - 6] == c[end - 6]) &&
                (identical(p[end - 7], c[end - 7]) ||
                    p[end - 7] == c[end - 7])) {
              end -= 8;
              continue;
            }
            break;
          }
          while (
              end >= next && (identical(p[end], c[end]) || p[end] == c[end])) {
            end--;
          }
          if (end < next) return true;
          for (int j = next; j <= end; j++) {
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
    for (final entry in c.entries) {
      final k = entry.key;
      final cv = entry.value;
      final pv = p[k];
      if (!identical(pv, cv) && pv != cv) {
        p[k] = cv;
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
      return c;
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
      if (_allScalarProps) {
        props;
        final c = _pendingSingle;
        if (p == c) {
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        _singleBaseline = c;
        _dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
      if (p is GraftState) {
        // ⚡ O(1) version-stamp check: compare captured version vs current.
        // This replaces 8-level recursive diffChanges() traversal with a single
        // integer comparison — same cost as GetX's Rx version check.
        final cv = p._version;
        final capturedV = _singleNestedVersion;
        if (capturedV >= 0 && cv == capturedV) {
          props;
          final c = _pendingSingle;
          if (!identical(p, c)) {
            _singleBaseline = c;
            _singleNestedVersion = c is GraftState ? c._version : -1;
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        // Version changed or not yet captured — run leaf diff directly if cached.
        final leaf = _leafState;
        if (leaf != null) {
          if (leaf.diffChanges().isNotEmpty) {
            _singleNestedVersion = p._version;
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
          _singleNestedVersion = p._version;
          props;
          final c = _pendingSingle;
          if (!identical(p, c)) {
            _singleBaseline = c;
            _singleNestedVersion = c is GraftState ? c._version : -1;
            _dirtyMask = GraftMask.bit0;
            return GraftMask.bit0;
          }
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        GraftState cur = p;
        while (cur._baseline == null) {
          final next = cur._singleBaseline;
          if (next is GraftState) {
            cur = next;
          } else {
            break;
          }
        }
        if (cur.diffChanges().isNotEmpty) {
          _singleNestedVersion = p._version;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _singleNestedVersion = p._version;
        props;
        final c = _pendingSingle;
        if (!identical(p, c)) {
          _singleBaseline = c;
          _singleNestedVersion = c is GraftState ? c._version : -1;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
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
      if (c is GraftState) {
        // ⚡ O(1) version-stamp for early-return GraftState prop.
        if (!identical(p, c)) {
          _singleBaseline = c;
          _singleNestedVersion = c._version;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        final cv = c._version;
        final capturedV = _singleNestedVersion;
        if (capturedV >= 0 && cv == capturedV) {
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        if (c.diffChanges().isNotEmpty) {
          _singleNestedVersion = cv;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _singleNestedVersion = cv;
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
          // ⚡ In-place element mutation: same reference, same length → emit bit0.
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
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
        // Capture nested GraftState version for O(1) detection.
        _singleNestedVersion = c is GraftState ? c._version : -1;
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
      if (c is GraftState) {
        // ⚡ O(1) version-stamp for len==1 GraftState prop (A4 depth-8 path).
        if (!identical(p, c)) {
          _singleBaseline = c;
          _singleNestedVersion = c._version;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        final cv = c._version;
        final capturedV = _singleNestedVersion;
        if (capturedV >= 0 && cv == capturedV) {
          _dirtyMask = GraftMask.empty;
          return GraftMask.empty;
        }
        // Version changed: propagate diff to leaf to sync baseline, then stamp.
        if (c.diffChanges().isNotEmpty) {
          _singleNestedVersion = cv;
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
        }
        _singleNestedVersion = cv;
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
          // ⚡ In-place element mutation: same reference, same length → emit bit0.
          _dirtyMask = GraftMask.bit0;
          return GraftMask.bit0;
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
      bool d1 = false;
      if (_allScalarProps) {
        if (p0 != c0) {
          prev[0] = c0;
          d0 = true;
        }
        if (p1 != c1) {
          prev[1] = c1;
          d1 = true;
        }
      } else {
        if (!identical(p0, c0)) {
          if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
            if (p0 != c0) {
              prev[0] = c0;
              d0 = true;
            }
          } else if (c0 is GraftState) {
            if (!identical(p0, c0) || c0.diffChanges().isNotEmpty) {
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
        } else if (c0 is GraftState) {
          if (c0.diffChanges().isNotEmpty) {
            prev[0] = c0;
            d0 = true;
          }
        } else if (c0 is Iterable || c0 is Map) {
          if (!_deepEquals(p0, c0)) {
            prev[0] = _snapshotValue(c0);
            d0 = true;
          }
        }

        if (!identical(p1, c1)) {
          if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
            if (p1 != c1) {
              prev[1] = c1;
              d1 = true;
            }
          } else if (c1 is GraftState) {
            if (!identical(p1, c1) || c1.diffChanges().isNotEmpty) {
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
        } else if (c1 is GraftState) {
          if (c1.diffChanges().isNotEmpty) {
            prev[1] = c1;
            d1 = true;
          }
        } else if (c1 is Iterable || c1 is Map) {
          if (!_deepEquals(p1, c1)) {
            prev[1] = _snapshotValue(c1);
            d1 = true;
          }
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
      if (_allScalarProps) {
        if (p0 != c0) {
          prev[0] = c0;
          w |= 1;
        }
        if (p1 != c1) {
          prev[1] = c1;
          w |= 2;
        }
        if (p2 != c2) {
          prev[2] = c2;
          w |= 4;
        }
      } else {
        if (p0 != c0) {
          if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
            prev[0] = c0;
            w |= 1;
          } else if (c0 is GraftState) {
            if (!identical(p0, c0) || c0.diffChanges().isNotEmpty) {
              prev[0] = c0;
              w |= 1;
            }
          } else if (p0 is List && c0 is List) {
            if (p0.length != c0.length) {
              prev[0] = List<Object?>.of(c0, growable: false);
              w |= 1;
            } else if (_diffListAndUpdate(p0, c0)) {
              w |= 1;
            }
          } else if (p0 is Map && c0 is Map) {
            if (_diffMapAndUpdate(p0, c0)) w |= 1;
          } else if (_isPropertyDirty(p0, c0)) {
            prev[0] = _updateSnapshot(p0, c0);
            w |= 1;
          }
        } else if (c0 is GraftState) {
          if (c0.diffChanges().isNotEmpty) {
            prev[0] = c0;
            w |= 1;
          }
        } else if (c0 is Iterable || c0 is Map) {
          if (!_deepEquals(p0, c0)) {
            prev[0] = _snapshotValue(c0);
            w |= 1;
          }
        }
        if (p1 != c1) {
          if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
            prev[1] = c1;
            w |= 2;
          } else if (c1 is GraftState) {
            if (!identical(p1, c1) || c1.diffChanges().isNotEmpty) {
              prev[1] = c1;
              w |= 2;
            }
          } else if (p1 is List && c1 is List) {
            if (p1.length != c1.length) {
              prev[1] = List<Object?>.of(c1, growable: false);
              w |= 2;
            } else if (_diffListAndUpdate(p1, c1)) {
              w |= 2;
            }
          } else if (p1 is Map && c1 is Map) {
            if (_diffMapAndUpdate(p1, c1)) w |= 2;
          } else if (_isPropertyDirty(p1, c1)) {
            prev[1] = _updateSnapshot(p1, c1);
            w |= 2;
          }
        } else if (c1 is GraftState) {
          if (c1.diffChanges().isNotEmpty) {
            prev[1] = c1;
            w |= 2;
          }
        } else if (c1 is Iterable || c1 is Map) {
          if (!_deepEquals(p1, c1)) {
            prev[1] = _snapshotValue(c1);
            w |= 2;
          }
        }
        if (p2 != c2) {
          if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
            prev[2] = c2;
            w |= 4;
          } else if (c2 is GraftState) {
            if (!identical(p2, c2) || c2.diffChanges().isNotEmpty) {
              prev[2] = c2;
              w |= 4;
            }
          } else if (p2 is List && c2 is List) {
            if (p2.length != c2.length) {
              prev[2] = List<Object?>.of(c2, growable: false);
              w |= 4;
            } else if (_diffListAndUpdate(p2, c2)) {
              w |= 4;
            }
          } else if (p2 is Map && c2 is Map) {
            if (_diffMapAndUpdate(p2, c2)) w |= 4;
          } else if (_isPropertyDirty(p2, c2)) {
            prev[2] = _updateSnapshot(p2, c2);
            w |= 4;
          }
        } else if (c2 is GraftState) {
          if (c2.diffChanges().isNotEmpty) {
            prev[2] = c2;
            w |= 4;
          }
        } else if (c2 is Iterable || c2 is Map) {
          if (!_deepEquals(p2, c2)) {
            prev[2] = _snapshotValue(c2);
            w |= 4;
          }
        }
      }
      if (w == 0) {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (w == 7) {
        _dirtyMask = GraftMask.allBitsUpTo(3);
        return _dirtyMask;
      }
      if ((w & (w - 1)) == 0) {
        final mask = GraftMask.bit(w.bitLength - 1);
        _dirtyMask = mask;
        return mask;
      }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
      _dirtyMask = mask;
      return mask;
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
      if (_allScalarProps) {
        if (p0 != c0) {
          prev[0] = c0;
          w |= 1;
        }
        if (p1 != c1) {
          prev[1] = c1;
          w |= 2;
        }
        if (p2 != c2) {
          prev[2] = c2;
          w |= 4;
        }
        if (p3 != c3) {
          prev[3] = c3;
          w |= 8;
        }
      } else {
        if (p0 != c0) {
          if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
            prev[0] = c0;
            w |= 1;
          } else if (c0 is GraftState) {
            if (!identical(p0, c0) || c0.diffChanges().isNotEmpty) {
              prev[0] = c0;
              w |= 1;
            }
          } else if (p0 is List && c0 is List) {
            if (p0.length != c0.length) {
              prev[0] = List<Object?>.of(c0, growable: false);
              w |= 1;
            } else if (_diffListAndUpdate(p0, c0)) {
              w |= 1;
            }
          } else if (p0 is Map && c0 is Map) {
            if (_diffMapAndUpdate(p0, c0)) w |= 1;
          } else if (_isPropertyDirty(p0, c0)) {
            prev[0] = _updateSnapshot(p0, c0);
            w |= 1;
          }
        } else if (c0 is GraftState) {
          if (c0.diffChanges().isNotEmpty) {
            prev[0] = c0;
            w |= 1;
          }
        } else if (c0 is Iterable || c0 is Map) {
          if (!_deepEquals(p0, c0)) {
            prev[0] = _snapshotValue(c0);
            w |= 1;
          }
        }
        if (p1 != c1) {
          if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
            prev[1] = c1;
            w |= 2;
          } else if (c1 is GraftState) {
            if (!identical(p1, c1) || c1.diffChanges().isNotEmpty) {
              prev[1] = c1;
              w |= 2;
            }
          } else if (p1 is List && c1 is List) {
            if (p1.length != c1.length) {
              prev[1] = List<Object?>.of(c1, growable: false);
              w |= 2;
            } else if (_diffListAndUpdate(p1, c1)) {
              w |= 2;
            }
          } else if (p1 is Map && c1 is Map) {
            if (_diffMapAndUpdate(p1, c1)) w |= 2;
          } else if (_isPropertyDirty(p1, c1)) {
            prev[1] = _updateSnapshot(p1, c1);
            w |= 2;
          }
        } else if (c1 is GraftState) {
          if (c1.diffChanges().isNotEmpty) {
            prev[1] = c1;
            w |= 2;
          }
        } else if (c1 is Iterable || c1 is Map) {
          if (!_deepEquals(p1, c1)) {
            prev[1] = _snapshotValue(c1);
            w |= 2;
          }
        }
        if (p2 != c2) {
          if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
            prev[2] = c2;
            w |= 4;
          } else if (c2 is GraftState) {
            if (!identical(p2, c2) || c2.diffChanges().isNotEmpty) {
              prev[2] = c2;
              w |= 4;
            }
          } else if (p2 is List && c2 is List) {
            if (p2.length != c2.length) {
              prev[2] = List<Object?>.of(c2, growable: false);
              w |= 4;
            } else if (_diffListAndUpdate(p2, c2)) {
              w |= 4;
            }
          } else if (p2 is Map && c2 is Map) {
            if (_diffMapAndUpdate(p2, c2)) w |= 4;
          } else if (_isPropertyDirty(p2, c2)) {
            prev[2] = _updateSnapshot(p2, c2);
            w |= 4;
          }
        } else if (c2 is GraftState) {
          if (c2.diffChanges().isNotEmpty) {
            prev[2] = c2;
            w |= 4;
          }
        } else if (c2 is Iterable || c2 is Map) {
          if (!_deepEquals(p2, c2)) {
            prev[2] = _snapshotValue(c2);
            w |= 4;
          }
        }
        if (p3 != c3) {
          if (c3 is! Iterable && c3 is! Map && c3 is! GraftState) {
            prev[3] = c3;
            w |= 8;
          } else if (c3 is GraftState) {
            if (!identical(p3, c3) || c3.diffChanges().isNotEmpty) {
              prev[3] = c3;
              w |= 8;
            }
          } else if (p3 is List && c3 is List) {
            if (p3.length != c3.length) {
              prev[3] = List<Object?>.of(c3, growable: false);
              w |= 8;
            } else if (_diffListAndUpdate(p3, c3)) {
              w |= 8;
            }
          } else if (p3 is Map && c3 is Map) {
            if (_diffMapAndUpdate(p3, c3)) w |= 8;
          } else if (_isPropertyDirty(p3, c3)) {
            prev[3] = _updateSnapshot(p3, c3);
            w |= 8;
          }
        } else if (c3 is GraftState) {
          if (c3.diffChanges().isNotEmpty) {
            prev[3] = c3;
            w |= 8;
          }
        } else if (c3 is Iterable || c3 is Map) {
          if (!_deepEquals(p3, c3)) {
            prev[3] = _snapshotValue(c3);
            w |= 8;
          }
        }
      }
      if (w == 0) {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (w == 15) {
        _dirtyMask = GraftMask.allBitsUpTo(4);
        return _dirtyMask;
      }
      if ((w & (w - 1)) == 0) {
        final mask = GraftMask.bit(w.bitLength - 1);
        _dirtyMask = mask;
        return mask;
      }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
      _dirtyMask = mask;
      return mask;
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
      final p0 = prev[0],
          p1 = prev[1],
          p2 = prev[2],
          p3 = prev[3],
          p4 = prev[4];
      int w = 0;
      if (_allScalarProps) {
        if (p0 != c0) {
          prev[0] = c0;
          w |= 1;
        }
        if (p1 != c1) {
          prev[1] = c1;
          w |= 2;
        }
        if (p2 != c2) {
          prev[2] = c2;
          w |= 4;
        }
        if (p3 != c3) {
          prev[3] = c3;
          w |= 8;
        }
        if (p4 != c4) {
          prev[4] = c4;
          w |= 16;
        }
      } else {
        if (p0 != c0) {
          if (c0 is! Iterable && c0 is! Map && c0 is! GraftState) {
            prev[0] = c0;
            w |= 1;
          } else if (c0 is GraftState) {
            if (!identical(p0, c0) || c0.diffChanges().isNotEmpty) {
              prev[0] = c0;
              w |= 1;
            }
          } else if (p0 is List && c0 is List) {
            if (p0.length != c0.length) {
              prev[0] = List<Object?>.of(c0, growable: false);
              w |= 1;
            } else if (_diffListAndUpdate(p0, c0)) {
              w |= 1;
            }
          } else if (p0 is Map && c0 is Map) {
            if (_diffMapAndUpdate(p0, c0)) w |= 1;
          } else if (_isPropertyDirty(p0, c0)) {
            prev[0] = _updateSnapshot(p0, c0);
            w |= 1;
          }
        } else if (c0 is GraftState) {
          if (c0.diffChanges().isNotEmpty) {
            prev[0] = c0;
            w |= 1;
          }
        } else if (c0 is Iterable || c0 is Map) {
          if (!_deepEquals(p0, c0)) {
            prev[0] = _snapshotValue(c0);
            w |= 1;
          }
        }
        if (p1 != c1) {
          if (c1 is! Iterable && c1 is! Map && c1 is! GraftState) {
            prev[1] = c1;
            w |= 2;
          } else if (c1 is GraftState) {
            if (!identical(p1, c1) || c1.diffChanges().isNotEmpty) {
              prev[1] = c1;
              w |= 2;
            }
          } else if (p1 is List && c1 is List) {
            if (p1.length != c1.length) {
              prev[1] = List<Object?>.of(c1, growable: false);
              w |= 2;
            } else if (_diffListAndUpdate(p1, c1)) {
              w |= 2;
            }
          } else if (p1 is Map && c1 is Map) {
            if (_diffMapAndUpdate(p1, c1)) w |= 2;
          } else if (_isPropertyDirty(p1, c1)) {
            prev[1] = _updateSnapshot(p1, c1);
            w |= 2;
          }
        } else if (c1 is GraftState) {
          if (c1.diffChanges().isNotEmpty) {
            prev[1] = c1;
            w |= 2;
          }
        } else if (c1 is Iterable || c1 is Map) {
          if (!_deepEquals(p1, c1)) {
            prev[1] = _snapshotValue(c1);
            w |= 2;
          }
        }
        if (p2 != c2) {
          if (c2 is! Iterable && c2 is! Map && c2 is! GraftState) {
            prev[2] = c2;
            w |= 4;
          } else if (c2 is GraftState) {
            if (!identical(p2, c2) || c2.diffChanges().isNotEmpty) {
              prev[2] = c2;
              w |= 4;
            }
          } else if (p2 is List && c2 is List) {
            if (p2.length != c2.length) {
              prev[2] = List<Object?>.of(c2, growable: false);
              w |= 4;
            } else if (_diffListAndUpdate(p2, c2)) {
              w |= 4;
            }
          } else if (p2 is Map && c2 is Map) {
            if (_diffMapAndUpdate(p2, c2)) w |= 4;
          } else if (_isPropertyDirty(p2, c2)) {
            prev[2] = _updateSnapshot(p2, c2);
            w |= 4;
          }
        } else if (c2 is GraftState) {
          if (c2.diffChanges().isNotEmpty) {
            prev[2] = c2;
            w |= 4;
          }
        } else if (c2 is Iterable || c2 is Map) {
          if (!_deepEquals(p2, c2)) {
            prev[2] = _snapshotValue(c2);
            w |= 4;
          }
        }
        if (p3 != c3) {
          if (c3 is! Iterable && c3 is! Map && c3 is! GraftState) {
            prev[3] = c3;
            w |= 8;
          } else if (c3 is GraftState) {
            if (!identical(p3, c3) || c3.diffChanges().isNotEmpty) {
              prev[3] = c3;
              w |= 8;
            }
          } else if (p3 is List && c3 is List) {
            if (p3.length != c3.length) {
              prev[3] = List<Object?>.of(c3, growable: false);
              w |= 8;
            } else if (_diffListAndUpdate(p3, c3)) {
              w |= 8;
            }
          } else if (p3 is Map && c3 is Map) {
            if (_diffMapAndUpdate(p3, c3)) w |= 8;
          } else if (_isPropertyDirty(p3, c3)) {
            prev[3] = _updateSnapshot(p3, c3);
            w |= 8;
          }
        } else if (c3 is GraftState) {
          if (c3.diffChanges().isNotEmpty) {
            prev[3] = c3;
            w |= 8;
          }
        } else if (c3 is Iterable || c3 is Map) {
          if (!_deepEquals(p3, c3)) {
            prev[3] = _snapshotValue(c3);
            w |= 8;
          }
        }
        if (p4 != c4) {
          if (c4 is! Iterable && c4 is! Map && c4 is! GraftState) {
            prev[4] = c4;
            w |= 16;
          } else if (c4 is GraftState) {
            if (!identical(p4, c4) || c4.diffChanges().isNotEmpty) {
              prev[4] = c4;
              w |= 16;
            }
          } else if (p4 is List && c4 is List) {
            if (p4.length != c4.length) {
              prev[4] = List<Object?>.of(c4, growable: false);
              w |= 16;
            } else if (_diffListAndUpdate(p4, c4)) {
              w |= 16;
            }
          } else if (p4 is Map && c4 is Map) {
            if (_diffMapAndUpdate(p4, c4)) w |= 16;
          } else if (_isPropertyDirty(p4, c4)) {
            prev[4] = _updateSnapshot(p4, c4);
            w |= 16;
          }
        } else if (c4 is GraftState) {
          if (c4.diffChanges().isNotEmpty) {
            prev[4] = c4;
            w |= 16;
          }
        } else if (c4 is Iterable || c4 is Map) {
          if (!_deepEquals(p4, c4)) {
            prev[4] = _snapshotValue(c4);
            w |= 16;
          }
        }
      }
      if (w == 0) {
        _dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      if (w == 31) {
        _dirtyMask = GraftMask.allBitsUpTo(5);
        return _dirtyMask;
      }
      if ((w & (w - 1)) == 0) {
        final mask = GraftMask.bit(w.bitLength - 1);
        _dirtyMask = mask;
        return mask;
      }
      final curMask = _dirtyMask;
      if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) return curMask;
      final mask = GraftMask.fromWords(w, 0);
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
      final c = buf != null ? buf[i] : current[i];

      bool dirty = false;
      if (!identical(p, c)) {
        if (c is! Iterable && c is! Map && c is! GraftState) {
          if (p != c) {
            prev[i] = c;
            dirty = true;
          }
        } else if (c is GraftState) {
          if (!identical(p, c)) {
            prev[i] = c;
            final nv = _nestedVersions;
            if (nv != null && i < nv.length) nv[i] = c._version;
            dirty = true;
          } else {
            final nv = _nestedVersions;
            if (nv != null && i < nv.length) {
              final cv = c._version;
              if (nv[i] != cv) {
                nv[i] = cv;
                if (c.diffChanges().isNotEmpty) {
                  prev[i] = c;
                  dirty = true;
                }
              }
            } else if (c.diffChanges().isNotEmpty) {
              prev[i] = c;
              dirty = true;
            }
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
      } else if (c is GraftState) {
        final nv = _nestedVersions;
        if (nv != null && i < nv.length) {
          final cv = c._version;
          if (nv[i] != cv) {
            nv[i] = cv;
            if (c.diffChanges().isNotEmpty) {
              prev[i] = c;
              dirty = true;
            }
          }
        } else if (c.diffChanges().isNotEmpty) {
          prev[i] = c;
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

  @pragma('vm:prefer-inline')
  void _dispatchNotification(GraftMask mask) {
    if (_isDryEnabled) {
      DryStateHook.onStateUpdated(this);
    }
    final g = _graft;
    if (g != null) {
      if (g.hasOnlyFastDirectReceiver) {
        final fast = g.fastDirectReceiver!;
        if (fast.mounted) {
          fast.markFastDirty();
          return;
        }
        g.fastDirectReceiver = null;
      }
      if (g.hasOnlySingleListener) {
        g.singleListener!();
        return;
      }
      _dirtyMask = mask;
      g.notifyMask(mask);
    }
  }

  /// Triggers fine-grained slot diffing and notifies all listeners synchronously.
  /// When [itemIndex] is provided, dispatches directly to the item slot at [itemIndex]
  /// with 0 closure overhead on other list items.
  @nonVirtual
  @pragma('vm:prefer-inline')
  void update({int? itemIndex}) {
    if (itemIndex != null) {
      _version++;
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
      _dirtyMask = GraftMask.bit0;
      final g = _graft;
      if (g != null && g.hasItemReceiver(itemIndex)) {
        g.notifyItem(itemIndex);
        return;
      }
    }
    final p = _singleBaseline;
    if (_allScalarProps &&
        _baseline == null &&
        !identical(p, _undefined) &&
        Graft.observer == null) {
      props;
      final c = _pendingSingle;
      if (p == c) return;
      _version++;
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
      _singleBaseline = c;
      final g = _graft;
      if (g != null) {
        if (g.hasOnlyFastDirectReceiver) {
          final fast = g.fastDirectReceiver!;
          if (fast.mounted) {
            fast.markFastDirty();
            return;
          }
          g.fastDirectReceiver = null;
        }
        if (g.hasOnlySingleListener) {
          g.singleListener!();
          return;
        }
        _dirtyMask = GraftMask.bit0;
        g.notifyMask(GraftMask.bit0);
      }
      return;
    }
    final sc = _scalarCount;
    if (sc == 5 && Graft.observer == null) {
      props;
      final c0 = _s0, c1 = _s1, c2 = _s2, c3 = _s3, c4 = _s4;
      final p0 = _b0, p1 = _b1, p2 = _b2, p3 = _b3, p4 = _b4;
      int w = 0;
      if (p0 != c0) {
        _b0 = c0;
        w |= 1;
      }
      if (p1 != c1) {
        _b1 = c1;
        w |= 2;
      }
      if (p2 != c2) {
        _b2 = c2;
        w |= 4;
      }
      if (p3 != c3) {
        _b3 = c3;
        w |= 8;
      }
      if (p4 != c4) {
        _b4 = c4;
        w |= 16;
      }
      if (w == 0) return;
      _version++;
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
      final g = _graft;
      if (g != null) {
        if (g.hasOnlyFastDirectReceiver) {
          final fast = g.fastDirectReceiver!;
          if (fast.mounted) {
            fast.markFastDirty();
            return;
          }
          g.fastDirectReceiver = null;
        }
        if (g.hasOnlySingleListener) {
          g.singleListener!();
          return;
        }
        final mask =
            w == 31 ? GraftMask.allBitsUpTo(5) : GraftMask.fromWords(w, 0);
        _dirtyMask = mask;
        g.notifyMask(mask);
      }
      return;
    }
    if (sc >= 2 && sc < 5 && Graft.observer == null) {
      props;
      final c0 = _s0, c1 = _s1;
      final p0 = _b0, p1 = _b1;
      int w = 0;
      if (p0 != c0) {
        _b0 = c0;
        w |= 1;
      }
      if (p1 != c1) {
        _b1 = c1;
        w |= 2;
      }
      if (sc > 2) {
        final c2 = _s2, p2 = _b2;
        if (p2 != c2) {
          _b2 = c2;
          w |= 4;
        }
        if (sc > 3) {
          final c3 = _s3, p3 = _b3;
          if (p3 != c3) {
            _b3 = c3;
            w |= 8;
          }
        }
      }
      if (w == 0) return;
      _version++;
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
      final g = _graft;
      if (g != null) {
        if (g.hasOnlyFastDirectReceiver) {
          final fast = g.fastDirectReceiver!;
          if (fast.mounted) {
            fast.markFastDirty();
            return;
          }
          g.fastDirectReceiver = null;
        }
        if (g.hasOnlySingleListener) {
          g.singleListener!();
          return;
        }
        final mask = w == ((1 << sc) - 1)
            ? GraftMask.allBitsUpTo(sc)
            : GraftMask.fromWords(w, 0);
        _dirtyMask = mask;
        g.notifyMask(mask);
      }
      return;
    }
    final leaf = _leafState;
    if (leaf != null && Graft.observer == null) {
      _version++;
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
      leaf.update();
      return;
    }
    if (_baseline == null &&
        !identical(p, _undefined) &&
        Graft.observer == null) {
      if (p is List) {
        props;
        final c = _pendingSingle;
        if (c is List) {
          final clen = c.length;
          if (_prevListLength != clen) {
            _prevListLength = clen;
            _baselineNeedsSync = true;
            _version++;
            _dirtyMask = GraftMask.bit0;
            _dispatchNotification(GraftMask.bit0);
            return;
          }
          if (_baselineNeedsSync) {
            _singleBaseline = List<Object?>.of(c, growable: false);
            _baselineNeedsSync = false;
            _version++;
            _dirtyMask = GraftMask.bit0;
            _dispatchNotification(GraftMask.bit0);
            return;
          }
          if (_diffListAndUpdate(p, c)) {
            _version++;
            _dirtyMask = GraftMask.bit0;
            _dispatchNotification(GraftMask.bit0);
            return;
          }
        }
      } else if (p is GraftState) {
        // ⚡ Direct O(1) leaf state resolution without recursive traversal.
        final cur = _leafState ?? p;
        final leafP = cur._singleBaseline;
        if (cur._baseline == null &&
            (cur._allScalarProps ||
                leafP is num ||
                leafP is String ||
                leafP is bool ||
                leafP is Enum)) {
          cur.props;
          final c = cur._pendingSingle;
          if (leafP == c) return;
          _version++;
          cur._version++;
          cur._singleBaseline = c;
          _singleNestedVersion = p._version; // stamp root's child version
          _dirtyMask = GraftMask.bit0;
          final g = _graft;
          if (g != null) g.notifyMask(GraftMask.bit0);
          return;
        }
        if (cur.diffChanges().isNotEmpty) {
          _version++;
          cur._version++;
          _singleNestedVersion = p._version; // stamp root's child version
          _dirtyMask = GraftMask.bit0;
          final g = _graft;
          if (g != null) g.notifyMask(GraftMask.bit0);
          return;
        }
      }
    }

    _version++;

    final prev = _baseline;
    if (prev != null && _allScalarProps && Graft.observer == null) {
      props;
      final buf = _propsBuffer;
      final len = prev.length;
      if (buf != null) {
        if (len == 5) {
          final c0 = buf[0], c1 = buf[1], c2 = buf[2], c3 = buf[3], c4 = buf[4];
          final p0 = prev[0],
              p1 = prev[1],
              p2 = prev[2],
              p3 = prev[3],
              p4 = prev[4];
          int w = 0;
          if (p0 != c0) {
            prev[0] = c0;
            w |= 1;
          }
          if (p1 != c1) {
            prev[1] = c1;
            w |= 2;
          }
          if (p2 != c2) {
            prev[2] = c2;
            w |= 4;
          }
          if (p3 != c3) {
            prev[3] = c3;
            w |= 8;
          }
          if (p4 != c4) {
            prev[4] = c4;
            w |= 16;
          }
          if (w == 0) return;
          final mask =
              w == 31 ? GraftMask.allBitsUpTo(5) : GraftMask.fromWords(w, 0);
          _dispatchNotification(mask);
          return;
        } else if (len == 2) {
          final c0 = buf[0], c1 = buf[1];
          final p0 = prev[0], p1 = prev[1];
          int w = 0;
          if (p0 != c0) {
            prev[0] = c0;
            w |= 1;
          }
          if (p1 != c1) {
            prev[1] = c1;
            w |= 2;
          }
          if (w == 0) return;
          final mask = w == 3
              ? GraftMask.allBitsUpTo(2)
              : (w == 1 ? GraftMask.bit0 : GraftMask.bit1);
          _dispatchNotification(mask);
          return;
        } else if (len == 3) {
          final c0 = buf[0], c1 = buf[1], c2 = buf[2];
          final p0 = prev[0], p1 = prev[1], p2 = prev[2];
          int w = 0;
          if (p0 != c0) {
            prev[0] = c0;
            w |= 1;
          }
          if (p1 != c1) {
            prev[1] = c1;
            w |= 2;
          }
          if (p2 != c2) {
            prev[2] = c2;
            w |= 4;
          }
          if (w == 0) return;
          final mask =
              w == 7 ? GraftMask.allBitsUpTo(3) : GraftMask.fromWords(w, 0);
          _dispatchNotification(mask);
          return;
        } else if (len == 4) {
          final c0 = buf[0], c1 = buf[1], c2 = buf[2], c3 = buf[3];
          final p0 = prev[0], p1 = prev[1], p2 = prev[2], p3 = prev[3];
          int w = 0;
          if (p0 != c0) {
            prev[0] = c0;
            w |= 1;
          }
          if (p1 != c1) {
            prev[1] = c1;
            w |= 2;
          }
          if (p2 != c2) {
            prev[2] = c2;
            w |= 4;
          }
          if (p3 != c3) {
            prev[3] = c3;
            w |= 8;
          }
          if (w == 0) return;
          final mask =
              w == 15 ? GraftMask.allBitsUpTo(4) : GraftMask.fromWords(w, 0);
          _dispatchNotification(mask);
          return;
        }
      }
    }
    final hasObserver = Graft.observer != null;
    List<Object?>? prevSnapshot;
    if (hasObserver) {
      prevSnapshot = baselineSnapshot;
    }
    final mask = diffChanges();
    if (mask.isNotEmpty) {
      if (_isDryEnabled) DryStateHook.onStateUpdated(this);
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
  @protected
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

  /// Creates a [GraftProps] instance wrapping [list].
  factory GraftProps.fromList(List<Object?> list) => _GraftPropsList(list);

  /// Gets the property value at [index].
  Object? operator [](int index);

  @override
  int get length;

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length > 0;
}

final class _GraftPropsList extends GraftProps {
  final List<Object?> _list;
  const _GraftPropsList(this._list);

  @override
  Object? operator [](int index) => _list[index];

  @override
  int get length => _list.length;

  @override
  Iterator<Object?> get iterator => _list.iterator;
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
  List<Object?> _list;

  _GraftPropsListView(this._list);

  set list(List<Object?> l) => _list = l;

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
