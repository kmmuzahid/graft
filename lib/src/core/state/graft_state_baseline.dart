part of '../graft_state.dart';

void _initBaselineImpl(GraftState state) {
  final current = state.props;
  final len = current.length;
  state._baselineNeedsSync = false;
  if (len == 1) {
    final c = current is _GraftPropsSingle ? current.value : current[0];
    state._singleBaseline = _snapshotValue(c);
    state._prevListLength = c is List ? c.length : -1;
    state._allScalarProps = c is num || c is String || c is bool || c is Enum;
    if (state._allScalarProps) state._scalarCount = 1;
    state._hasAsyncProps = c is GraftAsync;
    state._singleNestedVersion = c is GraftState ? c._version : -1;
    if (c is GraftState) {
      c._initBaseline();
      c._graft = state._graft;
      GraftState cur = c;
      while (cur.props.length == 1) {
        final next = cur.props is _GraftPropsSingle
            ? (cur.props as _GraftPropsSingle).value
            : cur.props[0];
        if (next is GraftState) {
          next._initBaseline();
          next._graft = state._graft;
          cur = next;
        } else {
          break;
        }
      }
      state._leafState = cur;
      cur._graft = state._graft;
      GraftState chain = c;
      while (!identical(chain, cur)) {
        chain._leafState = cur;
        chain._graft = state._graft;
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
        state._baseline = List<Object?>.generate(
          len,
          (i) {
            final v = current[i];
            if (v is GraftState) nestedVers![i] = v._version;
            return _snapshotValue(v);
          },
          growable: false,
        );
      } else {
        state._baseline = List<Object?>.of(list, growable: false);
      }
    } else {
      bool hasNested = false;
      state._baseline = List<Object?>.generate(
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
    state._nestedVersions = nestedVers;
    bool allScalar = true;
    bool hasAsync = false;
    for (int i = 0; i < len; i++) {
      final v = current[i];
      if (v is GraftAsync) hasAsync = true;
      if (v is! num && v is! String && v is! bool && v is! Enum) {
        allScalar = false;
      }
    }
    state._allScalarProps = allScalar;
    state._hasAsyncProps = hasAsync;
    if (allScalar && len >= 2 && len <= 5) {
      state._scalarCount = len;
      state._s0 = state._b0 = current[0];
      state._s1 = state._b1 = current[1];
      if (len > 2) state._s2 = state._b2 = current[2];
      if (len > 3) state._s3 = state._b3 = current[3];
      if (len > 4) state._s4 = state._b4 = current[4];
    }
  }
}

List<Object?> _getBaselineSnapshot(GraftState state) {
  if (!identical(state._singleBaseline, _undefined)) {
    return [state._singleBaseline];
  }
  if (state._scalarCount >= 2 && state._scalarCount <= 5) {
    return [
      state._b0,
      state._b1,
      if (state._scalarCount > 2) state._b2,
      if (state._scalarCount > 3) state._b3,
      if (state._scalarCount > 4) state._b4,
    ];
  }
  return state._baseline != null
      ? List<Object?>.unmodifiable(state._baseline!)
      : const [];
}
