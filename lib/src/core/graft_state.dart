import 'graft.dart';

/// Base class for domain states that enables direct cascade mutation with zero boilerplate.
///
/// ### Why extend GraftState?
/// - **Zero Boilerplate:** No immutable `copyWith` methods, no `Equatable` boilerplate, and
///   no code generation (`build_runner` is never required).
/// - **Fluent Cascade Updates:** Modify multiple fields cleanly using Dart's native cascade operator:
///   ```dart
///   state
///     ..name = 'Alice'
///     ..avatarUrl = 'https://...'
///     ..isLoading = false
///     ..update(); // Batched diffing: notifies listeners once!
///   ```
/// - **Fine-Grained Slot Diffing:** Calling [update] triggers slot diffing in `graft.column`,
///   `graft.slot`, etc. Only the specific UI slots displaying modified fields will rebuild.
/// - **Internal Binding:** Automatically linked to its owning [Graft] controller upon construction.
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = '';
///   String email = '';
///   bool isOnline = false;
/// }
///
/// class UserGraft extends Graft<UserState> {
///   UserGraft() : super(UserState());
///
///   void updateProfile({required String name, required String email}) {
///     state
///       ..name = name
///       ..email = email
///       ..update(); // Notifies listeners and diffs UI slots
///   }
/// }
/// ```
abstract class GraftState {
  Graft? _graft;

  /// Binds this state instance to its owning [Graft] controller.
  ///
  /// This method is called automatically by the [Graft] constructor and [Graft.emit].
  /// You typically do not need to call this method manually.
  void bindGraft(Graft graft) {
    _graft = graft;
  }

  /// Triggers fine-grained slot diffing and notifies all listeners of changes.
  ///
  /// ### Why call `state.update()`?
  /// Calling [update] commits in-place field mutations, notifies the global observer,
  /// and prompts reactive UI widgets (`graft.column`, `graft.slot`, etc.) to run
  /// an isolated slot diffing pass.
  ///
  /// ### Example:
  /// ```dart
  /// void rename(String newName) {
  ///   state
  ///     ..name = newName
  ///     ..update();
  /// }
  /// ```
  void update() {
    _graft?.notify();
  }
}

