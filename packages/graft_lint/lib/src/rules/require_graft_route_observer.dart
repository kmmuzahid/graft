// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class RequireGraftRouteObserverRule extends DartLintRule {
  RequireGraftRouteObserverRule() : super(code: _code);

  static const _code = LintCode(
    name: 'require_graft_route_observer',
    problemMessage:
        'MaterialApp is missing GraftRouteTracker.observer in navigatorObservers.',
    correctionMessage:
        'Add GraftRouteTracker.observer to navigatorObservers: [GraftRouteTracker.observer] to enable automatic route-scoped lifecycle disposal.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name2.lexeme;
      if (typeName != 'MaterialApp' && typeName != 'CupertinoApp') {
        return;
      }

      final navigatorObserversArg = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((arg) => arg.name.label.name == 'navigatorObservers')
          .firstOrNull;

      if (navigatorObserversArg == null) {
        reporter.atNode(node.constructorName, _code);
        return;
      }

      final expression = navigatorObserversArg.expression;
      if (expression is ListLiteral) {
        final hasTracker = expression.elements.any((element) {
          final source = element.toSource();
          return source.contains('GraftRouteTracker.observer') ||
              source.contains('routeObserver');
        });
        if (!hasTracker) {
          reporter.atNode(navigatorObserversArg, _code);
        }
      }
    });
  }
}
