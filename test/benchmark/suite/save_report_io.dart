import 'dart:io';

void saveBenchmarkFile(String filePath, String content) {
  File(filePath).writeAsStringSync(content);
}

bool benchmarkFileExists(String path) => File(path).existsSync();

String getBenchmarkPlatform() => Platform.operatingSystemVersion;
