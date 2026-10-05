# Changelog

All notable changes to `graft_lint` will be documented in this file.

## 0.1.2-alpha.1

* **New Rule (`prefer_tracked_in_graft_state`):** Warns developers when a domain state class extending `GraftState` declares fields without overriding `tracked`. Guides developers to declare `List<Object?> get tracked => [...]` to enable 1-cycle hardware bitmask diffing and 0 GC heap allocations.
* **Expanded `avoid_nested_graft_slot`:** Added `boundary` to prohibited nesting patterns (e.g. nesting `graft.boundary` inside `graft.slots` or `slot`).

## 0.1.1-alpha.1

* **Breaking (Diagnostics):** Promoted `avoid_nested_graft_slot` rule severity from `Warning` to `Error` (`ErrorSeverity.ERROR`) by default.
* Fixed ambiguous import collision for `LintCode` between `analyzer` and `custom_lint_builder`.
* Expanded documentation with rule examples (Bad vs. Good code) and `analysis_options.yaml` configuration guidelines.

## 0.1.0-alpha.1

* Initial alpha release of `graft_lint` analyzer plugin.
* Added `avoid_nested_graft_slot` rule to prevent redundant slot nesting.
* Added `require_graft_route_observer` rule to remind developers to register `GraftRouteTracker.observer`.
