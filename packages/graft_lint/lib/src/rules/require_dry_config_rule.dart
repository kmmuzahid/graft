// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Linter rule that encourages providing `dryConfig` when invoking `Graft.config()`.
class RequireDryConfigRule extends DartLintRule {
  const RequireDryConfigRule() : super(code: _code);

  static const _code = LintCode(
    name: 'require_dry_config',
    problemMessage:
        'Graft.config() is invoked without "dryConfig". State will only persist in ephemeral RAM for the current session.',
    correctionMessage:
        'Pass "dryConfig: FileDryConfig(storageDirectory)" so that Frame-0 dry states are saved permanently across app restarts.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'config' &&
          (node.target?.toString() == 'Graft')) {
        final hasDryConfig = node.argumentList.arguments
            .whereType<NamedExpression>()
            .any((arg) => arg.name.label.name == 'dryConfig');

        if (!hasDryConfig) {
          reporter.atNode(node.methodName, _code);
        }
      }
    });
  }
}
