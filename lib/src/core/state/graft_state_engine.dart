part of '../graft_state.dart';

/// Internal engine accessor for [GraftState].
/// Internal to package:graft; never exported in public API.
@internal
abstract final class GraftStateEngine {
  /// Returns the hardware-aligned domain property container for [state].
  static GraftProps props(GraftState state) => state.props;

  /// Binds [state] to [graft] and initializes baseline snapshot.
  static void bind(GraftState state, Graft graft) => state._bindGraft(graft);

  /// Initializes the baseline snapshot of [state].
  static void initBaseline(GraftState state) => state._initBaseline();

  /// Sets whether dry persistence is enabled for [state].
  static void setDryEnabled(GraftState state, bool enabled) =>
      state._isDryEnabled = enabled;

  /// Sets custom dry storage key for [state].
  static void setCustomDryKey(GraftState state, String? key) =>
      state._customDryKey = key;

  /// Whether dry persistence is enabled for [state].
  static bool isDryEnabled(GraftState state) => state._isDryEnabled;

  /// Returns the current version counter of [state].
  static int version(GraftState state) => state._version;

  /// Returns unmodifiable snapshot of baseline properties for [state].
  static List<Object?> baselineSnapshot(GraftState state) =>
      state._baselineSnapshot;

  /// Executes property diffing pass on [state] and returns the dirty bitmask.
  static GraftMask diff(GraftState state) => state._diffChanges();

  /// Whether [state] contains any [GraftAsync] properties.
  static bool hasAsyncProps(GraftState state) => state._hasAsyncProps;

  /// Returns the number of scalar properties cached on [state].
  static int scalarCount(GraftState state) => state._scalarCount;
}
