/// Engine hooks for Frame-0 synchronous hydration, updates, and invalidations.
library;

import '../../core/graft.dart';
import '../../core/graft_state.dart';
import '../ambient_locator.dart';
import '../model/binary_serializer.dart';
import '../model/graft_model.dart';
import '../model/schema_fingerprint.dart';
import 'dry_expando.dart';

/// Internal engine hook coordinating dry state lifecycle for [GraftState].
final class DryStateHook {
  DryStateHook._();

  /// Restores state instance using constructor tear-off [factory] from Frame-0 binary cache.
  static S hydrateFactory<S extends GraftState>(Function factory, String key) {
    return hydrateFactoryWithStatus<S>(factory, key).$1;
  }

  /// Restores state instance and returns whether it was hydrated from binary cache.
  static (S, bool) hydrateFactoryWithStatus<S extends GraftState>(
    Function factory,
    String key,
  ) {
    final S probe;
    try {
      probe = Function.apply(factory, const []) as S;
    } catch (e) {
      throw StateError(
        'Graft.dry Error: Factory "$factory" could not be instantiated with zero arguments: $e',
      );
    }

    // Tier 2 Runtime Guard: Require schemaVersion on State
    if (probe.schemaVersion <= 0) {
      throw StateError(
        'Graft.dry Error: Class "${probe.runtimeType}" must override '
        '"@override int get schemaVersion => 1;" to guarantee deterministic persistence '
        'and safe schema evolution across app restarts.',
      );
    }

    // Tier 2 Runtime Guard: Require schemaVersion and factory on nested GraftModels
    for (final prop in probe.props) {
      if (prop is GraftModel) {
        if (prop.schemaVersion <= 0) {
          throw StateError(
            'Graft.dry Error: Nested model "${prop.runtimeType}" in "${probe.runtimeType}" '
            'must override "@override int get schemaVersion => 1;".',
          );
        }
        if (prop.factory == null) {
          throw StateError(
            'Graft.dry Error: Nested model "${prop.runtimeType}" in "${probe.runtimeType}" '
            'must override "@override Function get factory => ${prop.runtimeType}.new;" '
            'to enable Frame-0 constructor hydration.',
          );
        }
      }
    }

    final currentFp = SchemaFingerprint.compute(
      probe.props,
      schemaVersion: probe.schemaVersion,
    );

    final cached = ambientStorageCoordinator.readSync(key);
    if (cached != null && cached.isNotEmpty) {
      final decoded = BinarySerializer.decode(cached);
      if (decoded != null && decoded.fingerprint == currentFp) {
        try {
          final args = <Object?>[];
          final probeProps = probe.props;
          final data = decoded.data;
          for (int i = 0; i < probeProps.length && i < data.length; i++) {
            args.add(_hydrateValue(probeProps[i], data[i]));
          }
          final restored = Function.apply(factory, args) as S;
          DryExpando.setFingerprint(restored, currentFp);
          DryExpando.setHydrated(restored);
          return (restored, true);
        } catch (_) {
          // Fall back to probe defaults
        }
      } else {
        // Stale or corrupted cache: purge
        ambientStorageCoordinator.delete(key);
      }
    }
    DryExpando.setFingerprint(probe, currentFp);
    return (probe, false);
  }

  /// Activates dry persistence tracking for [state] initialized via tear-off.
  static void enableDryForState(GraftState state, String dryKey) {
    DryExpando.setDryEnabled(state, true);
    GraftStateEngine.setDryEnabled(state, true);
    DryExpando.setHydrated(state);
    if (DryExpando.getFingerprint(state) == null) {
      final fp = SchemaFingerprint.compute(
        state.props,
        schemaVersion: state.schemaVersion > 0 ? state.schemaVersion : 1,
      );
      DryExpando.setFingerprint(state, fp);
    }
  }

  /// Synchronously restores persisted state from L1 RAM in < 50ns on Frame 0.
  @pragma('vm:prefer-inline')
  static void hydrateSync(GraftState state) {
    // Frame-0 hydration is performed directly by Graft.dry
  }

  /// Saves mutated state to L1 RAM synchronously and debounces disk write.
  @pragma('vm:prefer-inline')
  static void onStateUpdated(GraftState state) {
    if (!GraftStateEngine.isDryEnabled(state) ||
        DryExpando.isInvalidated(state)) {
      return;
    }

    final persistentProps = state.props;

    int? fp = DryExpando.getFingerprint(state);
    if (fp == null) {
      fp = SchemaFingerprint.compute(
        persistentProps,
        schemaVersion: state.schemaVersion > 0 ? state.schemaVersion : 1,
      );
      DryExpando.setFingerprint(state, fp);
    }

    final encoded = BinarySerializer.encode(persistentProps, fp);
    ambientStorageCoordinator.write(state.dryKey, encoded);
  }

  /// Permanently invalidates and purges dry state for [state].
  static void invalidate(GraftState state) {
    DryExpando.invalidate(state);
    ambientStorageCoordinator.delete(state.dryKey);
    Graft.observer?.onDryInvalidated(state, key: state.dryKey);
  }

  /// Purges all dry state matching [prefix].
  static void invalidatePrefix(String prefix) {
    ambientStorageCoordinator.invalidatePrefix(prefix);
    Graft.observer?.onDryInvalidated(prefix, key: prefix, isScopePurge: true);
  }

  static Object? _hydrateValue(Object? defaultVal, Object? cachedVal) {
    if (defaultVal is GraftModel && cachedVal is List) {
      if (defaultVal.factory != null) {
        final subProps = defaultVal.props;
        final subArgs = <Object?>[];
        for (int j = 0; j < subProps.length && j < cachedVal.length; j++) {
          subArgs.add(_hydrateValue(subProps[j], cachedVal[j]));
        }
        return Function.apply(defaultVal.factory!, subArgs);
      }
      return defaultVal;
    }
    if (defaultVal is List && cachedVal is List) {
      if (defaultVal is List<String>) {
        return cachedVal.cast<String>();
      } else if (defaultVal is List<int>) {
        return cachedVal.cast<int>();
      } else if (defaultVal is List<double>) {
        return cachedVal.map((e) => (e as num).toDouble()).toList();
      } else if (defaultVal is List<num>) {
        return cachedVal.cast<num>();
      } else if (defaultVal is List<bool>) {
        return cachedVal.cast<bool>();
      }
      return cachedVal;
    }
    return cachedVal;
  }
}
