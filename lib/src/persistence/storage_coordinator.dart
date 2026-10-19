/// Coordinates L1 RAM cache, background debounce queues, and storage backends.
library;

import 'dart:async';
import 'dart:typed_data';
import 'debounce_queue.dart';
import 'l1_cache.dart';
import 'state_config.dart';

/// Central coordinator managing Frame-0 cache and background disk synchronization.
final class StorageCoordinator {
  final GraftStateConfig config;
  final L1Cache l1Cache = L1Cache();
  late final DebounceQueue debounceQueue;

  StorageCoordinator(this.config) {
    debounceQueue = DebounceQueue(
      onFlush: (key, value) => config.write(key, value),
    );
    // Pre-warm L1 RAM cache synchronously on Frame 0
    final preRead = config.readAllSync();
    if (preRead.isNotEmpty) {
      l1Cache.preWarm(preRead);
    }
  }

  /// Synchronously reads state binary bytes from L1 cache in < 50ns.
  @pragma('vm:prefer-inline')
  Uint8List? readSync(String key) => l1Cache.readSync(key);

  /// Writes to L1 RAM synchronously and schedules a 300ms debounced disk save.
  @pragma('vm:prefer-inline')
  void write(String key, Uint8List value) {
    l1Cache.writeSync(key, value);
    debounceQueue.enqueue(key, value);
  }

  /// Immediately purges [key] from L1 RAM, cancels pending debounces, and deletes on disk.
  void delete(String key) {
    l1Cache.deleteSync(key);
    debounceQueue.cancel(key);
    config.delete(key);
  }

  /// Invalidates and purges stored data for [key].
  void invalidate(String key) => delete(key);

  /// Invalidates and purges all keys matching [prefix] (e.g. scope-wide purge).
  void invalidatePrefix(String prefix) {
    final lower = prefix.toLowerCase();
    final toDelete = l1Cache.keys
        .where((k) => k.startsWith(prefix) || k.toLowerCase().contains(lower))
        .toList();
    for (final key in toDelete) {
      delete(key);
    }
  }

  /// Flushes pending background writes to disk.
  Future<void> flush() => debounceQueue.flush();

  /// Releases resources and closes storage backend.
  Future<void> close() async {
    await debounceQueue.flush();
    await config.close();
    l1Cache.clear();
  }
}
