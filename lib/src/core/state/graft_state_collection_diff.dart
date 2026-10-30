part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _diffListAndUpdate(List p, List c) {
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
              (identical(p[end - 1], c[end - 1]) || p[end - 1] == c[end - 1]) &&
              (identical(p[end - 2], c[end - 2]) || p[end - 2] == c[end - 2]) &&
              (identical(p[end - 3], c[end - 3]) || p[end - 3] == c[end - 3]) &&
              (identical(p[end - 4], c[end - 4]) || p[end - 4] == c[end - 4]) &&
              (identical(p[end - 5], c[end - 5]) || p[end - 5] == c[end - 5]) &&
              (identical(p[end - 6], c[end - 6]) || p[end - 6] == c[end - 6]) &&
              (identical(p[end - 7], c[end - 7]) || p[end - 7] == c[end - 7]) &&
              (identical(p[end - 8], c[end - 8]) || p[end - 8] == c[end - 8]) &&
              (identical(p[end - 9], c[end - 9]) || p[end - 9] == c[end - 9]) &&
              (identical(p[end - 10], c[end - 10]) || p[end - 10] == c[end - 10]) &&
              (identical(p[end - 11], c[end - 11]) || p[end - 11] == c[end - 11]) &&
              (identical(p[end - 12], c[end - 12]) || p[end - 12] == c[end - 12]) &&
              (identical(p[end - 13], c[end - 13]) || p[end - 13] == c[end - 13]) &&
              (identical(p[end - 14], c[end - 14]) || p[end - 14] == c[end - 14]) &&
              (identical(p[end - 15], c[end - 15]) || p[end - 15] == c[end - 15])) {
            end -= 16;
            continue;
          }
          break;
        }
        while (end - 7 >= next) {
          if ((identical(p[end], c[end]) || p[end] == c[end]) &&
              (identical(p[end - 1], c[end - 1]) || p[end - 1] == c[end - 1]) &&
              (identical(p[end - 2], c[end - 2]) || p[end - 2] == c[end - 2]) &&
              (identical(p[end - 3], c[end - 3]) || p[end - 3] == c[end - 3]) &&
              (identical(p[end - 4], c[end - 4]) || p[end - 4] == c[end - 4]) &&
              (identical(p[end - 5], c[end - 5]) || p[end - 5] == c[end - 5]) &&
              (identical(p[end - 6], c[end - 6]) || p[end - 6] == c[end - 6]) &&
              (identical(p[end - 7], c[end - 7]) || p[end - 7] == c[end - 7])) {
            end -= 8;
            continue;
          }
          break;
        }
        while (end >= next && (identical(p[end], c[end]) || p[end] == c[end])) {
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
bool _diffMapAndUpdate(Map p, Map c) {
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

