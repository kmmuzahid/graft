part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _tryFastBufferScalar(GraftState state, List<Object?> prev, int len) {
  state.props;
  final buf = state._propsBuffer;
  if (buf == null) return false;

  int w = 0;
  if (len == 2) {
    if (prev[0] != buf[0]) {
      prev[0] = buf[0];
      w |= 1;
    }
    if (prev[1] != buf[1]) {
      prev[1] = buf[1];
      w |= 2;
    }
    if (w == 0) return true;
    final mask = w == 3
        ? GraftMask.allBitsUpTo(2)
        : (w == 1 ? GraftMask.bit0 : GraftMask.bit1);
    _stateDispatchNotification(state, mask);
    return true;
  }
  if (len == 3) {
    if (prev[0] != buf[0]) {
      prev[0] = buf[0];
      w |= 1;
    }
    if (prev[1] != buf[1]) {
      prev[1] = buf[1];
      w |= 2;
    }
    if (prev[2] != buf[2]) {
      prev[2] = buf[2];
      w |= 4;
    }
    if (w == 0) return true;
    final mask =
        w == 7 ? GraftMask.allBitsUpTo(3) : GraftMask.fromWords(w, 0);
    _stateDispatchNotification(state, mask);
    return true;
  }
  if (len == 4) {
    if (prev[0] != buf[0]) {
      prev[0] = buf[0];
      w |= 1;
    }
    if (prev[1] != buf[1]) {
      prev[1] = buf[1];
      w |= 2;
    }
    if (prev[2] != buf[2]) {
      prev[2] = buf[2];
      w |= 4;
    }
    if (prev[3] != buf[3]) {
      prev[3] = buf[3];
      w |= 8;
    }
    if (w == 0) return true;
    final mask =
        w == 15 ? GraftMask.allBitsUpTo(4) : GraftMask.fromWords(w, 0);
    _stateDispatchNotification(state, mask);
    return true;
  }
  if (len == 5) {
    if (prev[0] != buf[0]) {
      prev[0] = buf[0];
      w |= 1;
    }
    if (prev[1] != buf[1]) {
      prev[1] = buf[1];
      w |= 2;
    }
    if (prev[2] != buf[2]) {
      prev[2] = buf[2];
      w |= 4;
    }
    if (prev[3] != buf[3]) {
      prev[3] = buf[3];
      w |= 8;
    }
    if (prev[4] != buf[4]) {
      prev[4] = buf[4];
      w |= 16;
    }
    if (w == 0) return true;
    final mask =
        w == 31 ? GraftMask.allBitsUpTo(5) : GraftMask.fromWords(w, 0);
    _stateDispatchNotification(state, mask);
    return true;
  }
  return false;
}

