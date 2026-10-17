import 'package:flutter/foundation.dart';

void saveBenchmarkFile(String filePath, String content) {
  // File writing is not available in browser sandbox
  debugPrint('[WEB BENCHMARK OUTPUT: $filePath]');
}

bool benchmarkFileExists(String path) => true;

String getBenchmarkPlatform() => 'Web (Chromium Engine / Web JS)';
