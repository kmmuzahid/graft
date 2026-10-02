import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_state.dart';
import '../core/value_graft.dart';
import 'child_slot_engine.dart';

/// Extension on [Graft<S>] providing high-performance reactive Flutter widget builders.
extension GraftWidgetsX<S extends GraftState> on Graft<S> {
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
  ///   **already** isolate and diff every child slot automatically!
  Widget slot(Widget Function(S state) builder, {Key? key}) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slot');
    return GraftSingleSlotScope<S>(
      key: key,
      graft: this,
      builder: builder,
    );
  }

  // ===========================================================================
  // 2. MULTI-SLOTS (LIST OF WIDGETS + OPTIONAL LAYOUT)
  // ===========================================================================

  /// Creates a reactive multi-child container whose child slots diff independently.
  ///
  /// Takes a [layout] function as the first parameter (e.g. `(children) => Column(children: children)`),
  /// and [children] as the second parameter returning the list of child widgets.
  ///
  /// ### Why use `graft.slots(...)`?
  /// Automatically isolates each child into its own diffing slot:
  /// - `const` children: **0 rebuilds** (pointer identity match).
  /// - Unchanged children: **0 rebuilds** (equivalence match).
  /// - Only slots with changed content rebuild in Flutter's render pipeline.
  /// - Collection-`if` and collection-`for` are 100% supported natively.
  /// - 100% layout agnostic: Works with [Column], [Row], [Wrap], [Stack], [ListView], etc.
  ///
  /// ### Example:
  /// ```dart
  /// // 1. Vertical Column:
  /// graft.slots(
  ///   (children) => Column(children: children),
  ///   (s) => [
  ///     const ProfileHeader(),
  ///     Text(s.name),
  ///     if (s.isVerified) const VerifiedBadge(),
  ///     Text(s.email),
  ///   ],
  /// )
  ///
  /// // 2. Horizontal Row:
  /// graft.slots(
  ///   (children) => Row(children: children),
  ///   (s) => [
  ///     const Icon(Icons.star),
  ///     Text('${s.rating}'),
  ///     Text('(${s.reviewCount})'),
  ///   ],
  /// )
  /// ```
  /// ⚠️ **How Slot Diffing Works:**
  /// - `const` children: **0 rebuilds** for any widget in Flutter via pointer identity.
  /// - Built-in primitives (`Text`, `Icon`, `SizedBox`, `Padding`, `Container`, `ColoredBox`, `Align`):
  ///   automatically deep-diffed.
  /// - If a slot contains arbitrary 3rd-party widgets or widgets with callbacks (`onTap: () => ...`),
  ///   use **`graft.compute`** to guarantee 0-rebuild data-driven isolation.
  /// - Do **NOT** wrap children inside `graft.slots` with `graft.slot(...)`!
  ///   Every item in the list is **already** an isolated diffing slot automatically.
  Widget slots(
    Widget Function(List<Widget> children) layout,
    List<Widget> Function(S state) children, {
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
  /// graft.compute(
  ///   (s) => s.notifications.length, // Derived computation: int
  ///   (count) => HeavyBadge(count: count), // Builder runs ONLY when count changes!
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
  Widget compute<R>(
    R Function(S state) computation,
    Widget Function(R value) builder, {
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.compute');
    return _GraftComputation<S, R>(
      key: key,
      graft: this,
      computation: computation,
      builder: builder,
    );
  }

  // ===========================================================================
  // 4. LAZY BUILDER & VIRTUALIZED COLLECTIONS
  // ===========================================================================

  /// Creates a 100% lazy, virtualized collection with per-item slot diffing.
  ///
  /// Works with **ANY** Flutter builder widget:
  /// - [ListView.builder] / [ListView.separated]
  /// - [GridView.builder]
  /// - [PageView.builder]
  /// - [SliverList.builder] / [SliverGrid.builder]
  /// - [CarouselView]
  ///
  /// ### How it works:
  /// - **Layout Agnostic**: The [layout] function receives `(itemCount, itemBuilder)`.
  ///   You pass standard Flutter widgets without any wrapper interference.
  /// - **100% Automated**: Pass `items: (s) => s.tasks` once. The engine automatically derives
  ///   `itemCount` and indexes each item.
  /// - **Fine-Grained Isolation**: Unchanged items have **0 rebuilds**. Only the modified item rebuilds (**1 rebuild**)!
  ///
  /// ### Example (ListView):
  /// ```dart
  /// graft.builder<TaskItem>(
  ///   (itemCount, itemBuilder) => ListView.builder(
  ///     padding: const EdgeInsets.all(8),
  ///     itemCount: itemCount,
  ///     itemBuilder: itemBuilder,
  ///   ),
  ///   items: (s) => s.tasks,
  ///   itemBuilder: (context, task, index) => TaskListTile(task: task),
  /// )
  /// ```
  ///
  /// ### Example (GridView):
  /// ```dart
  /// graft.builder<Product>(
  ///   (itemCount, itemBuilder) => GridView.builder(
  ///     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  ///     itemCount: itemCount,
  ///     itemBuilder: itemBuilder,
  ///   ),
  ///   items: (s) => s.products,
  ///   itemBuilder: (context, product, index) => ProductGridTile(product: product),
  /// )
  /// ```
  Widget builder<T>(
    Widget Function(int itemCount, NullableIndexedWidgetBuilder itemBuilder) layout, {
    List<T> Function(S state)? items,
    int Function(S state)? itemCount,
    T Function(S state, int index)? item,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    Key Function(T item, int index)? itemKey,
    Key? key,
  }) {
    assert(
      items != null || (itemCount != null && item != null),
      'Either provide `items: (s) => ...` or both `itemCount` and `item`.',
    );
    GraftScopeGuard.verifyNotActive(this, 'graft.builder');
    return GraftBuilderDiffEngine<S, T>(
      key: key,
      graft: this,
      layout: layout,
      itemCount: itemCount ?? ((s) => items!(s).length),
      item: item ?? ((s, i) => items!(s)[i]),
      itemBuilder: itemBuilder,
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
  Widget item<T>(
    T Function(S state) selector,
    Widget Function(BuildContext context, T item) builder, {
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.item');
    return GraftItemSlot<S, T>(
      key: key,
      graft: this,
      selector: selector,
      builder: builder,
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
  /// counterGraft.slot((count) => Text('Count: $count'))
  ///
  /// // 2. Per-Item Micro-State in ListView.builder:
  /// // When items in a large list hold their own ValueGraft (e.g. isLiked, quantity),
  /// // tapping like rebuilds ONLY that tiny cell with 0 rebuilds for the parent list!
  /// ListView.builder(
  ///   itemCount: items.length,
  ///   itemBuilder: (context, index) {
  ///     final item = items[index];
  ///     return ListTile(
  ///       title: Text(item.title),
  ///       trailing: item.isLiked.slot(
  ///         (liked) => IconButton(
  ///           icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
  ///           onPressed: () => item.isLiked.value = !item.isLiked.value,
  ///         ),
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  Widget slot(Widget Function(T value) builder, {Key? key}) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slot');
    return GraftSingleSlotScope<GraftValue<T>>(
      key: key,
      graft: this,
      builder: (s) => builder(s.value),
    );
  }
}

