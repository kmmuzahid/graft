import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'benchmark/suite/benchmark_models.dart';
import 'benchmark/suite/scenario_a_micro_mutation.dart';
import 'benchmark/suite/scenario_b_rebuild_isolation.dart';
import 'benchmark/suite/scenario_c_large_list.dart';
import 'benchmark/suite/scenario_d_composite.dart';
import 'benchmark/suite/scenario_e_lifecycle.dart';

void main() {
  final collector = BenchmarkReportCollector();

  setUpAll(() {
    print('Testing UI scenarios FIRST, followed by Scenario A (Micro Mutation)...');
  });

  // 1. SCENARIO B: FINE-GRAINED REBUILD ISOLATION
  testWidgets('Scenario B: Fine-Grained Rebuild Isolation (120 Frames)', (WidgetTester tester) async {
    print('▶ Running Scenario B: Fine-Grained Rebuild Isolation (120 Frames)...');
    final statsB = await ScenarioBRebuildIsolationRunner.runAll(tester);
    for (final s in statsB) {
      collector.add(s);
      print('${s.scenario} | ${s.framework.padRight(25)} | Median: ${s.medianMs.toStringAsFixed(2)} ms');
    }
  });

  // 2. SCENARIO C: LARGE LIST PERFORMANCE
  testWidgets('Scenario C: Large List Performance (5k, 20k items)', (WidgetTester tester) async {
    print('▶ Running Scenario C: Large List Performance (5k, 20k items)...');
    final statsC = await ScenarioCLargeListRunner.runAll(tester);
    for (final s in statsC) {
      collector.add(s);
      print('${s.scenario} | ${s.framework.padRight(25)} | Median: ${s.medianMs.toStringAsFixed(2)} ms');
    }
  });

  // 3. SCENARIO D: REALISTIC COMPOSITE SCENARIOS
  testWidgets('Scenario D: Realistic Composite Scenarios', (WidgetTester tester) async {
    print('▶ Running Scenario D: Realistic Composite Scenarios...');
    final statsD = await ScenarioDCompositeRunner.runAll(tester);
    for (final s in statsD) {
      collector.add(s);
    }
  });

  // 4. SCENARIO E: LIFECYCLE & CORRECTNESS
  testWidgets('Scenario E: Lifecycle & Correctness', (WidgetTester tester) async {
    print('▶ Running Scenario E: Lifecycle & Correctness...');
    final statsE = await ScenarioELifecycleRunner.runAll(tester);
    for (final s in statsE) {
      collector.add(s);
    }
  });

  // 5. SCENARIO A: MICRO MUTATION SPEED
  test('Scenario A: Micro Mutation Speed', () {
    print('▶ Running Scenario A: Micro Mutation Speed...');
    final statsA = ScenarioAMicroMutationRunner.runAll();
    for (final s in statsA) {
      collector.add(s);
    }
  });

  tearDownAll(() {
    print('ALL SCENARIOS COMPLETED!');
  });
}
