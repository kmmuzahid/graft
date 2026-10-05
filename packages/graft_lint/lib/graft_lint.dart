import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/rules/avoid_nested_graft_slot.dart';
import 'src/rules/prefer_tracked_in_graft_state.dart';
import 'src/rules/require_graft_route_observer.dart';

/// Entrypoint for the Graft custom lint plugin.
PluginBase createPlugin() => _GraftLinter();

class _GraftLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidNestedGraftSlotRule(),
        PreferPropsInGraftStateRule(),
        RequireGraftRouteObserverRule(),
      ];
}
