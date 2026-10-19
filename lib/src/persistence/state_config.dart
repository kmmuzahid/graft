/// Storage configuration contract for Graft Frame-0 persistence.
library;

import 'dart:typed_data';

/// Abstract contract defining storage I/O operations for persisted state.
abstract interface class GraftStateConfig {
  /// Reads stored binary data by [key] asynchronously.
  Future<Uint8List?> read(String key);

  /// Persists [value] under [key] asynchronously.
  Future<void> write(String key, Uint8List value);

  /// Deletes stored data associated with [key].
  Future<void> delete(String key);

  /// Flushes pending I/O and releases open file handles.
  Future<void> close();

  /// Synchronously pre-reads all stored entries to hydrate L1 RAM on Frame 0.
  Map<String, Uint8List> readAllSync();
}
