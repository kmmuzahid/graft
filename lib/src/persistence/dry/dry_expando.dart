/// GC-safe Expando lifecycle manager for dry state metadata.
library;

import '../../core/graft_state.dart';

final class _DryMetadata {
  bool isInvalidated = false;
  int? cachedFingerprint;
  bool isHydrated = false;
  bool isDryEnabled = false;
}

/// Manages GC-safe metadata associated with persistent [GraftState] instances.
final class DryExpando {
  DryExpando._();

  static final Expando<_DryMetadata> _metadata = Expando<_DryMetadata>();

  static _DryMetadata _get(GraftState state) {
    return _metadata[state] ??= _DryMetadata();
  }

  /// Whether [state] has dry persistence activated.
  @pragma('vm:prefer-inline')
  static bool isDryEnabled(GraftState state) =>
      _metadata[state]?.isDryEnabled ?? false;

  /// Sets whether [state] has dry persistence activated.
  @pragma('vm:prefer-inline')
  static void setDryEnabled(GraftState state, bool enabled) {
    _get(state).isDryEnabled = enabled;
  }

  /// Whether [state] has been marked as permanently invalidated.
  @pragma('vm:prefer-inline')
  static bool isInvalidated(GraftState state) =>
      _metadata[state]?.isInvalidated ?? false;

  /// Marks [state] as permanently invalidated for this session.
  @pragma('vm:prefer-inline')
  static void invalidate(GraftState state) {
    _get(state).isInvalidated = true;
  }

  /// Gets the cached schema fingerprint for [state], if computed.
  @pragma('vm:prefer-inline')
  static int? getFingerprint(GraftState state) =>
      _metadata[state]?.cachedFingerprint;

  /// Caches the schema fingerprint for [state].
  @pragma('vm:prefer-inline')
  static void setFingerprint(GraftState state, int fingerprint) {
    _get(state).cachedFingerprint = fingerprint;
  }

  /// Whether [state] has already undergone Frame-0 hydration.
  @pragma('vm:prefer-inline')
  static bool isHydrated(GraftState state) =>
      _metadata[state]?.isHydrated ?? false;

  /// Marks [state] as having completed Frame-0 hydration.
  @pragma('vm:prefer-inline')
  static void setHydrated(GraftState state) {
    _get(state).isHydrated = true;
  }
}
