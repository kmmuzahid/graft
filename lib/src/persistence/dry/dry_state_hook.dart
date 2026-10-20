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
  static (S, bool) hydrateFactoryWithStatus<S extends GraftState>(Function factory, String key) {
    final cached = ambientStorageCoordinator.readSync(key);
    if (cached != null && cached.isNotEmpty) {
      final decoded = BinarySerializer.decode(cached);
      if (decoded != null) {
        try {
          final probe = Function.apply(factory, const []) as S;
          final currentFp = SchemaFingerprint.compute(probe.props);
          if (decoded.fingerprint == currentFp) {
            final args = <Object?>[];
            final probeProps = probe.props;
            final data = decoded.data;
            for (int i = 0; i < probeProps.length && i < data.length; i++) {
              final defaultVal = probeProps[i];
              final cachedVal = data[i];
              if (defaultVal is GraftModel && cachedVal is List) {
                defaultVal.hydrate(cachedVal.cast<Object?>());
                args.add(defaultVal);
              } else {
                args.add(cachedVal);
              }
            }
            final restored = Function.apply(factory, args) as S;
            DryExpando.setFingerprint(restored, currentFp);
            return (restored, true);
          } else {
            ambientStorageCoordinator.delete(key);
          }
        } catch (_) {
          ambientStorageCoordinator.delete(key);
        }
      }
    }
    return (Function.apply(factory, const []) as S, false);
  }

  /// Activates dry persistence tracking for [state] initialized via tear-off.
  static void enableDryForState(GraftState state, String dryKey) {
    DryExpando.setDryEnabled(state, true);
    state.setDryEnabledInternal(true);
    DryExpando.setHydrated(state);
  }

  /// Synchronously restores persisted state from L1 RAM in < 50ns on Frame 0.
  @pragma('vm:prefer-inline')
  static void hydrateSync(GraftState state) {
    if (DryExpando.isHydrated(state) || DryExpando.isInvalidated(state)) {
      return;
    }

    final dryVals = state.captureDryValues();
    final persistentProps =
        dryVals.isNotEmpty ? GraftProps.fromList(dryVals) : state.props;
    final currentFp = SchemaFingerprint.compute(persistentProps);
    DryExpando.setFingerprint(state, currentFp);

    final key = state.dryKey;
    final cached = ambientStorageCoordinator.readSync(key);

    if (cached != null && cached.isNotEmpty) {
      final decoded = BinarySerializer.decode(cached);
      if (decoded != null && decoded.fingerprint == currentFp) {
        state.hydrate(decoded.data);
        Graft.observer?.onDryHydrated(state, key: key, fromCache: true);
      } else {
        // Mismatch or corrupt: discard stale cache
        ambientStorageCoordinator.delete(key);
        state.probeWithoutCache();
        if (state.isDryEnabled) {
          Graft.observer?.onDryHydrated(state, key: key, fromCache: false);
        }
      }
    } else {
      state.probeWithoutCache();
      if (state.isDryEnabled) {
        Graft.observer?.onDryHydrated(state, key: key, fromCache: false);
      }
    }

    DryExpando.setHydrated(state);
  }

  /// Saves mutated state to L1 RAM synchronously and debounces disk write.
  @pragma('vm:prefer-inline')
  static void onStateUpdated(GraftState state) {
    if (!state.isDryEnabled || DryExpando.isInvalidated(state)) {
      return;
    }

    final dryVals = state.captureDryValues();
    final persistentProps =
        dryVals.isNotEmpty ? GraftProps.fromList(dryVals) : state.props;

    int? fp = DryExpando.getFingerprint(state);
    if (fp == null) {
      fp = SchemaFingerprint.compute(persistentProps);
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
}
