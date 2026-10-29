import 'package:flutter/foundation.dart';
import '../core/graft.dart';
import 'graft_di.dart';

/// Type-safe factory registry for resolving, instantiating, and scoping [Graft] instances.
class GraftRegistry {
  GraftRegistry._();

  /// Internal constructor test helper.
  @visibleForTesting
  static GraftRegistry createForTest() => GraftRegistry._();

  static final Map<Type, Object Function()> _factories = {};
  static final Map<Type, Graft> _singletons = {};
  static final Set<Type> _isNewCreateDisabled = {};

  /// Optional fallback resolver (e.g. `GetIt.I<T>`).
  static T Function<T extends Object>()? fallbackLocator;

  /// Registers a factory for a given [Graft] type [T].
  /// When [allowNew] is `true` (default), the Graft is Route-Scoped.
  /// When [allowNew] is `false`, it is locked as an app-wide Global Singleton.
  static void register<T extends Graft>(
    T Function() factory, {
    bool allowNew = true,
  }) {
    _factories[T] = factory;
    if (!allowNew) {
      _isNewCreateDisabled.add(T);
    } else {
      _isNewCreateDisabled.remove(T);
      _singletons.remove(T)?.dispose();
    }
  }

  /// Registers a factory for a given [Graft] type [T] as a **Global Singleton**.
  ///
  /// ### Why register as a Singleton?
  /// Use this for state that must persist across navigation flows throughout the entire app:
  /// - Authentication sessions & user credentials
  /// - Application settings & theme preferences
  /// - Real-time WebSocket or push notification services
  ///
  /// ### Parameters:
  /// - [lazy]: If `true` (default), the instance is created lazily on first access
  ///   when `context.use<T>()` is called. If `false`, it is instantiated immediately.
  /// - A singleton is **never re-created** by `context.create<T>()` and is **never disposed** by route pops.
  ///
  /// ### Example:
  /// ```dart
  /// // Lazy singleton (instantiated on first use):
  /// GraftRegistry.registerSingleton(AuthGraft.new);
  ///
  /// // Eager singleton (instantiated immediately right now):
  /// GraftRegistry.registerSingleton(SettingsGraft.new, lazy: false);
  /// ```
  static void registerSingleton<T extends Graft>(
    T Function() factory, {
    bool lazy = true,
  }) {
    register<T>(factory, allowNew: false);
    if (!lazy) {
      getOrCreateSingleton<T>();
    }
  }

  /// Whether new instances can be created for [T]. Returns `false` if registered as singleton.
  ///
  /// Used internally by `context.use<T>()` and `context.create<T>()` to enforce singleton guarantees.
  @internal
  static bool canCreateNew<T extends Graft>() {
    return !_isNewCreateDisabled.contains(T);
  }

  /// Returns the singleton instance for [T], creating it on first access if registered lazily.
  ///
  /// Internal engine method used by `context.use<T>()`.
  @internal
  static T getOrCreateSingleton<T extends Graft>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    final instance = create<T>();
    _singletons[T] = instance;
    return instance;
  }

  /// Unregisters a factory and disposes any cached singleton for [T].
  ///
  /// Useful for modular feature unloading or dynamic testing teardowns.
  ///
  /// ### Example:
  /// ```dart
  /// GraftRegistry.unregister<UserGraft>();
  /// ```
  static void unregister<T extends Graft>() {
    _factories.remove(T);
    _isNewCreateDisabled.remove(T);
    _singletons.remove(T)?.dispose();
  }

  /// Checks if a factory for [T] is registered in [GraftRegistry].
  ///
  /// ### Example:
  /// ```dart
  /// if (!GraftRegistry.isRegistered<UserGraft>()) {
  ///   GraftRegistry.register(UserGraft.new);
  /// }
  /// ```
  static bool isRegistered<T extends Graft>() {
    return _factories.containsKey(T) || GraftDI.root.isRegistered<T>();
  }

  /// Creates a new instance of [T] using its registered factory or [fallbackLocator].
  ///
  /// Throws a clear [StateError] if [T] has not been registered and cannot be resolved.
  ///
  /// ### Example:
  /// ```dart
  /// final instance = GraftRegistry.create<UserGraft>();
  /// ```
  static T create<T extends Graft>() {
    final factory = _factories[T];
    if (factory != null) {
      return factory() as T;
    }

    if (GraftDI.root.isRegistered<T>()) {
      return GraftDI.root.resolve<T>();
    }

    if (fallbackLocator != null) {
      try {
        return fallbackLocator!<T>();
      } catch (_) {
        // Fall through to descriptive StateError
      }
    }

    throw StateError(
      'Graft of type $T is not registered in GraftRegistry.\n'
      'Please register it at app startup:\n'
      '  GraftRegistry.register<$T>($T.new);\n'
      'Then in your screen simply call:\n'
      '  context.use<$T>();',
    );
  }

  /// Clears all registered factories and disposes all active singletons.
  ///
  /// ### Why call reset?
  /// Call this inside `tearDown` or `setUp` in your test suite to ensure clean,
  /// leak-free test isolation across test cases:
  /// ```dart
  /// tearDown(() {
  ///   GraftRegistry.reset();
  /// });
  /// ```
  @visibleForTesting
  static void reset() {
    _factories.clear();
    for (final singleton in _singletons.values) {
      if (!singleton.isDisposed) {
        singleton.dispose();
      }
    }
    _singletons.clear();
    _isNewCreateDisabled.clear();
    fallbackLocator = null;
  }
}
