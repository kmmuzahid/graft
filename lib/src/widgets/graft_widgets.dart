import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_state.dart';
import '../core/value_graft.dart';
import 'child_slot_engine.dart';
import 'multi_graft_scope.dart';

/// Extension on [Graft<S>] providing high-performance reactive Flutter widget builders.
extension GraftWidgetsX<S extends GraftState> on Graft<S> {
  /// Combines this [Graft] with another [Graft] into a single unified rebuild boundary.
  ///
  /// Rebuilds only when either state updates, and surgical diffing eliminates clean passes.
  Widget combine<S2 extends GraftState>(
    Graft<S2> other,
    Widget Function(S s1, S2 s2) builder, {
    Key? key,
  }) {
    return GraftMultiSlotScope(
      key: key,
      grafts: [this, other],
      builder: () => builder(state, other.state),
    );
  }

  /// Combines this [Graft] with two other [Graft] instances into a single unified rebuild boundary.
  Widget combine2<S2 extends GraftState, S3 extends GraftState>(
    Graft<S2> second,
    Graft<S3> third,
    Widget Function(S s1, S2 s2, S3 s3) builder, {
    Key? key,
  }) {
    return GraftMultiSlotScope(
      key: key,
      grafts: [this, second, third],
      builder: () => builder(state, second.state, third.state),
    );
  }

  // ===========================================================================
  // 1. SINGLE SLOT (ONE WIDGET)
  // ===========================================================================

  /// Creates an isolated single-child slot that diffs its content.
  ///
  /// ### Why use `graft.slot(...)`?
  /// Rebuilds **ONLY** when the widget returned by [builder] changes properties or identity.
  /// Unrelated state changes in other fields will result in **0 rebuilds** for this slot.
  ///
  /// Also handles full-screen state switching (e.g. Loading / Error / Content):
  /// when the returned widget type changes (e.g. `Spinner` to `Dashboard`), it automatically
  /// swaps the widget.
  ///
  /// ### Example:
  /// ```dart
  /// // 1. Single Field in AppBar / ListTile:
  /// AppBar(
  ///   title: graft.slot((s) => Text(s.title)),
  /// )
  ///
  /// // 2. Standard ListView.builder (Without ValueGraft):
  /// graft.slot((s) => ListView.builder(
  ///   itemCount: s.items.length,
  ///   itemBuilder: (context, index) {
  ///     final item = s.items[index];
  ///     return ListTile(
  ///       title: Text(item.title),
  ///       trailing: Icon(item.isDone ? Icons.check : Icons.circle_outlined),
  ///     );
  ///   },
  /// ))
  /// ```
  ///
  /// ⚠️ **Avoid Misuse:**
  /// - Do **NOT** use `graft.slot` inside `graft.slots(...)`. Those multi-child layouts
  /// Creates an isolated single-child slot that diffs its content.
  ///
  /// ### Why use `graft.slot(...)`?
  /// Rebuilds **ONLY** when the widget returned by [builder] changes properties or identity.
  /// Unrelated state changes in other fields will result in **0 rebuilds** for this slot.
  ///
  /// Also handles full-screen state switching (e.g. Loading / Error / Content):
  /// when the returned widget type changes (e.g. `Spinner` to `Dashboard`), it automatically
  /// swaps the widget.
  ///
  /// ### Example:
  /// ```dart
  /// // 1. Single Field in AppBar / ListTile:
  /// AppBar(
  ///   title: graft.slot(
  ///     builder: (s) => Text(s.title),
  ///   ),
  /// )
  /// ```
  ///
  /// ⚠️ **Avoid Misuse:**
  /// - Do **NOT** use `graft.slot` inside `graft.slots(...)`. Those multi-child layouts
  ///   **already** isolate and diff every child slot automatically!
  Widget slot({
    required Widget Function(S state) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slot');
    return GraftSingleSlotScope<S>(
      key: key,
      graft: this,
      builder: builder,
    );
  }

  /// Callable syntax shortcut allowing `graft((s) => Text(s.name))` as the ultra-clean reactive entry point!
  Widget call(Widget Function(S state) builder, {Key? key}) =>
      slot(builder: builder, key: key);

  // ===========================================================================
  // 2. MULTI-SLOTS (LIST OF WIDGETS + REQUIRED LAYOUT)
  // ===========================================================================

  /// Creates a reactive multi-child container whose child slots diff independently.
  ///
  /// Takes a required named [layout] function (e.g. `(children) => Column(children: children)`),
  /// and required named [children] function returning the list of child widgets.
  ///
  /// ### Why use `graft.slots(...)`?
  /// Automatically isolates each child into its own diffing slot:
  /// - `const` children: **0 rebuilds** (pointer identity match).
  /// - Unchanged children: **0 rebuilds** (equivalence match).
  /// - Only slots with changed content rebuild in Flutter's render pipeline.
  /// - Collection-`if` and collection-`for` are 100% supported natively.
  /// - 100% layout agnostic: Works with [Column], [Row], [Wrap], [Stack], [Flex], etc.
  ///
  /// ### Example:
  /// ```dart
  /// // 1. Vertical Column:
  /// graft.slots(
  ///   layout: (children) => Column(children: children),
  ///   children: (s) => [
  ///     const ProfileHeader(),
  ///     Text(s.name),
  ///     if (s.isVerified) const VerifiedBadge(),
  ///     Text(s.email),
  ///   ],
  /// )
  /// ```
  Widget slots({
    required Widget Function(List<Widget> children) layout,
    required List<Widget> Function(S state) children,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slots');
    return GraftMultiChildDiffEngine<S>(
      key: key,
      graft: this,
      layoutBuilder: layout,
      childrenBuilder: children,
    );
  }

  /// Creates a fine-grained reactive [Column] whose children diff independently with 0 rebuilds.
  Widget column({
    required List<Widget> Function(S state) children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextDirection? textDirection,
    TextBaseline? textBaseline,
    Key? key,
  }) => slots(
    key: key,
    layout: (c) => Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      verticalDirection: verticalDirection,
      textDirection: textDirection,
      textBaseline: textBaseline,
      children: c,
    ),
    children: children,
  );

  /// Creates a fine-grained reactive [Row] whose children diff independently with 0 rebuilds.
  Widget row({
    required List<Widget> Function(S state) children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextDirection? textDirection,
    TextBaseline? textBaseline,
    Key? key,
  }) => slots(
    key: key,
    layout: (c) => Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      verticalDirection: verticalDirection,
      textDirection: textDirection,
      textBaseline: textBaseline,
      children: c,
    ),
    children: children,
  );

  // ===========================================================================
  // 3. COMPUTED DERIVED STATE (PRE-FLIGHT VALUE CHECK)
  // ===========================================================================

  /// Computes a derived value [R] from state and rebuilds **ONLY** when that computed value changes.
  ///
  /// ### Why use `graft.compute(...)`?
  /// When you derive a computed value from state (e.g. `s.items.length`, `s.unreadCount > 0`,
  /// or `s.price * s.quantity`), [compute] checks the raw computed value first.
  /// If the computed value has not changed, the widget builder closure is **never even executed**,
  /// saving CPU cycles on heavy subtrees.
  ///
  /// ### Example:
  /// ```dart
  /// graft.compute<int>(
  ///   compute: (s) => s.notifications.length, // Derived computation: int
  ///   builder: (count) => HeavyBadge(count: count), // Builder runs ONLY when count changes!
  /// )
  /// ```
  ///
  /// 💡 **When to use `graft.compute`:**
  /// - For **deeply nested subtrees**, **custom/3rd-party widgets** (e.g. CoreKit, Card, ListTile),
  ///   or widgets with closures (`onTap: () => ...`), [compute] checks the raw data first,
  ///   guaranteeing 0-rebuild isolation without needing widget-diffing.
  /// - For **derived computed values** (e.g. `(s) => s.items.length` or `(s) => s.total > 100`).
  /// - For simple widgets like `Text(s.name)`, `graft.slot` and `graft.slots` already do fast
  ///   diffing with zero ceremony.
  Widget compute<R>({
    required R Function(S state) compute,
    required Widget Function(R value) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.compute');
    return _GraftComputation<S, R>(
      key: key,
      graft: this,
      computation: compute,
      builder: builder,
    );
  }

  // ===========================================================================
  // 4. LAZY BUILDER & VIRTUALIZED COLLECTIONS
  // ===========================================================================

  /// Creates a 100% lazy, virtualized collection with per-item slot diffing.
  ///
  /// Works out-of-the-box with automatic [ListView.builder], or customize with **ANY** Flutter builder:
  /// - [ListView.builder] / [ListView.separated]
  /// - [GridView.builder]
  /// - [PageView.builder]
  /// - [SliverList.builder] / [SliverGrid.builder]
  /// - [CarouselView]
  ///
  /// ### How it works:
  /// - **Zero Layout Plumbing**: Defaults automatically to `ListView.builder`.
  /// - **100% Automated**: Pass `items: (s) => s.tasks` once. The engine automatically derives
  ///   `itemCount` and indexes each item.
  /// - **Position & Data Access**: [itemBuilder] receives `(item, index)` for zebra striping, rank numbers, etc.
  ///   Or use `item: (item)` for a zero-ceremony 1-argument shorthand.
  /// - **Fine-Grained Isolation**: Unchanged items have **0 rebuilds**. Only the modified item rebuilds (**1 rebuild**)!
  ///
  /// ### Example (Default ListView):
  /// ```dart
  /// graft.builder<TaskItem>(
  ///   items: (s) => s.tasks,
  ///   itemBuilder: (task, index) => TaskListTile(task: task, isEven: index.isEven),
  /// )
  /// ```
  ///
  /// ### Example (Custom GridView):
  /// ```dart
  /// graft.builder<Product>(
  ///   items: (s) => s.products,
  ///   itemBuilder: (product, index) => ProductGridTile(product: product),
  ///   layout: (itemCount, itemBuilder) => GridView.builder(
  ///     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  ///     itemCount: itemCount,
  ///     itemBuilder: itemBuilder,
  ///   ),
  /// )
  /// ```
  Widget builder<T>({
    required List<T> Function(S state) items,
    Widget Function(T item, int index)? itemBuilder,
    Widget Function(T item)? item,
    /// Optional stable key extractor for list items.
    ///
    /// **You do NOT need this in most cases.**
    /// By default, Graft uses `ValueKey(index)` which is correct and
    /// automatic for any list where items are only added, removed at the
    /// end, or updated in-place at a fixed position.
    ///
    /// **Only provide [itemKey] when your list can be dynamically reordered**
    /// (e.g. drag-and-drop, sort-by-field, or items inserted at arbitrary
    /// positions). In these cases, position-based keys cause wrong elements
    /// to update — use a stable ID field instead:
    ///
    /// ```dart
    /// // ✅ When items can reorder:
    /// graft.builder<TaskItem>(
    ///   items: (s) => s.tasks,
    ///   itemBuilder: (task, index) => TaskCard(task, index: index),
    ///   itemKey: (item) => ValueKey(item.id),
    /// );
    ///
    /// // ✅ When index is not needed in the card:
    /// graft.builder<TaskItem>(
    ///   items: (s) => s.tasks,
    ///   itemBuilder: (task, _) => TaskCard(task),
    ///   // No itemKey needed — automatic ValueKey(index) is applied.
    /// );
    /// ```
    Key Function(T item)? itemKey,
    Widget Function(int itemCount, NullableIndexedWidgetBuilder itemBuilder)? layout,
    Key? key,
  }) {
    assert(
      itemBuilder != null || item != null,
      'Either provide `itemBuilder: (item, index) => ...` or `item: (item) => ...`.',
    );
    GraftScopeGuard.verifyNotActive(this, 'graft.builder');
    final effectiveLayout = layout ??
        (count, b) => ListView.builder(
              itemCount: count,
              itemBuilder: b,
            );
    final effectiveItemBuilder = itemBuilder ?? (T itm, int _) => item!(itm);
    return GraftBuilderDiffEngine<S, T>(
      key: key,
      graft: this,
      layout: effectiveLayout,
      itemCount: (s) => items(s).length,
      item: (s, i) => items(s)[i],
      itemBuilder: (context, itm, index) => effectiveItemBuilder(itm, index),
      itemKey: itemKey,
    );
  }

  /// Universal lazy item slot adapter.
  ///
  /// Plug directly into the `itemBuilder` of **ANY** Flutter builder:
  /// - [GridView.builder]
  /// - [ListView.builder]
  /// - [PageView.builder]
  /// - [SliverList.builder] / [SliverGrid.builder]
  /// - [CarouselView]
  ///
  /// Rebuilds **ONLY** when [selector] returns a new or modified item.
  Widget item<T>({
    required T Function(S state) selector,
    required Widget Function(T item) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.item');
    return GraftItemSlot<S, T>(
      key: key,
      graft: this,
      selector: selector,
      builder: (context, itm) => builder(itm),
    );
  }
}

class _GraftComputation<S extends GraftState, R> extends StatefulWidget
    implements GraftEquivalent {
  final Graft<S> graft;
  final R Function(S state) computation;
  final Widget Function(R value) builder;

  const _GraftComputation({
    super.key,
    required this.graft,
    required this.computation,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! _GraftComputation) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<_GraftComputation<S, R>> createState() => _GraftComputationState<S, R>();
}

class _GraftComputationState<S extends GraftState, R> extends State<_GraftComputation<S, R>> {
  late R _computedValue;

  @override
  void initState() {
    super.initState();
    _computedValue = GraftScopeGuard.run(
      widget.graft,
      'graft.compute',
      () => widget.computation(widget.graft.state),
    );
    widget.graft.addListener(_onStateChange);
  }

  void _onStateChange() {
    final newValue = GraftScopeGuard.run(
      widget.graft,
      'graft.compute',
      () => widget.computation(widget.graft.state),
    );
    if (_computedValue != newValue) {
      setState(() {
        _computedValue = newValue;
      });
      Graft.observer?.onSlotRebuild(widget.graft, 0, widget.builder(newValue));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _onStateChange();
  }

  @override
  void didUpdateWidget(covariant _GraftComputation<S, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChange);
      _computedValue = GraftScopeGuard.run(
        widget.graft,
        'graft.compute',
        () => widget.computation(widget.graft.state),
      );
      widget.graft.addListener(_onStateChange);
    } else {
      _onStateChange();
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      final ancestorScope = context.getInheritedWidgetOfExactType<InheritedGraftScope>();
      if (ancestorScope != null && identical(ancestorScope.graft, widget.graft)) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: NESTED ELEMENT TREE SCOPE ON ${widget.graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'A widget inside "${ancestorScope.caller}" is trying to observe the exact same ${widget.graft.runtimeType} with "graft.compute"!\n'
          'This creates duplicate element listeners on the same controller and degrades performance.\n\n'
          'Fix: Use the value directly inside "${ancestorScope.caller}" without wrapping it in graft.compute().\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      return true;
    }());

    return InheritedGraftScope(
      graft: widget.graft,
      caller: 'graft.compute',
      child: widget.builder(_computedValue),
    );
  }
}

/// Extension on [ValueGraft<T>] providing clean, single-value reactive widget builders.
extension ValueGraftWidgetsX<T> on ValueGraft<T> {
  /// A reactive slot that diffs and rebuilds only when [value] changes.
  ///
  /// ### Examples:
  /// ```dart
  /// // 1. Standalone Counter:
  /// counterGraft.slot(
  ///   builder: (count) => Text('Count: $count'),
  /// )
  /// ```
  Widget slot({
    required Widget Function(T value) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slot');
    return GraftSingleSlotScope<GraftValue<T>>(
      key: key,
      graft: this,
      builder: (s) => builder(s.value),
    );
  }
}

// =============================================================================
// MULTI-GRAFT COMBINATOR EXTENSIONS (Dart 3 Record Syntax)
// =============================================================================

/// Modern Dart 3 Record extension for pairing 2 Grafts into a single surgical boundary.
///
/// ### Example:
/// ```dart
/// (userGraft, themeGraft).graft((user, theme) => Row(
///   children: [
///     Icon(theme.icon, color: theme.primaryColor),
///     Text('User: ${user.name}'),
///   ],
/// ))
/// ```
extension GraftRecord2X<S1 extends GraftState, S2 extends GraftState>
    on (Graft<S1>, Graft<S2>) {
  /// Renders a single rebuild boundary combining both Grafts.
  Widget graft(Widget Function(S1 s1, S2 s2) builder, {Key? key}) {
    return GraftMultiSlotScope(
      key: key,
      grafts: [$1, $2],
      builder: () => builder($1.state, $2.state),
    );
  }

  /// Callable syntax shortcut: `(userGraft, themeGraft)((user, theme) => ...)`
  Widget call(Widget Function(S1 s1, S2 s2) builder, {Key? key}) =>
      graft(builder, key: key);
}

/// Modern Dart 3 Record extension for combining 3 Grafts into a single surgical boundary.
extension GraftRecord3X<S1 extends GraftState, S2 extends GraftState,
    S3 extends GraftState> on (Graft<S1>, Graft<S2>, Graft<S3>) {
  /// Renders a single rebuild boundary combining all 3 Grafts.
  Widget graft(Widget Function(S1 s1, S2 s2, S3 s3) builder, {Key? key}) {
    return GraftMultiSlotScope(
      key: key,
      grafts: [$1, $2, $3],
      builder: () => builder($1.state, $2.state, $3.state),
    );
  }

  /// Callable syntax shortcut: `(graftA, graftB, graftC)((a, b, c) => ...)`
  Widget call(Widget Function(S1 s1, S2 s2, S3 s3) builder, {Key? key}) =>
      graft(builder, key: key);
}

/// Modern Dart 3 Record extension for combining 4 Grafts into a single surgical boundary.
extension GraftRecord4X<
    S1 extends GraftState,
    S2 extends GraftState,
    S3 extends GraftState,
    S4 extends GraftState> on (Graft<S1>, Graft<S2>, Graft<S3>, Graft<S4>) {
  /// Renders a single rebuild boundary combining all 4 Grafts.
  Widget graft(Widget Function(S1 s1, S2 s2, S3 s3, S4 s4) builder,
      {Key? key}) {
    return GraftMultiSlotScope(
      key: key,
      grafts: [$1, $2, $3, $4],
      builder: () => builder($1.state, $2.state, $3.state, $4.state),
    );
  }

  /// Callable syntax shortcut: `(graftA, graftB, graftC, graftD)((a, b, c, d) => ...)`
  Widget call(Widget Function(S1 s1, S2 s2, S3 s3, S4 s4) builder,
          {Key? key}) =>
      graft(builder, key: key);
}


