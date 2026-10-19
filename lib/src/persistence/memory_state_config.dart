/// In-memory storage configuration for tests and ephemeral persistence.
library;

import 'dart:typed_data';
import 'state_config.dart';

/// Pure in-memory implementation of [GraftStateConfig].
///
/// Ideal for headless unit tests, fast benchmarks, and environments
/// where disk file I/O is disabled or unnecessary.
final class MemoryStateConfig implements GraftStateConfig {
  final Map<String, Uint8List> _storage = {};

  @override
  Future<Uint8List?> read(String key) async => _storage[key];

  @override
  Future<void> write(String key, Uint8List value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> close() async {
    _storage.clear();
  }

  @override
  Map<String, Uint8List> readAllSync() => Map.unmodifiable(_storage);

  /// Clears all entries from in-memory storage.
  void clear() => _storage.clear();

  /// Inspects currently stored keys.
  Iterable<String> get keys => _storage.keys;
}
