import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

class AsyncDbService {
  final Completer<String> _completer = Completer<String>();

  Future<String> get connection => _completer.future;

  void initialize(String connStr) {
    _completer.complete(connStr);
  }
}

class UserRepository {
  final AsyncDbService dbService;
  UserRepository(this.dbService);

  Future<String> getUser(String id) async {
    final conn = await dbService.connection;
    return '$conn:User_$id';
  }
}

class TransientCounter {
  static int counter = 0;
  final int id;
  TransientCounter() : id = ++counter;
}

void main() {
  setUp(() {
    GraftTesting.resetAll();
    TransientCounter.counter = 0;
  });

  tearDown(() {
    GraftTesting.resetAll();
  });

  group('Uniform DI Engine Tests', () {
    test('100% lazy: bind stores function pointer and never instantiates until use()', () {
      int factoryExecutions = 0;

      bind<AsyncDbService>(() {
        factoryExecutions++;
        return AsyncDbService();
      });

      // No instantiation yet
      expect(factoryExecutions, 0);

      // First use instantiates
      final db = use<AsyncDbService>();
      expect(factoryExecutions, 1);
      expect(db, isA<AsyncDbService>());

      // Subsequent use returns singleton without re-running factory
      final db2 = use<AsyncDbService>();
      expect(factoryExecutions, 1);
      expect(identical(db, db2), isTrue);
    });

    test('Async service pattern: service encapsulates its own Future safely', () async {
      bind<AsyncDbService>(() => AsyncDbService());
      bind<UserRepository>(() => UserRepository(use<AsyncDbService>()));

      final repo = use<UserRepository>();
      final db = use<AsyncDbService>();

      // Initialize database asynchronously
      db.initialize('postgres://localhost:5432/app');

      final user = await repo.getUser('42');
      expect(user, 'postgres://localhost:5432/app:User_42');
    });

    test('Non-singleton transient bindings create fresh instances on each use()', () {
      bind<TransientCounter>(() => TransientCounter(), singleton: false);

      final c1 = use<TransientCounter>();
      final c2 = use<TransientCounter>();
      final c3 = use<TransientCounter>();

      expect(c1.id, 1);
      expect(c2.id, 2);
      expect(c3.id, 3);
      expect(identical(c1, c2), isFalse);
    });
  });
}

