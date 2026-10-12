import 'package:flutter_test/flutter_test.dart';
import 'benchmark/suite/scenario_b_rebuild_isolation.dart';

void main() {
  testWidgets('Standalone Scenario B Test', (tester) async {
    final stats = await ScenarioBRebuildIsolationRunner.runAll(tester);
    for (final s in stats) {
      print('${s.scenario} | ${s.framework.padRight(25)} | Median: ${s.medianMs.toStringAsFixed(2)} ms | Mean: ${s.meanMs.toStringAsFixed(2)} ms | Min: ${s.minMs.toStringAsFixed(2)} ms');
    }
  });
}
