/// Coalescing background write debounce queue for persistence.
library;

import 'dart:async';
import 'dart:typed_data';

/// Queues and coalesces rapid state writes into debounced background batches.
///
/// Ensures rapid keystrokes (e.g. typing in a form at 60fps) update
/// L1 RAM cache synchronously on every keystroke, while coalescing
/// disk writes into a single debounced 300ms I/O operation.
final class DebounceQueue {
  final Duration debounceDuration;
  final Map<String, Timer> _pendingTimers = {};
  final Map<String, Uint8List> _pendingPayloads = {};
  final Future<void> Function(String key, Uint8List value) onFlush;

  DebounceQueue({
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.onFlush,
  });

  /// Queues a write operation for [key], resetting its debounce timer.
  void enqueue(String key, Uint8List value) {
    _pendingPayloads[key] = value;
    _pendingTimers[key]?.cancel();

    _pendingTimers[key] = Timer(debounceDuration, () {
      _executeWrite(key);
    });
  }

  /// Cancels any pending write for [key].
  void cancel(String key) {
    _pendingTimers[key]?.cancel();
    _pendingTimers.remove(key);
    _pendingPayloads.remove(key);
  }

  Future<void> _executeWrite(String key) async {
    _pendingTimers.remove(key);
    final payload = _pendingPayloads.remove(key);
    if (payload != null) {
      await onFlush(key, payload);
    }
  }

  /// Immediately flushes all pending debounced writes to disk.
  Future<void> flush() async {
    final keys = _pendingPayloads.keys.toList();
    for (final key in keys) {
      _pendingTimers[key]?.cancel();
      _pendingTimers.remove(key);
      final payload = _pendingPayloads.remove(key);
      if (payload != null) {
        await onFlush(key, payload);
      }
    }
  }

  /// Clears all timers and pending payloads without writing to disk.
  void clear() {
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
    _pendingPayloads.clear();
  }

  /// Whether [key] currently has a pending write in the queue.
  bool hasPending(String key) => _pendingPayloads.containsKey(key);
}
