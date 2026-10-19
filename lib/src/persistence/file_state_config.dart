/// File-system based storage configuration for persistent state.
library;

import 'dart:io';
import 'dart:typed_data';
import 'state_config.dart';

/// File-based implementation of [GraftStateConfig] writing binary files to a directory.
final class FileStateConfig implements GraftStateConfig {
  final Directory directory;

  FileStateConfig(this.directory) {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  File _fileForKey(String key) {
    final sanitized = key.replaceAll(RegExp(r'[^\w\.-]'), '_');
    return File('${directory.path}/$sanitized.bin');
  }

  @override
  Future<Uint8List?> read(String key) async {
    final file = _fileForKey(key);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  @override
  Future<void> write(String key, Uint8List value) async {
    final file = _fileForKey(key);
    await file.writeAsBytes(value, flush: true);
  }

  @override
  Future<void> delete(String key) async {
    final file = _fileForKey(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> close() async {
    // Flush/close any pending descriptors
  }

  @override
  Map<String, Uint8List> readAllSync() {
    final result = <String, Uint8List>{};
    if (!directory.existsSync()) return result;

    final entities = directory.listSync();
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.bin')) {
        final filename = entity.uri.pathSegments.last;
        final key = filename.substring(0, filename.length - 4);
        try {
          result[key] = entity.readAsBytesSync();
        } catch (_) {
          // Ignore corrupt file on pre-read
        }
      }
    }
    return result;
  }
}
