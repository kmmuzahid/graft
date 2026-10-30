part of '../graft_state.dart';

mixin GraftStateProps on GraftStateStorage {
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
    if (identical(p1, _undefined)) {
      if (p0 is num) {
        _pendingSingle = p0;
        final view = _singleView;
        if (view != null) {
          view.value = p0;
          return view;
        }
        return _singleView = _GraftPropsSingle(p0);
      }
      if (p0 is String || p0 is bool || p0 is Enum) {
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
      view = _propsView = _GraftPropsBuffer(this, buf, count);
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
      default:
        buf[0] = p0;
        buf[1] = p1;
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

  @protected
  @nonVirtual
  @pragma('vm:prefer-inline')
  GraftProps propsOfMany(Iterable<Object?> items) {
    if (items.isEmpty) return const _EmptyGraftProps();
    if (items is List<Object?>) return _GraftPropsListView(items);
    return _GraftPropsListView(List<Object?>.of(items, growable: false));
  }
}
