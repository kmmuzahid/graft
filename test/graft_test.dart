import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TestState extends GraftState {
  int count;
  String text;

  TestState({this.count = 0, this.text = ''});

  @override
  List<Object?> get props => [count, text];

  @override
  void onReset() {
    count = 0;
    text = '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          text == other.text;

  @override
  int get hashCode => count.hashCode ^ text.hashCode;
}

class TestGraft extends Graft<TestState> {
  TestGraft() : super(TestState());

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void setText(String text) {
    state
      ..text = text
      ..update();
  }

  void updateSame() {
    state.update(); // No-op diff
  }

  void triggerError(String message) => addError(Exception(message));
}

class MockGraftObserver extends GraftObserver {
  int createCalls = 0;
  int changeCalls = 0;
  int errorCalls = 0;
  int disposeCalls = 0;
  GraftChange? lastChange;

  @override
  void onCreate(dynamic graft) {
    createCalls++;
  }

  @override
  void onChange(dynamic graft, GraftChange change) {
    changeCalls++;
    lastChange = change;
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    errorCalls++;
  }

  @override
  void onDispose(dynamic graft) {
    disposeCalls++;
  }
}

void main() {
  group('Graft Core Tests', () {
    late MockGraftObserver observer;

    setUp(() {
      observer = MockGraftObserver();
      Graft.observer = observer;
    });

    tearDown(() {
      Graft.observer = null;
    });

    test('initial state is set synchronously and calls onCreate', () {
      final graft = TestGraft();
      expect(graft.state, TestState(count: 0, text: ''));
      expect(observer.createCalls, 1);
      graft.dispose();
    });

    test('update notifies listener and observer', () {
      final graft = TestGraft();
      int listenerCalls = 0;
      graft.addListener(() => listenerCalls++);

      graft.increment();

      expect(graft.state.count, 1);
      expect(listenerCalls, 1);
      expect(observer.changeCalls, 1);
      expect(observer.lastChange?.previousProps, [0, '']);
      expect(observer.lastChange?.nextProps, [1, '']);

      graft.dispose();
    });

    test('updating with no field changes does not notify listeners or observer', () {
      final graft = TestGraft();
      int listenerCalls = 0;
      graft.addListener(() => listenerCalls++);

      graft.updateSame();

      expect(listenerCalls, 0);
      expect(observer.changeCalls, 0);

      graft.dispose();
    });

    test('addError notifies observer', () {
      final graft = TestGraft();
      graft.triggerError('Test error');

      expect(observer.errorCalls, 1);
      graft.dispose();
    });

    test('dispose marks isDisposed and prevents subsequent emissions', () {
      final graft = TestGraft();
      expect(graft.isDisposed, false);

      graft.dispose();
      expect(graft.isDisposed, true);
      expect(observer.disposeCalls, 1);

      // Safe update after dispose: listeners and observers are not notified
      int listenerCalls = 0;
      graft.addListener(() => listenerCalls++);
      graft.increment();
      expect(listenerCalls, 0);

      // Safe notify after dispose
      graft.notify();
      expect(listenerCalls, 0);
    });

    test('reentrant notify() during listener notification batches via microtask safely', () async {
      final graft = TestGraft();
      int listenerCalls = 0;
      bool reentrantTriggered = false;

      graft.addListener(() {
        listenerCalls++;
        if (!reentrantTriggered) {
          reentrantTriggered = true;
          // Trigger reentrant notify() synchronously while notifying
          graft.notify();
        }
      });

      graft.notify();
      // Synchronously, only the first notify() pass ran
      expect(listenerCalls, 1);

      // Allow scheduled microtask to complete
      await Future<void>.delayed(Duration.zero);

      // Second notify pass completed via microtask
      expect(listenerCalls, 2);
      graft.dispose();
    });
  });

  group('GraftRegistry Tests', () {
    setUp(() {
      GraftRegistry.reset();
    });

    tearDown(() {
      GraftRegistry.reset();
    });

    test('create throws descriptive StateError when unregistered', () {
      expect(
        () => GraftRegistry.create<TestGraft>(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Graft of type TestGraft is not registered in GraftRegistry'),
          ),
        ),
      );
    });

    test('create resolves via fallbackLocator when configured', () {
      final mockLocatorInstances = <Type, Object>{
        TestGraft: TestGraft(),
      };

      GraftRegistry.fallbackLocator = <T extends Object>() =>
          mockLocatorInstances[T] as T;

      final instance = GraftRegistry.create<TestGraft>();
      expect(instance, isA<TestGraft>());
      expect(identical(instance, mockLocatorInstances[TestGraft]), isTrue);
    });

    test('reset clears all registered factories and singletons', () {
      GraftRegistry.registerSingleton(TestGraft.new);
      expect(GraftRegistry.isRegistered<TestGraft>(), isTrue);

      GraftRegistry.reset();
      expect(GraftRegistry.isRegistered<TestGraft>(), isFalse);
    });
  });
}
