#!/usr/bin/env bash
set -e

# Ensure execution from repository root regardless of current working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if command -v fvm &> /dev/null && [ -d ".fvm" ]; then
  FLUTTER_BIN="fvm flutter"
  DART_BIN="fvm dart"
else
  FLUTTER_BIN="flutter"
  DART_BIN="dart"
fi

echo "================================================================================"
echo "  RUNNING GRAFT COMPREHENSIVE TEST SUITE & REPORT GENERATOR"
echo "================================================================================"

# Record Flutter environment
$FLUTTER_BIN --version

echo ""
echo "▶ Running static analysis (flutter analyze)..."
$FLUTTER_BIN analyze --no-pub

echo ""
echo "▶ Executing test suite and generating TEST_REPORT.md..."
if [ $# -eq 0 ]; then
  $FLUTTER_BIN test --reporter json | $DART_BIN run tool/generate_test_report.dart
else
  $FLUTTER_BIN test "$@" --reporter json | $DART_BIN run tool/generate_test_report.dart
fi

