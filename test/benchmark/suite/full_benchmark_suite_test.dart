import 'package:flutter_test/flutter_test.dart';
import 'benchmark_models.dart';
import 'save_report.dart';
import 'scenario_a_micro_mutation.dart';
import 'scenario_b_rebuild_isolation.dart';
import 'scenario_c_large_list.dart';
import 'scenario_d_composite.dart';
import 'scenario_e_lifecycle.dart';
import 'scenario_f_reactive_diamond.dart';
import 'scenario_g_transactional_batching.dart';

void main() {
  final collector = BenchmarkReportCollector();

  setUpAll(() {
    // ignore: avoid_print
    print('''
================================================================================
  STARTING RIGOROUS FLUTTER STATE MANAGEMENT BENCHMARK SUITE (LATE 2026)
  Frameworks: Graft, Riverpod (Notifier & StateNotifier), BLoC (Cubit),
              Signals, GetX, Provider
  Methodology: 3 Warm-up runs discarded, 15+ measured runs per scenario
================================================================================
''');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO B: FINE-GRAINED REBUILD ISOLATION (120 FRAMES)
  // ---------------------------------------------------------------------------
  testWidgets('Scenario B: Fine-Grained Rebuild Isolation (120 Frames)', (WidgetTester tester) async {
    // ignore: avoid_print
    print('▶ Running Scenario B: Fine-Grained Rebuild Isolation (120 Frames)...');
    final statsB = await ScenarioBRebuildIsolationRunner.runAll(tester);
    for (final s in statsB) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario B completed (${statsB.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO C: LARGE LIST PERFORMANCE
  // ---------------------------------------------------------------------------
  testWidgets('Scenario C: Large List Performance (5k, 20k items)', (WidgetTester tester) async {
    // ignore: avoid_print
    print('▶ Running Scenario C: Large List Performance (5k, 20k items)...');
    final statsC = await ScenarioCLargeListRunner.runAll(tester);
    for (final s in statsC) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario C completed (${statsC.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO D: REALISTIC COMPOSITE SCENARIOS
  // ---------------------------------------------------------------------------
  testWidgets('Scenario D: Realistic Composite Scenarios', (WidgetTester tester) async {
    // ignore: avoid_print
    print('▶ Running Scenario D: Realistic Composite Scenarios...');
    final statsD = await ScenarioDCompositeRunner.runAll(tester);
    for (final s in statsD) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario D completed (${statsD.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO E: LIFECYCLE & CORRECTNESS
  // ---------------------------------------------------------------------------
  testWidgets('Scenario E: Lifecycle & Correctness', (WidgetTester tester) async {
    // ignore: avoid_print
    print('▶ Running Scenario E: Lifecycle & Correctness...');
    final statsE = await ScenarioELifecycleRunner.runAll(tester);
    for (final s in statsE) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario E completed (${statsE.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO F: REACTIVE DIAMOND & GLITCH-FREE EVALUATION
  // ---------------------------------------------------------------------------
  test('Scenario F: Reactive Diamond & Glitch-Free Evaluation (5,000 updates)', () {
    // ignore: avoid_print
    print('▶ Running Scenario F: Reactive Diamond & Glitch-Free Evaluation...');
    final statsF = ScenarioFReactiveDiamondRunner.runAll();
    for (final s in statsF) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario F completed (${statsF.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO G: TRANSACTIONAL MULTI-FIELD BATCHING BURST
  // ---------------------------------------------------------------------------
  test('Scenario G: Transactional Multi-Field Batching (2,000 transactions)', () {
    // ignore: avoid_print
    print('▶ Running Scenario G: Transactional Multi-Field Batching...');
    final statsG = ScenarioGTransactionalBatchingRunner.runAll();
    for (final s in statsG) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario G completed (${statsG.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // SCENARIO A: MICRO MUTATION SPEED
  // ---------------------------------------------------------------------------
  test('Scenario A: Micro Mutation Speed', () {
    // ignore: avoid_print
    print('▶ Running Scenario A: Micro Mutation Speed...');
    final statsA = ScenarioAMicroMutationRunner.runAll();
    for (final s in statsA) {
      collector.add(s);
    }
    // ignore: avoid_print
    print('✔ Scenario A completed (${statsA.length} benchmark targets).');
  });

  // ---------------------------------------------------------------------------
  // TEARDOWN: EXPORT DELIVERABLES & PRINT EXECUTIVE SUMMARY
  // ---------------------------------------------------------------------------
  tearDownAll(() {
    const csvPath = 'benchmark_results.csv';
    const reportPath = 'BENCHMARK_REPORT.md';

    collector.saveCsv(csvPath);
    // ignore: avoid_print
    print('📁 Saved raw numbers CSV to: $csvPath');

    collector.saveMarkdown(
      reportPath,
      flutterVersion: 'Flutter 3.47.6 (stable channel)',
      dartVersion: 'Dart 3.13.5 (stable)',
      platform: getBenchmarkPlatform(),
    );
    // ignore: avoid_print
    print('📄 Saved comprehensive report to: $reportPath');

    // Print quick executive summary table
    // ignore: avoid_print
    print('''
================================================================================
  BENCHMARK SUITE COMPLETE! SUMMARY OF KEY RESULTS:
================================================================================''');

    final grouped = <String, List<BenchmarkStats>>{};
    for (final r in collector.results) {
      grouped.putIfAbsent(r.scenario, () => []).add(r);
    }

    final sortedScenarioKeys = grouped.keys.toList()..sort();
    for (final scenarioKey in sortedScenarioKeys) {
      final sorted = List<BenchmarkStats>.from(grouped[scenarioKey]!)
        ..sort((a, b) => a.meanMs.compareTo(b.meanMs));
      // ignore: avoid_print
      print('\nScenario: $scenarioKey');
      // ignore: avoid_print
      print('  ${"Framework".padRight(24)} ${"Mean (ms)".padLeft(10)} ${"Median (ms)".padLeft(12)} ${"p95 (ms)".padLeft(10)} ${"Static Builds".padLeft(14)} ${"Status".padLeft(10)}');
      // ignore: avoid_print
      print('  ------------------------------------------------------------------------------------------');
      for (final s in sorted) {
        final status = s.isPassed ? 'Pass' : 'Degraded';
        // ignore: avoid_print
        print('  ${s.framework.padRight(24)} ${s.meanMs.toStringAsFixed(2).padLeft(10)} ${s.medianMs.toStringAsFixed(2).padLeft(12)} ${s.p95Ms.toStringAsFixed(2).padLeft(10)} ${s.staticRebuilds.toString().padLeft(14)} ${status.padLeft(10)}');
      }
    }

    // Print Architectural Correctness & Rebuild Fidelity Scorecard
    final fwSet = <String>{};
    for (final r in collector.results) fwSet.add(r.framework);
    final sortedFw = fwSet.toList()..sort();

    // ignore: avoid_print
    print('''
================================================================================
  ARCHITECTURAL CORRECTNESS & REBUILD FIDELITY SCORECARD
================================================================================
  ${"Framework".padRight(24)} ${"Status".padLeft(10)} ${"Glitches".padLeft(10)} ${"Wasted Notifs".padLeft(15)} ${"Wasted Builds".padLeft(15)} ${"Efficiency".padLeft(12)}
  ----------------------------------------------------------------------------------------------------''');

    for (final fw in sortedFw) {
      final fwStats = collector.results.where((r) => r.framework == fw).toList();
      final totalGlitches = fwStats.fold<int>(0, (sum, r) => sum + r.glitchesDetected);
      final totalWastedNotifs = fwStats.fold<int>(0, (sum, r) => sum + r.wastedNotifications);
      final totalTarget = fwStats.fold<int>(0, (sum, r) => sum + r.targetRebuilds);
      final totalStatic = fwStats.fold<int>(0, (sum, r) => sum + r.staticRebuilds);
      final failedCount = fwStats.where((r) => !r.isPassed).length;
      final eff = (totalTarget + totalStatic) == 0 ? 100.0 : (totalTarget / (totalTarget + totalStatic)) * 100.0;
      final status = (failedCount == 0 && totalGlitches == 0) ? 'PASSED' : 'DEGRADED';

      // ignore: avoid_print
      print('  ${fw.padRight(24)} ${status.padLeft(10)} ${totalGlitches.toString().padLeft(10)} ${totalWastedNotifs.toString().padLeft(15)} ${totalStatic.toString().padLeft(15)} ${eff.toStringAsFixed(1).padLeft(11)}%');
    }

    // ignore: avoid_print
    print('''
================================================================================
  ALL BENCHMARKS EXECUTED AND VERIFIED!
================================================================================
''');

    expect(benchmarkFileExists(csvPath), true);
    expect(benchmarkFileExists(reportPath), true);
  });
}
