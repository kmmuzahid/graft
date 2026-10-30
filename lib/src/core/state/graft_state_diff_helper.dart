part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _diffPropertyAtIndex(
  GraftState state,
  List<Object?> prev,
  int index,
  Object? c,
) {
  final p = prev[index];
  if (!identical(p, c)) {
    if (c is! Iterable && c is! Map && c is! GraftState) {
      if (p != c) {
        prev[index] = c;
        return true;
      }
    } else if (c is GraftState) {
      prev[index] = c;
      final nv = state._nestedVersions;
      if (nv != null && index < nv.length) nv[index] = c._version;
      return true;
    } else if (p is List && c is List) {
      if (p.length != c.length) {
        prev[index] = List<Object?>.of(c, growable: false);
        return true;
      } else {
        return _diffListAndUpdate(p, c);
      }
    } else if (p is Map && c is Map) {
      return _diffMapAndUpdate(p, c);
    } else if (_isPropertyDirty(p, c)) {
      prev[index] = _updateSnapshot(p, c);
      return true;
    }
  } else if (c is GraftState) {
    if (c._diffChanges().isNotEmpty) {
      prev[index] = c;
      final nv = state._nestedVersions;
      if (nv != null && index < nv.length) nv[index] = c._version;
      return true;
    }
  } else if (c is Iterable || c is Map) {
    if (!_deepEquals(p, c)) {
      prev[index] = _snapshotValue(c);
      return true;
    }
  }
  return false;
}
