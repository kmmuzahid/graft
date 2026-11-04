/// Ambient locator for the global StorageCoordinator instance.
library;

import 'package:flutter/foundation.dart';
import 'lifecycle_observer.dart';
import 'memory_state_config.dart';
import 'dry_config.dart';
import 'storage_coordinator.dart';

StorageCoordinator? _ambientCoordinator;
bool _isCustomDryConfigured = false;
bool _suppressDryWarning = false;

/// Returns true if a custom [GraftDryConfig] was provided via [configurePersistence] or [Graft.config].
@internal
bool get isCustomDryConfigured => _isCustomDryConfigured;

/// Whether to silence the missing dryConfig warning (useful in headless tests).
@internal
bool get suppressDryWarning => _suppressDryWarning;

@internal
set suppressDryWarning(bool value) => _suppressDryWarning = value;

/// Retrieves the active [StorageCoordinator], defaulting to in-memory if unconfigured.
StorageCoordinator get ambientStorageCoordinator =>
    _ambientCoordinator ??= StorageCoordinator(MemoryStateConfig());

/// Configures global Frame-0 dry persistence storage with a custom [GraftDryConfig].
@internal
void configurePersistence(GraftDryConfig config) {
  _isCustomDryConfigured = true;
  _ambientCoordinator?.close();
  _ambientCoordinator = StorageCoordinator(config);
  GraftLifecycleObserver.instance.attach();
}

/// Resets ambient persistence coordinator (used during testing).
@internal
void resetAmbientPersistence() {
  _isCustomDryConfigured = false;
  _ambientCoordinator?.close();
  _ambientCoordinator = null;
}
