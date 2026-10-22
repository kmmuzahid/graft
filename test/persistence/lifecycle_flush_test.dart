import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/lifecycle_observer.dart';

class FormState extends GraftState {
  @override
  int get schemaVersion => 1;

  String text;

  FormState([this.text = 'default']);

  @override
  GraftProps get props => propsOf(text);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('graft_lifecycle_test_');
    resetAmbientPersistence();
    configurePersistence(FileStateConfig(tempDir));
  });

  tearDown(() {
    resetAmbientPersistence();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Automatic Lifecycle Flush Tests', () {
    test('immediately flushes debounced writes upon AppLifecycleState.paused without waiting 300ms', () async {
      final graft = Graft<FormState>.dry(FormState.new);
      graft.state
        ..text = 'unsaved_keystroke_50ms_ago'
        ..update();

      // At this point, the write is pending in DebounceQueue (300ms timer running)
      // The disk file does NOT yet have the updated value:
      final fileConfig = FileStateConfig(tempDir);
      final preFlushBytes = await fileConfig.read(graft.state.dryKey);
      expect(preFlushBytes, isNull);

      // Simulate OS sending AppLifecycleState.paused (e.g. user pressed home button)
      GraftLifecycleObserver.instance.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Wait a microtask for async flush
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Assert that the file is now written to disk immediately:
      final postFlushBytes = await fileConfig.read(graft.state.dryKey);
      expect(postFlushBytes, isNotNull);

      // Cold restart simulation verifies data was flushed
      resetAmbientPersistence();
      configurePersistence(FileStateConfig(tempDir));

      final restoredGraft = Graft<FormState>.dry(FormState.new);
      expect(restoredGraft.state.text, equals('unsaved_keystroke_50ms_ago'));
    });

    test('flushes debounced writes upon AppLifecycleState.inactive', () async {
      final graft = Graft<FormState>.dry(FormState.new);
      graft.state
        ..text = 'inactive_state_test'
        ..update();

      final fileConfig = FileStateConfig(tempDir);
      expect(await fileConfig.read(graft.state.dryKey), isNull);

      // Trigger inactive (e.g. app switcher or phone call incoming)
      GraftLifecycleObserver.instance.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await fileConfig.read(graft.state.dryKey), isNotNull);
    });

    test('flushes debounced writes upon AppLifecycleState.detached', () async {
      final graft = Graft<FormState>.dry(FormState.new);
      graft.state
        ..text = 'detached_state_test'
        ..update();

      final fileConfig = FileStateConfig(tempDir);
      expect(await fileConfig.read(graft.state.dryKey), isNull);

      // Trigger detached
      GraftLifecycleObserver.instance.didChangeAppLifecycleState(AppLifecycleState.detached);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await fileConfig.read(graft.state.dryKey), isNotNull);
    });
  });
}
