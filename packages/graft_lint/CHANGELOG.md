# Changelog

All notable changes to `graft_lint` will be documented in this file.

## 0.1.1-alpha.1

* **Breaking (Diagnostics):** Promoted `avoid_nested_graft_slot` rule severity from `Warning` to `Error` (`ErrorSeverity.ERROR`) by default.
* Fixed ambiguous import collision for `LintCode` between `analyzer` and `custom_lint_builder`.
* Expanded documentation with rule examples (Bad vs. Good code) and `analysis_options.yaml` configuration guidelines.

## 0.1.0-alpha.1

* Initial alpha release of `graft_lint` analyzer plugin.
* Added `avoid_nested_graft_slot` rule to prevent redundant slot nesting.
* Added `require_graft_route_observer` rule to remind developers to register `GraftRouteTracker.observer`.
