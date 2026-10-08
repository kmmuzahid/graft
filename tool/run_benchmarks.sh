#!/usr/bin/env bash
set -e

echo "================================================================================"
echo "  RUNNING LATE 2026 FLUTTER STATE MANAGEMENT BENCHMARK SUITE"
echo "================================================================================"

# Record Flutter environment
fvm flutter --version

# Execute full suite in test environment
fvm flutter test test/benchmark/suite/full_benchmark_suite_test.dart

echo "================================================================================"
echo "  BENCHMARK SUITE COMPLETE"
echo "  CSV generated at: benchmark_results.csv"
echo "  Report generated at: BENCHMARK_REPORT.md"
echo "================================================================================"
