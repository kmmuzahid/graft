/// Frame-0 persistent single value state container.
library;

import '../../core/graft_state.dart';
import '../../core/value_graft.dart';

import '../../persistence/ambient_locator.dart';
import '../../persistence/model/binary_serializer.dart';
import '../../persistence/model/schema_fingerprint.dart';

/// Single-value state container supporting Frame-0 dry persistence.
final class DryGraftValue<T> extends GraftValue<T> {
  final String _key;

  DryGraftValue(super.value, {required String key}) : _key = key;

  @override
  int get schemaVersion => 1;

  @override
  String get dryKey => _key;
}

/// Persistent [ValueGraft] that automatically hydrates on Frame 0.
class DryValueGraft<T> extends ValueGraft<T> {
  DryValueGraft(T initialValue, {required String key})
      : super.fromState(_hydrateDryValue(initialValue, key: key));

  static DryGraftValue<T> _hydrateDryValue<T>(T initialValue,
      {required String key}) {
    final state = DryGraftValue<T>(initialValue, key: key);
    final fp = SchemaFingerprint.compute(state.props,
        schemaVersion: state.schemaVersion);
    final cached = ambientStorageCoordinator.readSync(key);
    if (cached != null && cached.isNotEmpty) {
      final decoded = BinarySerializer.decode(cached);
      if (decoded != null &&
          decoded.fingerprint == fp &&
          decoded.data.isNotEmpty) {
        state.value = decoded.data[0] as T;
      }
    }
    GraftStateEngine.setDryEnabled(state, true);
    return state;
  }
}
