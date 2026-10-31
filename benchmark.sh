#!/usr/bin/env bash
set -e

# Ensure execution from repository root regardless of current working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "  🚀 RUNNING LATE 2026 FLUTTER STATE MANAGEMENT BENCHMARK SUITE"
echo "================================================================================"

# Execute full suite in test environment
fvm flutter test test/benchmark/suite/full_benchmark_suite_test.dart

echo "================================================================================"
echo "  ✅ BENCHMARK SUITE COMPLETE"
echo "  📊 Results CSV: benchmark_results.csv"
echo "  📄 Primary Report: BENCHMARK_REPORT.md"
echo "  🌐 Cross-Platform Comparison: benchmark.md"
echo "================================================================================"

