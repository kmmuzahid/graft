/// Observer for automatic debounced write flushing on Flutter application lifecycle events.
library;

import 'package:flutter/widgets.dart';
import 'ambient_locator.dart';

/// Flushes pending persistence debounces to disk upon app backgrounding, suspension, or pause.
final class GraftLifecycleObserver with WidgetsBindingObserver {
  static final GraftLifecycleObserver instance = GraftLifecycleObserver._();
  GraftLifecycleObserver._();

  bool _isAttached = false;

  /// Attaches this observer to [WidgetsBinding.instance].
  ///
  /// Safe to call multiple times. Silently ignores in headless environments (e.g. pure Dart unit tests).
  void attach() {
    if (_isAttached) return;
    try {
      final binding = WidgetsBinding.instance;
      binding.addObserver(this);
      _isAttached = true;
    } catch (_) {
      // In headless unit tests or before WidgetsFlutterBinding is initialized.
    }
  }

  /// Detaches this observer from [WidgetsBinding.instance].
  void detach() {
    if (!_isAttached) return;
    try {
      WidgetsBinding.instance.removeObserver(this);
      _isAttached = false;
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state.name == 'hidden') {
      ambientStorageCoordinator.flush();
    }
  }
}
