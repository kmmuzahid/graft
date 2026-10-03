# graft_lint

Analyzer plugin and custom lint rules for the [Graft](https://pub.dev/packages/graft) reactive state management package.

## Rules Included

| Rule | Severity | Description |
|---|---|---|
| `avoid_nested_graft_slot` | Warning | Prevents nesting `graft.slot()` inside another slot or slots engine of the same Graft instance. |
| `require_graft_route_observer` | Info | Recommends registering `GraftRouteTracker.observer` in `MaterialApp.navigatorObservers` for automatic route scoping. |

## Quick Setup

Add `custom_lint` and `graft_lint` to your `dev_dependencies`:

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  graft_lint:
    path: packages/graft_lint # Or from pub once published
```

Enable the plugin in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```
