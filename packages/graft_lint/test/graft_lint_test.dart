// ignore: deprecated_member_use
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:graft_lint/graft_lint.dart';
import 'package:graft_lint/src/rules/avoid_nested_graft_slot.dart';
import 'package:graft_lint/src/rules/prefer_tracked_in_graft_state.dart';
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
      // ignore: deprecated_member_use
      expect(rule.code.errorSeverity, ErrorSeverity.ERROR);
    });

    test('RequireGraftRouteObserverRule has correct code and name', () {
      final rule = RequireGraftRouteObserverRule();
      expect(rule.code.name, 'require_graft_route_observer');
      expect(rule.code.problemMessage, contains('GraftRouteTracker.observer'));
      expect(rule.code.correctionMessage, contains('Add GraftRouteTracker.observer'));
    });

    test('PreferPropsInGraftStateRule has correct code, name, and info severity', () {
      final rule = PreferPropsInGraftStateRule();
      expect(rule.code.name, 'prefer_props_in_graft_state');
      expect(rule.code.problemMessage, contains('does not override "props"'));
      expect(rule.code.correctionMessage, contains('hardware bitmask'));
      // ignore: deprecated_member_use
      expect(rule.code.errorSeverity, ErrorSeverity.INFO);
    });
  });
}
