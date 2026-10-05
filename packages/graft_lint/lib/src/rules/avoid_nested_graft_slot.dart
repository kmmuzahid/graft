// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidNestedGraftSlotRule extends DartLintRule {
  AvoidNestedGraftSlotRule() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_nested_graft_slot',
    problemMessage:
        'Avoid nesting "{0}" inside another "{1}". Graft slots are already isolated diffing engines.',
    correctionMessage:
        'Return regular widgets directly or use graft.compute for derived state.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _slotMethodNames = {'slot', 'slots', 'compute', 'builder', 'item', 'boundary'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;
      if (!_slotMethodNames.contains(methodName)) return;

      final targetSource = node.realTarget?.toSource();
      if (targetSource == null) return;

      // Look up AST ancestor tree to see if we are inside another slot call
      AstNode? parent = node.parent;
      while (parent != null) {
        if (parent is MethodInvocation) {
          final ancestorMethod = parent.methodName.name;
          if (_slotMethodNames.contains(ancestorMethod)) {
            final ancestorTarget = parent.realTarget?.toSource();
            if (ancestorTarget != null && ancestorTarget == targetSource) {
              reporter.atNode(
                node,
                _code,
                arguments: [
                  '$targetSource.$methodName()',
                  '$ancestorTarget.$ancestorMethod()',
                ],
              );
              break;
            }
          }
        }
        parent = parent.parent;
      }
    });
  }
}
