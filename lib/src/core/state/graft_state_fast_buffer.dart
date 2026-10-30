part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _tryFastBufferScalar(GraftState state, List<Object?> prev, int len) {
  state.props;
  final buf = state._propsBuffer;
  if (buf == null) return false;

  int w = 0;
  int i = 0;
  while (i + 7 < len) {
    if (prev[i] != buf[i]) {
      prev[i] = buf[i];
      w |= (1 << i);
    }
    if (prev[i + 1] != buf[i + 1]) {
      prev[i + 1] = buf[i + 1];
      w |= (1 << (i + 1));
    }
    if (prev[i + 2] != buf[i + 2]) {
      prev[i + 2] = buf[i + 2];
      w |= (1 << (i + 2));
    }
    if (prev[i + 3] != buf[i + 3]) {
      prev[i + 3] = buf[i + 3];
      w |= (1 << (i + 3));
    }
    if (prev[i + 4] != buf[i + 4]) {
      prev[i + 4] = buf[i + 4];
      w |= (1 << (i + 4));
    }
    if (prev[i + 5] != buf[i + 5]) {
      prev[i + 5] = buf[i + 5];
      w |= (1 << (i + 5));
    }
    if (prev[i + 6] != buf[i + 6]) {
      prev[i + 6] = buf[i + 6];
      w |= (1 << (i + 6));
    }
    if (prev[i + 7] != buf[i + 7]) {
      prev[i + 7] = buf[i + 7];
      w |= (1 << (i + 7));
    }
    i += 8;
  }
  for (; i < len; i++) {
    if (prev[i] != buf[i]) {
      prev[i] = buf[i];
      w |= (1 << i);
    }
  }

  if (w == 0) return true;
  final mask = (len <= 32 && w == ((1 << len) - 1))
      ? GraftMask.allBitsUpTo(len)
      : ((w & (w - 1)) == 0
          ? GraftMask.bit(w.bitLength - 1)
          : GraftMask.fromWords(w, 0));
  _stateDispatchNotification(state, mask);
  return true;
}
