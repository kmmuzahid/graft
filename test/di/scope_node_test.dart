import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/di/disposable.dart';
import 'package:graft/src/di/scope_node.dart';
import 'package:graft/src/di/scope_tier.dart';

class Database implements Disposable {
  final void Function()? onDispose;
  Database([this.onDispose]);
  bool isDisposed = false;
  @override
  void dispose() {
    isDisposed = true;
    onDispose?.call();
  }
}

class Repo implements Disposable {
  final Database db;
  final void Function()? onDispose;
  Repo(this.db, [this.onDispose]);
  bool isDisposed = false;
  @override
  void dispose() {
    isDisposed = true;
    onDispose?.call();
  }
}

class TransientService {}

void main() {
  group('ScopeNode Tests', () {
    test('resolves and caches singleton instances in flat array', () {
      final root = ScopeNode(tier: ScopeTier.root);
      int counter = 0;
      root.bind<Database>(() {
        counter++;
        return Database();
      }, singleton: true);

      final db1 = root.resolve<Database>();
      final db2 = root.resolve<Database>();

      expect(identical(db1, db2), isTrue);
      expect(counter, equals(1));
    });

    test('creates fresh instances for non-singleton bindings', () {
      final root = ScopeNode(tier: ScopeTier.root);
      root.bind<TransientService>(TransientService.new, singleton: false);

      final s1 = root.resolve<TransientService>();
      final s2 = root.resolve<TransientService>();

      expect(identical(s1, s2), isFalse);
    });

    test('falls back to parent scope for unregistered types', () {
      final root = ScopeNode(tier: ScopeTier.root);
      root.bind<Database>(Database.new);

      final child = ScopeNode(parent: root);
      final resolved = child.resolve<Database>();

      expect(resolved, isA<Database>());
      expect(identical(resolved, root.resolve<Database>()), isTrue);
    });

    test('reverse DAG teardown disposes consumers before dependencies', () {
      final root = ScopeNode(tier: ScopeTier.root);
      final disposeOrder = <String>[];

      root.bind<Database>(() => Database(() => disposeOrder.add('db')));
      root.bind<Repo>(() {
        final d = root.resolve<Database>();
        return Repo(d, () => disposeOrder.add('repo'));
      });

      // Trigger resolution so DAG dependency is recorded
      final resolvedRepo = root.resolve<Repo>();
      final resolvedDb = root.resolve<Database>();

      // Drop scope
      root.drop();

      expect(resolvedRepo.isDisposed, isTrue);
      expect(resolvedDb.isDisposed, isTrue);
      expect(disposeOrder, equals(['repo', 'db']));
    });

    test('throws StateError for unregistered type', () {
      final root = ScopeNode(tier: ScopeTier.root);
      expect(() => root.resolve<Database>(), throwsStateError);
    });
  });
}
