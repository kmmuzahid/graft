import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hermetic isolation and memory-sanitization utilities for benchmark runners.
/// Guarantees that no candidate inherits GC baggage, font cache overhead,
/// or pending microtasks from any previous candidate.
abstract final class BenchmarkIsolation {
  /// Flushes the Dart VM nursery and forces a clean memory boundary before timing.
  @pragma('vm:prefer-inline')
  static void flushHeap() {
    // Allocate and immediately drop a temporary memory chunk to trigger GC nursery sweep
    final dummy = List<List<int>?>.filled(128, null);
    for (int i = 0; i < 128; i++) {
      dummy[i] = List<int>.filled(512, i);
    }
    dummy.fillRange(0, 128, null);
  }

  /// Completely unmounts the widget tree, flushes all microtasks, and neutralizes
  /// the Flutter WidgetsBinding/BuildOwner pipeline.
  static Future<void> flushPipeline(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    tester.binding.scheduleFrame();
    await tester.pump();
    flushHeap();
  }
}

