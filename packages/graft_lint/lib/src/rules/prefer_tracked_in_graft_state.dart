// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Linter rule that encourages overriding `props` in subclasses of `GraftState`.
///
/// Overriding `GraftProps get props => propsOf(...)` allows Graft to compute
/// an unbounded dirty bitmask in CPU registers and achieve 0 GC heap allocations during diff passes.
class PreferPropsInGraftStateRule extends DartLintRule {
  PreferPropsInGraftStateRule() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_props_in_graft_state',
    problemMessage:
        'Class "{0}" extends GraftState with domain fields but does not override "props".',
    correctionMessage:
        'Override "GraftProps get props => propsOf(...);" to enable 1-cycle hardware bitmask diffing and 0 GC heap allocations.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      // Ignore abstract classes
      if (node.abstractKeyword != null) return;

      final superclass = node.extendsClause?.superclass.name2.lexeme;
      if (superclass != 'GraftState') return;

      // Check if class declares non-static instance fields
      final hasInstanceFields = node.members
          .whereType<FieldDeclaration>()
          .any((f) => !f.isStatic);

      if (!hasInstanceFields) return;

      // Check if class overrides getter 'props'
      final hasPropsGetter = node.members
          .whereType<MethodDeclaration>()
          .any((m) => m.isGetter && m.name.lexeme == 'props');

      if (!hasPropsGetter) {
        reporter.atToken(node.name, _code, arguments: [node.name.lexeme]);
      }
    });
  }
}

