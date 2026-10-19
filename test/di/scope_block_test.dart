import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

enum TestScope { orders, session }

class OrderRepo implements Disposable {
  bool isDisposed = false;
  @override
  void dispose() => isDisposed = true;
}

class SessionService {}

void main() {
  setUp(() {
    GraftDI.reset();
  });

  group('Scope Block & Enum Tests', () {
    test('bind outside scope block registers into immortal root scope', () {
      bind(SessionService.new);
      final session = use<SessionService>();
      expect(session, isA<SessionService>());
    });

    test('scope block registers into developer-defined enum scope', () {
      scope(TestScope.orders, () {
        bind(OrderRepo.new);
      });

      final orderScope = GraftDI.getScope(TestScope.orders);
      expect(orderScope.isRegistered<OrderRepo>(), isTrue);

      final repo = orderScope.resolve<OrderRepo>();
      expect(repo, isA<OrderRepo>());

      // Dropping via enum extension
      TestScope.orders.drop();
      expect(repo.isDisposed, isTrue);
    });
  });
}
