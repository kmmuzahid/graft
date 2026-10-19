/// Computes a structural fingerprint from props based on count and types.
library;

import '../../core/graft_state.dart';
import 'graft_model.dart';

/// Computes a structural fingerprint of state props.
///
/// Computed once on Frame-0 initialization and cached in memory.
/// Never re-computed during active `update()` frame diffs, adding 0ns
/// overhead to keystroke mutations.
final class SchemaFingerprint {
  SchemaFingerprint._();

  /// Computes a structural fingerprint hash from [props].
  ///
  /// Recursively incorporates [GraftModel] properties to ensure nested
  /// model schema modifications automatically invalidate stale data.
  @pragma('vm:prefer-inline')
  static int compute(GraftProps props) {
    final len = props.length;
    int hash = len;
    for (int i = 0; i < len; i++) {
      final val = props[i];
      if (val is GraftModel) {
        hash = Object.hash(hash, val.runtimeType, compute(val.props));
      } else if (val is GraftProps) {
        hash = Object.hash(hash, val.runtimeType, compute(val));
      } else {
        hash = Object.hash(hash, val.runtimeType);
      }
    }
    return hash;
  }
}
