// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Linter rule that enforces `schemaVersion` and nested model `factory` overrides
/// whenever `Graft.dry` or `super.dry` is invoked.
class RequireDryContractsRule extends DartLintRule {
  const RequireDryContractsRule() : super(code: _stateCode);

  static const _stateCode = LintCode(
    name: 'require_dry_schema_version',
    problemMessage:
        'Class "{0}" is used with Graft.dry but does not override "schemaVersion".',
    correctionMessage:
        'Override "@override int get schemaVersion => 1;" to guarantee deterministic persistence and safe schema evolution across app restarts.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _modelFactoryCode = LintCode(
    name: 'require_model_factory_in_dry_state',
    problemMessage:
        'Nested GraftModel "{0}" in "{1}" must override "factory" tear-off.',
    correctionMessage:
        'Override "@override Function get factory => {0}.new;" to enable automatic Frame-0 constructor hydration.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _modelSchemaCode = LintCode(
    name: 'require_model_schema_version_in_dry_state',
    problemMessage:
        'Nested GraftModel "{0}" in "{1}" must override "schemaVersion".',
    correctionMessage:
        'Override "@override int get schemaVersion => 1;" to guarantee deterministic schema evolution.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // 1. Detect super.dry(State.new) in constructor initializer lists
    context.registry.addSuperConstructorInvocation((node) {
      if (node.constructorName?.name == 'dry') {
        final args = node.argumentList.arguments;
        if (args.isNotEmpty) {
          final firstArg = args.first;
          _checkStateFactory(firstArg, reporter);
        }
      }
    });

    // 2. Detect Graft.dry(State.new) method/instance invocations
    context.registry.addInstanceCreationExpression((node) {
      final constructorName = node.constructorName;
      if (constructorName.type.name2.lexeme == 'Graft' &&
          constructorName.name?.name == 'dry') {
        final args = node.argumentList.arguments;
        if (args.isNotEmpty) {
          final firstArg = args.first;
          _checkStateFactory(firstArg, reporter);
        }
      }
    });
  }

  void _checkStateFactory(Expression expr, ErrorReporter reporter) {
    // Handle State.new (PropertyAccess or PrefixedIdentifier)
    String? stateClassName;
    if (expr is PrefixedIdentifier && expr.identifier.name == 'new') {
      stateClassName = expr.prefix.name;
    } else if (expr is PropertyAccess && expr.propertyName.name == 'new') {
      stateClassName = expr.target?.toString();
    }

    if (stateClassName == null) return;

    // Resolve class declaration within CompilationUnit
    final unit = expr.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) return;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration &&
          declaration.name.lexeme == stateClassName) {
        _validateStateDeclaration(declaration, reporter, expr);
      }
    }
  }

  void _validateStateDeclaration(
    ClassDeclaration stateClass,
    ErrorReporter reporter,
    Expression reportTarget,
  ) {
    // Verify State overrides schemaVersion
    final hasSchemaVersion = stateClass.members
        .whereType<MethodDeclaration>()
        .any((m) => m.isGetter && m.name.lexeme == 'schemaVersion');

    if (!hasSchemaVersion) {
      reporter.atNode(
        reportTarget,
        _stateCode,
        arguments: [stateClass.name.lexeme],
      );
    }

    // Inspect fields for GraftModel subclasses
    final unit = stateClass.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) return;

    for (final field in stateClass.members.whereType<FieldDeclaration>()) {
      final typeAnnotation = field.fields.type;
      final typeName = typeAnnotation?.toString().replaceAll('?', '');
      if (typeName == null) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration &&
            declaration.name.lexeme == typeName) {
          final superclass = declaration.extendsClause?.superclass.name2.lexeme;
          if (superclass == 'GraftModel') {
            final hasFactory = declaration.members
                .whereType<MethodDeclaration>()
                .any((m) => m.isGetter && m.name.lexeme == 'factory');

            if (!hasFactory) {
              reporter.atNode(
                reportTarget,
                _modelFactoryCode,
                arguments: [typeName, stateClass.name.lexeme],
              );
            }

            final hasModelSchemaVersion = declaration.members
                .whereType<MethodDeclaration>()
                .any((m) => m.isGetter && m.name.lexeme == 'schemaVersion');

            if (!hasModelSchemaVersion) {
              reporter.atNode(
                reportTarget,
                _modelSchemaCode,
                arguments: [typeName, stateClass.name.lexeme],
              );
            }
          }
        }
      }
    }
  }
}
