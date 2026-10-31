import 'dart:math' as math;
import 'cross_platform_report_generator.dart';
import 'save_report.dart';
import 'scenario_descriptions.dart';

/// Represents the statistical summary of multiple measured runs for a benchmark scenario.
class BenchmarkStats {
  final String scenario;
  final String framework;
  final List<double> samplesMs; // In milliseconds
  final int targetRebuilds;
  final int staticRebuilds;
  final int allocatedObjects;
  final int glitchesDetected;
  final int wastedNotifications;
  final int resourceLeaks;
  final bool isPassed;
  final String failureReason;
  final String notes;

  BenchmarkStats({
    required this.scenario,
    required this.framework,
    required this.samplesMs,
    this.targetRebuilds = 0,
    this.staticRebuilds = 0,
    this.allocatedObjects = 0,
    this.glitchesDetected = 0,
    this.wastedNotifications = 0,
    this.resourceLeaks = 0,
    this.isPassed = true,
    this.failureReason = '',
    this.notes = '',
  });

  int get count => samplesMs.length;

  double get meanMs {
    if (samplesMs.isEmpty) return 0.0;
    return samplesMs.reduce((a, b) => a + b) / samplesMs.length;
  }

  double get medianMs {
    if (samplesMs.isEmpty) return 0.0;
    final sorted = List<double>.from(samplesMs)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  double get minMs {
    if (samplesMs.isEmpty) return 0.0;
    return samplesMs.reduce(math.min);
  }

  double get maxMs {
    if (samplesMs.isEmpty) return 0.0;
    return samplesMs.reduce(math.max);
  }

  double get p95Ms {
    if (samplesMs.isEmpty) return 0.0;
    final sorted = List<double>.from(samplesMs)..sort();
    final index = (0.95 * (sorted.length - 1)).round();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  double get stdDevMs {
    if (samplesMs.length <= 1) return 0.0;
    final mean = meanMs;
    final sumSquares = samplesMs.fold<double>(
      0.0,
      (sum, val) => sum + (val - mean) * (val - mean),
    );
    return math.sqrt(sumSquares / (samplesMs.length - 1));
  }

  double get rebuildEfficiency {
    final total = targetRebuilds + staticRebuilds;
    if (total == 0) return 100.0;
    return (targetRebuilds / total) * 100.0;
  }

  double get wastedRebuildRate {
    final total = targetRebuilds + staticRebuilds;
    if (total == 0) return 0.0;
    return (staticRebuilds / total) * 100.0;
  }
}

/// Central collector for benchmark results across all scenarios and frameworks.
class BenchmarkReportCollector {
  final List<BenchmarkStats> results = [];

  void add(BenchmarkStats stat) {
    results.add(stat);
  }

  /// Exports all collected results to CSV format.
  String toCsv() {
    final sb = StringBuffer();
    sb.writeln(
      'Scenario,Framework,Samples,Mean (ms),Median (ms),p95 (ms),Min (ms),Max (ms),StdDev (ms),'
      'Target Rebuilds,Static Rebuilds,Rebuild Efficiency (%),Glitches,Wasted Notifications,Resource Leaks,Status,Allocations,Notes',
    );
    final sorted = List<BenchmarkStats>.from(results)
      ..sort((a, b) {
        final c = a.scenario.compareTo(b.scenario);
        if (c != 0) return c;
        return a.meanMs.compareTo(b.meanMs);
      });
    for (final r in sorted) {
      sb.writeln(
        '"${r.scenario}","${r.framework}",${r.count},'
        '${r.meanMs.toStringAsFixed(3)},${r.medianMs.toStringAsFixed(3)},${r.p95Ms.toStringAsFixed(3)},'
        '${r.minMs.toStringAsFixed(3)},${r.maxMs.toStringAsFixed(3)},${r.stdDevMs.toStringAsFixed(3)},'
        '${r.targetRebuilds},${r.staticRebuilds},${r.rebuildEfficiency.toStringAsFixed(1)}%,'
        '${r.glitchesDetected},${r.wastedNotifications},${r.resourceLeaks},'
        '"${r.isPassed ? "PASSED" : "FAILED/DEGRADED"}",${r.allocatedObjects},"${r.notes}"',
      );
    }
    return sb.toString();
  }

  /// Saves the results to CSV file.
  void saveCsv(String filePath) {
    saveBenchmarkFile(filePath, toCsv());
  }

  /// Generates the comprehensive Markdown report.
  String toMarkdownReport({
    required String flutterVersion,
    required String dartVersion,
    required String platform,
  }) {
    return CrossPlatformReportGenerator.generate(
      nativeResults: results,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      platform: platform,
    );
  }

  /// Saves the report to Markdown file.
  void saveMarkdown(String filePath, {
    required String flutterVersion,
    required String dartVersion,
    required String platform,
  }) {
    saveBenchmarkFile(
      filePath,
      toMarkdownReport(
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
        platform: platform,
      ),
    );
  }
}
