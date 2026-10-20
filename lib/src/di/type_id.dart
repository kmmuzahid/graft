/// Monotonic integer type identifier for zero-collision flat array indexing.
library;

/// Assigns a unique, monotonic, 0-indexed integer ID to each type.
final class TypeId {
  TypeId._();

  static int _nextId = 0;
  static final Map<Type, int> _ids = {};

  /// Retrieves the monotonic integer ID assigned to type [T].
  @pragma('vm:prefer-inline')
  static int of<T>() => _ids[T] ??= _nextId++;
}
