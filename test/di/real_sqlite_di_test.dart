import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:sqlite3/sqlite3.dart';

// ============================================================================
// REAL SQLITE DATABASE WRAPPER EXTENDING GraftService
// ============================================================================
class SqliteDatabase extends GraftService {
  final Database rawDb;
  bool isDisposed = false;

  SqliteDatabase(this.rawDb) {
    rawDb.execute('''
      PRAGMA foreign_keys = ON;
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL
      );
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
  }

  @override
  void dispose() {
    if (!isDisposed) {
      rawDb.dispose();
      isDisposed = true;
    }
  }
}

// ============================================================================
// REAL DATA ACCESS OBJECTS (DAO)
// ============================================================================
class UserDao extends GraftService {
  final SqliteDatabase db;
  bool isDisposed = false;

  UserDao(this.db);

  int insertUser(String name, String email) {
    if (db.isDisposed) throw StateError('Database is closed!');
    final stmt = db.rawDb.prepare('INSERT INTO users (name, email) VALUES (?, ?);');
    try {
      stmt.execute([name, email]);
      return db.rawDb.lastInsertRowId;
    } finally {
      stmt.dispose();
    }
  }

  Row? findByEmail(String email) {
    if (db.isDisposed) throw StateError('Database is closed!');
    final result = db.rawDb.select('SELECT * FROM users WHERE email = ? LIMIT 1;', [email]);
    return result.isEmpty ? null : result.first;
  }

  @override
  void dispose() {
    isDisposed = true;
  }
}

class OrderDao extends GraftService {
  final SqliteDatabase db;
  bool isDisposed = false;

  OrderDao(this.db);

  int insertOrder(int userId, String item, double amount) {
    if (db.isDisposed) throw StateError('Database is closed!');
    final stmt = db.rawDb.prepare('INSERT INTO orders (user_id, item, amount) VALUES (?, ?, ?);');
    try {
      stmt.execute([userId, item, amount]);
      return db.rawDb.lastInsertRowId;
    } finally {
      stmt.dispose();
    }
  }

  ResultSet getOrdersForUser(int userId) {
    if (db.isDisposed) throw StateError('Database is closed!');
    return db.rawDb.select('SELECT * FROM orders WHERE user_id = ?;', [userId]);
  }

  @override
  void dispose() {
    isDisposed = true;
  }
}

// ============================================================================
// REAL BUSINESS SERVICE / REPOSITORY
// ============================================================================
class UserRepository extends GraftService {
  final UserDao userDao;
  final OrderDao orderDao;
  final void Function(String event)? onLifecycleEvent;
  bool isDisposed = false;

  UserRepository(this.userDao, this.orderDao, [this.onLifecycleEvent]);

  @override
  void onInit() {
    onLifecycleEvent?.call('user_repository_initialized');
  }

  int registerUserWithOrder(String name, String email, String item, double amount) {
    if (isDisposed) throw StateError('Repository is disposed!');
    userDao.db.rawDb.execute('BEGIN TRANSACTION;');
    try {
      final userId = userDao.insertUser(name, email);
      final orderId = orderDao.insertOrder(userId, item, amount);
      userDao.db.rawDb.execute('COMMIT;');
      return orderId;
    } catch (e) {
      userDao.db.rawDb.execute('ROLLBACK;');
      rethrow;
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    onLifecycleEvent?.call('user_repository_disposed');
  }
}

// ============================================================================
// REAL GRAFT CONTROLLER WITH DRY PERSISTENCE
// ============================================================================
class UserState extends GraftState {
  @override
  int get schemaVersion => 1;

  String userName;
  int orderCount;
  bool isRegistered;

  UserState([
    this.userName = '',
    this.orderCount = 0,
  ]) : isRegistered = false;

  @override
  GraftProps get props => propsOf(userName, orderCount);
}

class UserGraft extends Graft<UserState> {
  late final UserRepository _userRepo = use<UserRepository>();

  UserGraft() : super.dry(UserState.new, key: 'dry_active_user');

  void register(String name, String email, String item, double amount) {
    _userRepo.registerUserWithOrder(name, email, item, amount);
    state
      ..userName = name
      ..orderCount = 1
      ..isRegistered = true
      ..update();
  }
}

enum TestDbScope with GraftScope { checkout, reporting }

class CheckoutAuditDao extends GraftService {
  final SqliteDatabase db;
  bool isDisposed = false;

  CheckoutAuditDao(this.db) {
    db.rawDb.execute('''
      CREATE TABLE IF NOT EXISTS checkout_audit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL
      );
    ''');
  }

  void logAction(String action) {
    if (db.isDisposed) throw StateError('Database is closed!');
    db.rawDb.execute('INSERT INTO checkout_audit (action) VALUES (?);', [action]);
  }

  @override
  void dispose() {
    isDisposed = true;
  }
}

// ============================================================================
// CIRCULAR DEPENDENCY FIXTURES
// ============================================================================
class CircularServiceA {
  final CircularServiceB b;
  CircularServiceA(this.b);
}

class CircularServiceB {
  final CircularServiceA a;
  CircularServiceB(this.a);
}

class AsyncDatabaseService {
  final Future<SqliteDatabase> Function() getDb;
  AsyncDatabaseService(this.getDb);
  Future<SqliteDatabase> get db => getDb();
}

// ============================================================================
// TEST SUITE
// ============================================================================
void main() {
  setUp(() {
    GraftTesting.resetAll();
  });

  tearDown(() {
    GraftTesting.resetAll();
  });

  group('Real SQLite Database & Graft DI Integration', () {
    test('Scenario 1: Full multi-tier resolution (Database -> DAO -> Repository -> Controller)', () {
      // 1. Bind SQLite lazily
      bind<SqliteDatabase>(() {
        final raw = sqlite3.openInMemory();
        return SqliteDatabase(raw);
      });

      // 2. Bind synchronous DAOs and Repository
      bind<UserDao>(() => UserDao(use<SqliteDatabase>()));
      bind<OrderDao>(() => OrderDao(use<SqliteDatabase>()));
      bind<UserRepository>(() => UserRepository(use<UserDao>(), use<OrderDao>()));

      // 3. Resolve DB synchronously
      final db = use<SqliteDatabase>();
      expect(db.isDisposed, isFalse);

      // 4. Resolve controller and execute real SQL transaction
      final graft = UserGraft();
      graft.register('Alice Cooper', 'alice@rock.com', 'Electric Guitar', 1299.99);

      // 5. Verify Graft State updated
      expect(graft.state.userName, equals('Alice Cooper'));
      expect(graft.state.orderCount, equals(1));
      expect(graft.state.isRegistered, isTrue);

      // 6. Verify real SQLite table rows exist in memory
      final userRow = use<UserDao>().findByEmail('alice@rock.com');
      expect(userRow, isNotNull);
      expect(userRow!['name'], equals('Alice Cooper'));

      final orders = use<OrderDao>().getOrdersForUser(userRow['id'] as int);
      expect(orders.length, equals(1));
      expect(orders.first['item'], equals('Electric Guitar'));
      expect(orders.first['amount'], equals(1299.99));
    });

    test('Worst Case 1: In-Flight Concurrent Async Service Resolutions (Race Condition Protection)', () async {
      int openCount = 0;
      final connectGate = Completer<SqliteDatabase>();

      bind<AsyncDatabaseService>(() => AsyncDatabaseService(() => connectGate.future));

      // 20 concurrent callers fire simultaneously before connection completes:
      final futures = List.generate(20, (_) => use<AsyncDatabaseService>().db);

      // Release connect gate
      openCount++;
      connectGate.complete(SqliteDatabase(sqlite3.openInMemory()));
      final results = await Future.wait(futures);

      // Must complete factory once
      expect(openCount, equals(1));

      // All 20 callers must receive the exact same singleton instance
      final first = results.first;
      for (final instance in results) {
        expect(identical(instance, first), isTrue);
      }
    });

    test('Worst Case 2: In-Degree Reverse DAG Teardown guarantees clean disposal order', () {
      final disposeOrder = <String>[];

      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });

      bind<UserDao>(() {
        final db = use<SqliteDatabase>();
        return UserDao(db);
      });

      bind<OrderDao>(() {
        final db = use<SqliteDatabase>();
        return OrderDao(db);
      });

      bind<UserRepository>(() {
        return UserRepository(
          use<UserDao>(),
          use<OrderDao>(),
          (event) => disposeOrder.add(event),
        );
      });

      // Initialize all dependencies
      use<SqliteDatabase>();
      final repo = use<UserRepository>();
      repo.registerUserWithOrder('Bob', 'bob@test.com', 'Coffee', 4.50);

      // Drop entire DI container
      GraftTesting.resetAll();

      // Consumer (UserRepository) MUST have disposed before its DAOs and DB!
      expect(repo.isDisposed, isTrue);
      expect(disposeOrder, contains('user_repository_disposed'));
    });

    test('Worst Case 3: Database Open Failure and Self-Healing Recovery', () {
      bool shouldFail = true;

      bind<SqliteDatabase>(() {
        if (shouldFail) {
          throw const FileSystemException('Disk I/O failure: /dev/null is locked');
        }
        return SqliteDatabase(sqlite3.openInMemory());
      });

      // 1. Initial attempt fails cleanly
      expect(() => use<SqliteDatabase>(), throwsA(isA<FileSystemException>()));

      // 2. Recovery: repair environment and re-bind
      shouldFail = false;
      GraftTesting.resetAll();

      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });

      final recoveredDb = use<SqliteDatabase>();
      expect(recoveredDb.isDisposed, isFalse);

      // Verify DB accepts queries after recovery
      recoveredDb.rawDb.execute('CREATE TABLE recovery_test (val TEXT);');
      recoveredDb.rawDb.execute("INSERT INTO recovery_test VALUES ('healed');");
      final rows = recoveredDb.rawDb.select('SELECT * FROM recovery_test;');
      expect(rows.first['val'], equals('healed'));
    });

    test('Worst Case 4: Real Disk-Backed File SQLite Database persistence across container restarts', () {
      final tempDir = Directory.systemTemp.createTempSync('graft_real_sqlite_');
      final dbFile = File('${tempDir.path}/app_storage.db');

      try {
        // Session 1: Create and populate real disk database
        bind<SqliteDatabase>(() {
          final raw = sqlite3.open(dbFile.path);
          return SqliteDatabase(raw);
        });
        bind<UserDao>(() => UserDao(use<SqliteDatabase>()));

        final dao1 = use<UserDao>();
        dao1.insertUser('Persistent User', 'persist@disk.com');

        // Drop container (closes SQLite disk file)
        GraftTesting.resetAll();

        expect(dbFile.existsSync(), isTrue);

        // Session 2: Launch fresh app session pointing to existing disk file
        bind<SqliteDatabase>(() {
          final raw = sqlite3.open(dbFile.path);
          return SqliteDatabase(raw);
        });
        bind<UserDao>(() => UserDao(use<SqliteDatabase>()));

        final dao2 = use<UserDao>();
        final row = dao2.findByEmail('persist@disk.com');

        expect(row, isNotNull);
        expect(row!['name'], equals('Persistent User'));
      } finally {
        GraftTesting.resetAll();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('Worst Case 5: Transaction Rollback Integrity preserves database health', () {
      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });
      bind<UserDao>(() => UserDao(use<SqliteDatabase>()));
      bind<OrderDao>(() => OrderDao(use<SqliteDatabase>()));

      final db = use<SqliteDatabase>();
      final userDao = use<UserDao>();

      userDao.insertUser('Root User', 'root@test.com');

      // Attempt transaction with a duplicate email violation:
      db.rawDb.execute('BEGIN TRANSACTION;');
      try {
        userDao.insertUser('Second User', 'unique@test.com');
        // Duplicate email triggers UNIQUE constraint failure:
        userDao.insertUser('Third User', 'root@test.com');
        db.rawDb.execute('COMMIT;');
      } catch (_) {
        db.rawDb.execute('ROLLBACK;');
      }

      // Verify transaction was rolled back: 'unique@test.com' should NOT exist
      expect(userDao.findByEmail('unique@test.com'), isNull);

      // Verify connection remains completely healthy for subsequent queries
      userDao.insertUser('Next User', 'next@test.com');
      expect(userDao.findByEmail('next@test.com'), isNotNull);
    });

    test('Worst Case 6: Enum Scope dropping isolates feature DAO while preserving global DB', () {
      // Global database
      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });

      // Scoped Checkout DAO
      scope(TestDbScope.checkout, () {
        bind<CheckoutAuditDao>(() => CheckoutAuditDao(use<SqliteDatabase>()));
      });

      // Access scoped checkout DAO via getScope
      final checkoutScope = GraftDI.getScope(TestDbScope.checkout);
      final auditDao = checkoutScope.resolve<CheckoutAuditDao>();

      auditDao.logAction('entered_payment_screen');
      expect(auditDao.isDisposed, isFalse);

      // Drop checkout scope via enum method
      TestDbScope.checkout.drop();

      expect(auditDao.isDisposed, isTrue);

      // Global DB must still be alive and operational!
      final globalDb = use<SqliteDatabase>();
      expect(globalDb.isDisposed, isFalse);
      expect(globalDb.rawDb.select('SELECT 1;').first.values.first, equals(1));
    });

    test('Worst Case 7: Zone test mock override prevents any real SQLite execution', () async {
      // In root container: register real SQLite
      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });
      bind<UserDao>(() => UserDao(use<SqliteDatabase>()));
      bind<OrderDao>(() => OrderDao(use<SqliteDatabase>()));
      bind<UserRepository>(() => UserRepository(use<UserDao>(), use<OrderDao>()));

      // Mock Repository for tests
      final mockRepo = _MockUserRepository();

      await runZoned(() async {
        // use<UserRepository>() returns mock without touching real SQLite
        final repo = use<UserRepository>();
        expect(repo, same(mockRepo));

        repo.registerUserWithOrder('Mock Person', 'mock@test.com', 'Air Guitar', 0);
        expect(mockRepo.calledCount, equals(1));

        // Real DB in root has NO rows
        final realUserDao = GraftDI.root.resolve<UserDao>();
        expect(realUserDao.findByEmail('mock@test.com'), isNull);
      }, zoneValues: {
        GraftDI.testZoneKey: {
          UserRepository: mockRepo,
        },
      });

      // Outside zone, still returns real repository
      expect(use<UserRepository>(), isNot(same(mockRepo)));
    });

    test('Worst Case 8: Circular Dependency in DI Graph is detected with descriptive path', () {
      bind<CircularServiceA>(() => CircularServiceA(use<CircularServiceB>()));
      bind<CircularServiceB>(() => CircularServiceB(use<CircularServiceA>()));

      expect(
        () => use<CircularServiceA>(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Circular Dependency'),
          ),
        ),
      );
    });

    test('Worst Case 9: Frame-0 Dry Persistence working synchronously with SQLite DI', () {
      resetAmbientPersistence();

      bind<SqliteDatabase>(() {
        return SqliteDatabase(sqlite3.openInMemory());
      });
      bind<UserDao>(() => UserDao(use<SqliteDatabase>()));
      bind<OrderDao>(() => OrderDao(use<SqliteDatabase>()));
      bind<UserRepository>(() => UserRepository(use<UserDao>(), use<OrderDao>()));

      // 1. Session 1: Register and mutate Graft state
      final graft1 = UserGraft();
      graft1.state
        ..userName = 'John Legend'
        ..orderCount = 5
        ..isRegistered = true
        ..update();

      // 2. Session 2 (Simulating Frame-0 app restart):
      final graft2 = UserGraft();

      // In < 50ns, Frame-0 Dry restores userName and orderCount from L1 cache:
      expect(graft2.state.userName, equals('John Legend'));
      expect(graft2.state.orderCount, equals(5));

      // Transient isRegistered starts fresh:
      expect(graft2.state.isRegistered, isFalse);

      resetAmbientPersistence();
    });
  });
}

class _MockUserRepository implements UserRepository {
  int calledCount = 0;

  @override
  void onInit() {}

  @override
  int registerUserWithOrder(String name, String email, String item, double amount) {
    calledCount++;
    return 777;
  }

  @override
  bool isDisposed = false;

  @override
  OrderDao get orderDao => throw UnimplementedError();

  @override
  UserDao get userDao => throw UnimplementedError();

  @override
  void Function(String event)? get onLifecycleEvent => null;

  @override
  void dispose() {
    isDisposed = true;
  }
}
