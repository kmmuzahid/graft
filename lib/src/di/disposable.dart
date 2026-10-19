/// Lifecycle contracts for managed dependencies within Graft DI.
library;

/// Contract for domain services or repositories that require teardown.
///
/// When a scope drops, all registered instances implementing [Disposable]
/// are automatically closed in reverse topological DAG order, ensuring
/// that consumers dispose *before* underlying databases or network clients.
abstract interface class Disposable {
  /// Releases resources, stream subscriptions, or file/database handles.
  void dispose();
}

/// Optional initialization contract for dependencies.
///
/// If a dependency implements [GraftInitializable], its [onInit] callback
/// is invoked immediately after instantiation and registration.
abstract interface class GraftInitializable {
  /// Initialization hook invoked immediately after constructor execution.
  void onInit();
}
