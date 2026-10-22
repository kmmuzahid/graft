/// Computes a structural fingerprint from props based on count and types.
library;

import 'dart:typed_data';
import '../../core/graft_state.dart';
import 'graft_model.dart';

/// Computes a structural fingerprint of state props.
///
/// Computed once on Frame-0 initialization and cached in memory.
/// Never re-computed during active `update()` frame diffs, adding 0ns
/// overhead to keystroke mutations.
final class SchemaFingerprint {
  SchemaFingerprint._();

  static const int _fnvOffsetBasis = 0x811C9DC5;
  static const int _fnvPrime = 0x01000193;

  @pragma('vm:prefer-inline')
  static int _fnv1aByte(int hash, int byte) {
    hash = (hash ^ byte) & 0xFFFFFFFF;
    return (hash * _fnvPrime) & 0xFFFFFFFF;
  }

  @pragma('vm:prefer-inline')
  static int _fnv1aInt32(int hash, int val) {
    hash = _fnv1aByte(hash, (val >> 24) & 0xFF);
    hash = _fnv1aByte(hash, (val >> 16) & 0xFF);
    hash = _fnv1aByte(hash, (val >> 8) & 0xFF);
    return _fnv1aByte(hash, val & 0xFF);
  }

  static int _fnv1aString(int hash, String str) {
    final len = str.length;
    for (int i = 0; i < len; i++) {
      final code = str.codeUnitAt(i);
      if (code <= 0xFF) {
        hash = _fnv1aByte(hash, code);
      } else {
        hash = _fnv1aByte(hash, (code >> 8) & 0xFF);
        hash = _fnv1aByte(hash, code & 0xFF);
      }
    }
    return hash;
  }

  /// Computes a structural fingerprint hash from [props].
  ///
  /// Recursively incorporates [GraftModel] properties to ensure nested
  /// model schema modifications automatically invalidate stale data.
  @pragma('vm:prefer-inline')
  static int compute(GraftProps props, {int schemaVersion = 1}) {
    int hash = _fnvOffsetBasis;
    hash = _fnv1aInt32(hash, schemaVersion);
    final len = props.length;
    hash = _fnv1aInt32(hash, len);

    for (int i = 0; i < len; i++) {
      hash = _fnv1aByte(hash, i);
      final val = props[i];
      if (val == null) {
        hash = _fnv1aByte(hash, 0);
      } else if (val is bool) {
        hash = _fnv1aByte(hash, 1);
      } else if (val is int) {
        hash = _fnv1aByte(hash, 2);
      } else if (val is double) {
        hash = _fnv1aByte(hash, 3);
      } else if (val is num) {
        hash = _fnv1aByte(hash, 4);
      } else if (val is String) {
        hash = _fnv1aByte(hash, 5);
      } else if (val is List) {
        hash = _fnv1aByte(hash, 6);
        hash = _fnv1aString(hash, val.runtimeType.toString());
      } else if (val is Set) {
        hash = _fnv1aByte(hash, 7);
        hash = _fnv1aString(hash, val.runtimeType.toString());
      } else if (val is Map) {
        hash = _fnv1aByte(hash, 8);
        hash = _fnv1aString(hash, val.runtimeType.toString());
      } else if (val is TypedData) {
        hash = _fnv1aByte(hash, 9);
      } else if (val is GraftModel) {
        hash = _fnv1aByte(hash, 10);
        hash = _fnv1aString(hash, val.runtimeType.toString());
        hash = _fnv1aInt32(hash, val.schemaVersion);
        hash = _fnv1aInt32(
          hash,
          compute(val.props, schemaVersion: val.schemaVersion),
        );
      } else if (val is GraftProps) {
        hash = _fnv1aByte(hash, 11);
        hash = _fnv1aInt32(hash, compute(val, schemaVersion: schemaVersion));
      } else {
        hash = _fnv1aByte(hash, 12);
        hash = _fnv1aString(hash, val.runtimeType.toString());
      }
    }
    return hash.toSigned(32);
  }
}
