/// Architectural base class for background business logic, repositories, and services in Graft DI.
library;

/// Base contract for domain services, repositories, and data sources within Graft DI.
///
/// Classes extending or implementing [GraftService] receive automatic lifecycle hooks:
/// - [onInit]: Executed immediately after constructor instantiation.
/// - [dispose]: Executed in reverse topological DAG order when their enclosing scope drops,
///   guaranteeing that consumers dispose *before* underlying connections or databases.
abstract class GraftService implements GraftInitializable {
  /// Initialization hook invoked immediately after constructor execution.
  @override
  void onInit() {}

  /// Teardown hook invoked in reverse topological DAG order when this service's scope drops.
  void dispose() {}
}

/// Optional initialization contract for dependencies.
///
/// If a dependency implements [GraftInitializable], its [onInit] callback
/// is invoked immediately after instantiation and registration.
abstract interface class GraftInitializable {
  /// Initialization hook invoked immediately after constructor execution.
  void onInit();
}

