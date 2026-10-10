import 'graft.dart';
import 'graft_state.dart';

/// Single-value state container that adapts primitive types (`int`, `bool`, `String`)
/// or enums into [GraftState].
class GraftValue<T> extends GraftState {
  /// The underlying value.
  T value;

  /// Creates a [GraftValue] holding [value].
  GraftValue(this.value);

  @override
  GraftProps get props => propsOf(value);

  @override
  String toString() => value.toString();
}

/// A specialized [Graft] for managing single primitive, enum, or standalone values
/// without needing to define a separate state class.
///
/// ### Why use ValueGraft?
/// - **Zero State Class:** Ideal when you only need to track a single `int`, `bool`, `String`, or `enum`.
/// - **Direct Mutation:** Mutate with `value++` or `value = newValue` without writing `state..update()`.
/// - **Native UI Interop:** Works seamlessly with `graft.slot((val) => Text('$val'))`.
/// - **Per-Item Micro-State:** Wrap independent cell states in `ListView.builder` (e.g. `item.isLiked.slot(...)`) for zero parent rebuilds.
/// - **Automatic Route Lifecycle:** Inherited and auto-disposed across the navigation stack just like standard [Graft].
///
/// ### Example:
/// ```dart
/// // 1. Counter (int)
/// class CounterGraft extends ValueGraft<int> {
///   CounterGraft() : super(0);
///
///   void increment() => value++;
///   void decrement() => value--;
/// }
///
/// // 2. Theme Mode (enum)
/// class ThemeGraft extends ValueGraft<ThemeMode> {
///   ThemeGraft() : super(ThemeMode.system);
///
///   void setMode(ThemeMode mode) => value = mode;
/// }
///
/// // 3. Search Query (String)
/// class SearchGraft extends ValueGraft<String> {
///   SearchGraft() : super('');
///
///   void onQueryChanged(String query) => value = query;
/// }
/// ```
class ValueGraft<T> extends Graft<GraftValue<T>> {
  /// Creates a [ValueGraft] initialized with [initialValue].
  ValueGraft(T initialValue) : super(GraftValue<T>(initialValue));

  /// The current primitive value.
  T get value => state.value;

  /// Updates the value and triggers fine-grained reactive rebuilds.
  ///
  /// If [newValue] is equal to current [value], this operation is a no-op.
  set value(T newValue) {
    if (state.value == newValue) return;
    state.value = newValue;
    state.update();
  }
}
