import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'benchmark/suite/scenario_a_micro_mutation.dart';
import 'benchmark/suite/scenario_b_rebuild_isolation.dart';

void main() {
  test('Scenario A in Isolated Heap', () async {
    final statsA = await Isolate.run(() => ScenarioAMicroMutationRunner.runAll());
    print('Scenario A finished in isolated heap: ${statsA.length} stats');
  });

  testWidgets('Scenario B (Pristine Heap)', (tester) async {
    final statsB = await ScenarioBRebuildIsolationRunner.runAll(tester);
    for (final s in statsB) {
      print('${s.scenario} | ${s.framework.padRight(25)} | Median: ${s.medianMs.toStringAsFixed(2)} ms | Mean: ${s.meanMs.toStringAsFixed(2)} ms | Min: ${s.minMs.toStringAsFixed(2)} ms');
    }
  });
}
