import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:graft_lint/graft_lint.dart';
import 'package:graft_lint/src/rules/avoid_nested_graft_slot.dart';
import 'package:graft_lint/src/rules/require_graft_route_observer.dart';
import 'package:test/test.dart';

void main() {
  group('Graft Lint Plugin Rules', () {
    test('createPlugin returns plugin with registered rules', () {
      final plugin = createPlugin();
      expect(plugin, isNotNull);
    });

    test('AvoidNestedGraftSlotRule has correct code, name, and error severity', () {
      final rule = AvoidNestedGraftSlotRule();
      expect(rule.code.name, 'avoid_nested_graft_slot');
      expect(rule.code.problemMessage, contains('Avoid nesting'));
      expect(rule.code.correctionMessage, contains('Return regular widgets'));
      expect(rule.code.errorSeverity, ErrorSeverity.ERROR);
    });

    test('RequireGraftRouteObserverRule has correct code and name', () {
      final rule = RequireGraftRouteObserverRule();
      expect(rule.code.name, 'require_graft_route_observer');
      expect(rule.code.problemMessage, contains('GraftRouteTracker.observer'));
      expect(rule.code.correctionMessage, contains('Add GraftRouteTracker.observer'));
    });
  });
}
