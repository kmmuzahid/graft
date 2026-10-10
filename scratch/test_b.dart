import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import '../test/benchmark/suite/benchmark_models.dart';
import '../test/benchmark/suite/tracking_widget.dart';
import '../test/benchmark/suite/scenario_b_rebuild_isolation.dart';

void main() {
  testWidgets('Bench B leaf slot vs slots', (tester) async {
    final stats = await ScenarioBRebuildIsolationRunner.runColumnRebuild(
      tester: tester,
      slotCount: 10,
      scenarioName: 'B1_10_slot',
    );
    for (final s in stats) {
      print('${s.framework}: mean=${s.meanMs.toStringAsFixed(2)}ms median=${s.medianMs.toStringAsFixed(2)}ms dynamic=${s.targetRebuilds} static=${s.staticRebuilds}');
    }
  });
}
