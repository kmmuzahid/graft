/// Ambient locator for the global StorageCoordinator instance.
library;

import 'lifecycle_observer.dart';
import 'memory_state_config.dart';
import 'state_config.dart';
import 'storage_coordinator.dart';

StorageCoordinator? _ambientCoordinator;

/// Retrieves the active [StorageCoordinator], defaulting to in-memory if unconfigured.
StorageCoordinator get ambientStorageCoordinator =>
    _ambientCoordinator ??= StorageCoordinator(MemoryStateConfig());

/// Configures global persistence storage with a custom [GraftStateConfig].
void configurePersistence(GraftStateConfig config) {
  _ambientCoordinator?.close();
  _ambientCoordinator = StorageCoordinator(config);
  GraftLifecycleObserver.instance.attach();
}

/// Resets ambient persistence coordinator (used during testing).
void resetAmbientPersistence() {
  _ambientCoordinator?.close();
  _ambientCoordinator = null;
}
