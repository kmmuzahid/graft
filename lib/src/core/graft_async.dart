/// First-class async state representation for Graft, providing pattern-matching
/// loading, data, and error state transitions.
sealed class GraftAsync<T> {
  const GraftAsync();

  /// Represents uninitialized or idle state.
  const factory GraftAsync.idle() = AsyncIdle<T>;

  /// Represents in-flight asynchronous operations.
  const factory GraftAsync.loading() = AsyncLoading<T>;

  /// Represents successful data completion.
  const factory GraftAsync.data(T data) = AsyncData<T>;

  /// Represents failure with an error and optional stack trace.
  const factory GraftAsync.error(Object error, [StackTrace? stackTrace]) =
      AsyncError<T>;

  /// Whether this instance is in the idle state.
  bool get isIdle => this is AsyncIdle<T>;

  /// Whether this instance is in-flight loading.
  bool get isLoading => this is AsyncLoading<T>;

  /// Whether this instance contains valid data.
  bool get hasData => this is AsyncData<T>;

  /// Whether this instance contains an error.
  bool get hasError => this is AsyncError<T>;

  /// Returns [data] if in the data state, otherwise null.
  T? get dataOrNull => switch (this) {
        AsyncData(:final data) => data,
        _ => null,
      };

  /// Returns [error] if in the error state, otherwise null.
  Object? get errorOrNull => switch (this) {
        AsyncError(:final error) => error,
        _ => null,
      };
}

/// Idle or initial async state.
class AsyncIdle<T> extends GraftAsync<T> {
  const AsyncIdle();

  @override
  String toString() => 'GraftAsync<$T>.idle()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AsyncIdle<T>;

  @override
  int get hashCode => T.hashCode ^ 0x1d1e;
}

/// In-flight async operation state.
class AsyncLoading<T> extends GraftAsync<T> {
  const AsyncLoading();

  @override
  String toString() => 'GraftAsync<$T>.loading()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AsyncLoading<T>;

  @override
  int get hashCode => T.hashCode ^ 0x10ad;
}

/// Successfully resolved async data state.
class AsyncData<T> extends GraftAsync<T> {
  final T data;
  const AsyncData(this.data);

  @override
  String toString() => 'GraftAsync<$T>.data($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AsyncData<T> && other.data == data);

  @override
  int get hashCode => Object.hash(T, data);
}

/// Failed async operation with error details.
class AsyncError<T> extends GraftAsync<T> {
  final Object error;
  final StackTrace? stackTrace;
  const AsyncError(this.error, [this.stackTrace]);

  @override
  String toString() => 'GraftAsync<$T>.error($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AsyncError<T> && other.error == error);

  @override
  int get hashCode => Object.hash(T, error);
}
