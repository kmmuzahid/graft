part of '../graft_state.dart';

@pragma('vm:prefer-inline')
Object? _snapshotValue(Object? value) {
  if (value == null ||
      value is num ||
      value is String ||
      value is bool ||
      value is Enum) {
    return value;
  }
  if (value is GraftState) {
    if (value._baseline == null &&
        identical(value._singleBaseline, _undefined)) {
      value._initBaseline();
    }
    value._diffChanges();
    return value;
  }
  if (value is List) {
    if (value.isNotEmpty && value[0] is GraftState) {
      for (int i = 0; i < value.length; i++) {
        final item = value[i];
        if (item is GraftState) {
          if (item._baseline == null &&
              identical(item._singleBaseline, _undefined)) {
            item._initBaseline();
          }
          item._diffChanges();
        }
      }
    }
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
bool _deepEquals(Object? a, Object? b) {
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
      if (!b.containsKey(entry.key) || !_deepEquals(entry.value, b[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}

@pragma('vm:prefer-inline')
bool _isPropertyDirty(Object? p, Object? c) {
  if (identical(p, c)) {
    if (c is GraftState) return c._diffChanges().isNotEmpty;
    if (c is Iterable || c is Map) return !_deepEquals(p, c);
    return false;
  }
  if (c == null || p == null) return true;
  if (c is num || c is String || c is bool || c is Enum) return p != c;
  if (c is GraftState) return c._diffChanges().isNotEmpty;
  if (p is List && c is List) {
    if (p.length != c.length) return true;
    for (int j = 0; j < p.length; j++) {
      if (!identical(p[j], c[j]) && p[j] != c[j]) return true;
    }
    return false;
  }
  if (p is Set && c is Set) return p.length != c.length || !_deepEquals(p, c);
  if (p is Map && c is Map) return p.length != c.length || !_deepEquals(p, c);
  return p != c;
}

@pragma('vm:prefer-inline')
Object? _updateSnapshot(Object? p, Object? c) {
  if (c is List) {
    if (p is List && p.length == c.length) {
      for (int i = 0; i < p.length; i++) {
        p[i] = _snapshotValue(c[i]);
      }
      return p;
    }
    return List<Object?>.of(c, growable: false);
  }
  return _snapshotValue(c);
}
