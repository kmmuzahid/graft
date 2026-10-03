import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/graft.dart';
import '../core/graft_state.dart';

/// Interface for custom widgets to declare fine-grained content equivalence for slot diffing.
///
/// ### Why implement GraftEquivalent?
/// In Flutter, `Widget.operator ==` is marked `@nonVirtual` by default linter rules.
/// Implementing [GraftEquivalent] allows your custom widgets to define custom equivalence rules
/// without triggering linter warnings, allowing [GraftMultiChildDiffEngine] to skip rebuilding
/// whenever [isEquivalentTo] returns `true`.
///
/// ### Example:
/// ```dart
/// class UserAvatar extends StatelessWidget implements GraftEquivalent {
///   final String url;
///   const UserAvatar(this.url);
///
///   @override
///   bool isEquivalentTo(Widget other) => other is UserAvatar && other.url == url;
///
///   @override
///   Widget build(BuildContext context) => Image.network(url);
/// }
/// ```
abstract interface class GraftEquivalent {
  /// Returns whether this widget is equivalent to [other] for slot diffing.
  bool isEquivalentTo(Widget other);
}

/// Engine that performs fine-grained diffing on multi-child layout slots.
///
/// ### Why use GraftMultiChildDiffEngine?
/// In standard Flutter, modifying a single field inside a state model causes every widget inside
/// a parent `Column` or `Row` to rebuild.
/// [GraftMultiChildDiffEngine] wraps each child returned by [childrenBuilder] in an isolated
/// notifier slot. When state changes:
/// - `const` children: **0 rebuilds** (pointer identity match).
/// - Content equivalent children: **0 rebuilds** (evaluated via [isWidgetEquivalent]).
/// - Only slots with modified content trigger a rebuild in Flutter's render pipeline.
///
/// Powering methods like `graft.column(...)`, `graft.row(...)`, `graft.stack(...)`, and `graft.wrap(...)`.
class GraftMultiChildDiffEngine<S extends GraftState> extends StatefulWidget
    implements GraftEquivalent {
  /// The [Graft] controller providing state updates.
  final Graft<S> graft;

  /// Layout wrapper (e.g. `(children) => Column(children: children)`) receiving isolated slot widgets.
  final Widget Function(List<Widget> children) layoutBuilder;

  /// Builder returning the list of children widgets based on current [S].
  final List<Widget> Function(S state) childrenBuilder;

  /// Creates a [GraftMultiChildDiffEngine] that manages isolated slot rebuilds.
  const GraftMultiChildDiffEngine({
    super.key,
    required this.graft,
    required this.layoutBuilder,
    required this.childrenBuilder,
  });

  /// Compares two widgets for content equivalence to prevent unnecessary slot rebuilds.
  ///
  /// ### How Slot Diffing Works:
  /// 1. **`const` Widgets:** Any widget marked `const` is skipped immediately with **0 rebuilds**
  ///    via pointer identity (`identical(a, b)`).
  /// 2. **Stable Keys (`ValueKey`):** Widgets with matching non-null keys (e.g. `ValueKey(state.field)`)
  ///    skip diffing instantly with **0 rebuilds** when unchanged, and trigger an isolated rebuild
  ///    when the key value updates. Use this for 3rd-party or custom [StatefulWidget]s.
  /// 3. **Custom Equivalence & Native Graft Widgets:** Evaluates [GraftEquivalent.isEquivalentTo]
  ///    or `operator ==`. Native Graft reactive widgets ([GraftMultiChildDiffEngine], [GraftSingleSlotScope],
  ///    and `_GraftComputation`) implement [GraftEquivalent] to support nested cross-Graft isolation with 0 rebuilds.
  /// 4. **Supported Primitives:** Recursively property-diffed for [Text], [RichText], [Icon], [SizedBox],
  ///    [Padding], [Container], [ColoredBox], [Align]/[Center], [DecoratedBox], [Opacity], [ClipRRect],
  ///    [ShaderMask], [DefaultTextStyle], [Flex] ([Row]/[Column]), [Flexible] ([Expanded]), [FittedBox],
  ///    [ConstrainedBox], [AspectRatio], [FractionallySizedBox], [Stack], and [Wrap].
  /// 5. **Interactive Widgets:** Functionally diffed for [GestureDetector], [InkWell], [ButtonStyleButton]
  ///    ([ElevatedButton], [TextButton], [OutlinedButton], [FilledButton]), [IconButton], [CupertinoButton],
  ///    and [ListTile]. Inline callback closures (`onTap: () => ...`) do not trigger rebuilds.
  /// 6. **Automatic StatelessWidget Unwrapping:** Custom components (e.g. `CkText`, `Card`) automatically
  ///    expand to their underlying primitives and diff by content.
  ///
  /// 👉 For complex custom or 3rd-party [StatefulWidget]s where you want to control isolated rebuilds,
  /// assign `key: ValueKey(state.field)`. Alternatively, use **`graft.compute(...)`** for data-driven isolation.
  static bool isWidgetEquivalent(
    Widget a,
    Widget b, [
    BuildContext? context,
    Set<Widget>? visited,
  ]) {
    if (identical(a, b)) return true;
    if (a.runtimeType != b.runtimeType) return false;

    // Matching non-null keys explicitly denote content equivalence
    if (a.key != null && b.key != null && a.key == b.key) {
      return true;
    }
    if (a.key != b.key) return false;

    // Custom GraftEquivalent interface
    if (a is GraftEquivalent) {
      return (a as GraftEquivalent).isEquivalentTo(b);
    }

    // Direct object equality if overridden
    if (a == b) return true;

    // Text widget comparison
    if (a is Text && b is Text) {
      return a.data == b.data &&
          a.style == b.style &&
          a.textAlign == b.textAlign &&
          a.maxLines == b.maxLines &&
          a.overflow == b.overflow;
    }

    // RichText widget comparison
    if (a is RichText && b is RichText) {
      return a.text == b.text &&
          a.textAlign == b.textAlign &&
          a.maxLines == b.maxLines &&
          a.overflow == b.overflow;
    }

    // Icon widget comparison
    if (a is Icon && b is Icon) {
      return a.icon == b.icon &&
          a.size == b.size &&
          a.color == b.color &&
          a.semanticLabel == b.semanticLabel;
    }

    // SizedBox comparison
    if (a is SizedBox && b is SizedBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.width == b.width && a.height == b.height;
    }

    // Padding comparison
    if (a is Padding && b is Padding) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.padding == b.padding;
    }

    // Container comparison
    if (a is Container && b is Container) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      if (!childEqual) return false;

      return a.color == b.color &&
          a.padding == b.padding &&
          a.margin == b.margin &&
          a.alignment == b.alignment &&
          a.decoration == b.decoration &&
          a.constraints == b.constraints &&
          a.clipBehavior == b.clipBehavior;
    }

    // ColoredBox comparison
    if (a is ColoredBox && b is ColoredBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.color == b.color;
    }

    // Align & Center comparison
    if (a is Align && b is Align) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual &&
          a.alignment == b.alignment &&
          a.widthFactor == b.widthFactor &&
          a.heightFactor == b.heightFactor;
    }

    // DecoratedBox comparison
    if (a is DecoratedBox && b is DecoratedBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.decoration == b.decoration && a.position == b.position;
    }

    // Opacity comparison
    if (a is Opacity && b is Opacity) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.opacity == b.opacity;
    }

    // ClipRRect comparison
    if (a is ClipRRect && b is ClipRRect) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.borderRadius == b.borderRadius && a.clipBehavior == b.clipBehavior;
    }

    // ShaderMask comparison
    if (a is ShaderMask && b is ShaderMask) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.blendMode == b.blendMode;
    }

    // DefaultTextStyle comparison
    if (a is DefaultTextStyle && b is DefaultTextStyle) {
      return a.style == b.style &&
          a.textAlign == b.textAlign &&
          isWidgetEquivalent(a.child, b.child, context, visited);
    }

    // Flex (Row / Column) comparison
    if (a is Flex && b is Flex) {
      if (a.direction != b.direction ||
          a.mainAxisAlignment != b.mainAxisAlignment ||
          a.mainAxisSize != b.mainAxisSize ||
          a.crossAxisAlignment != b.crossAxisAlignment ||
          a.textDirection != b.textDirection ||
          a.verticalDirection != b.verticalDirection ||
          a.clipBehavior != b.clipBehavior ||
          a.children.length != b.children.length) {
        return false;
      }
      for (int i = 0; i < a.children.length; i++) {
        if (!isWidgetEquivalent(a.children[i], b.children[i], context, visited)) {
          return false;
        }
      }
      return true;
    }

    // Flexible & Expanded comparison
    if (a is Flexible && b is Flexible) {
      final childEqual = isWidgetEquivalent(a.child, b.child, context, visited);
      return childEqual && a.flex == b.flex && a.fit == b.fit;
    }

    // FittedBox comparison
    if (a is FittedBox && b is FittedBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual &&
          a.fit == b.fit &&
          a.alignment == b.alignment &&
          a.clipBehavior == b.clipBehavior;
    }

    // ConstrainedBox comparison
    if (a is ConstrainedBox && b is ConstrainedBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.constraints == b.constraints;
    }

    // AspectRatio comparison
    if (a is AspectRatio && b is AspectRatio) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual && a.aspectRatio == b.aspectRatio;
    }

    // FractionallySizedBox comparison
    if (a is FractionallySizedBox && b is FractionallySizedBox) {
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return childEqual &&
          a.widthFactor == b.widthFactor &&
          a.heightFactor == b.heightFactor &&
          a.alignment == b.alignment;
    }

    // Stack comparison
    if (a is Stack && b is Stack) {
      if (a.alignment != b.alignment ||
          a.textDirection != b.textDirection ||
          a.fit != b.fit ||
          a.clipBehavior != b.clipBehavior ||
          a.children.length != b.children.length) {
        return false;
      }
      for (int i = 0; i < a.children.length; i++) {
        if (!isWidgetEquivalent(a.children[i], b.children[i], context, visited)) {
          return false;
        }
      }
      return true;
    }

    // Positioned comparison
    if (a is Positioned && b is Positioned) {
      final childEqual = isWidgetEquivalent(a.child, b.child, context, visited);
      return childEqual &&
          a.left == b.left &&
          a.top == b.top &&
          a.right == b.right &&
          a.bottom == b.bottom &&
          a.width == b.width &&
          a.height == b.height;
    }

    // Wrap comparison
    if (a is Wrap && b is Wrap) {
      if (a.direction != b.direction ||
          a.alignment != b.alignment ||
          a.spacing != b.spacing ||
          a.runAlignment != b.runAlignment ||
          a.runSpacing != b.runSpacing ||
          a.crossAxisAlignment != b.crossAxisAlignment ||
          a.textDirection != b.textDirection ||
          a.verticalDirection != b.verticalDirection ||
          a.clipBehavior != b.clipBehavior ||
          a.children.length != b.children.length) {
        return false;
      }
      for (int i = 0; i < a.children.length; i++) {
        if (!isWidgetEquivalent(a.children[i], b.children[i], context, visited)) {
          return false;
        }
      }
      return true;
    }

    // GestureDetector functional comparison
    if (a is GestureDetector && b is GestureDetector) {
      final bothTapActive = (a.onTap != null) == (b.onTap != null);
      final bothDoubleTapActive = (a.onDoubleTap != null) == (b.onDoubleTap != null);
      final bothLongPressActive = (a.onLongPress != null) == (b.onLongPress != null);
      final behaviorEqual = a.behavior == b.behavior;
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return bothTapActive && bothDoubleTapActive && bothLongPressActive && behaviorEqual && childEqual;
    }

    // InkWell functional comparison
    if (a is InkWell && b is InkWell) {
      final bothTapActive = (a.onTap != null) == (b.onTap != null);
      final bothDoubleTapActive = (a.onDoubleTap != null) == (b.onDoubleTap != null);
      final bothLongPressActive = (a.onLongPress != null) == (b.onLongPress != null);
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return bothTapActive && bothDoubleTapActive && bothLongPressActive && childEqual && a.borderRadius == b.borderRadius;
    }

    // ButtonStyleButton family (ElevatedButton, TextButton, OutlinedButton, FilledButton)
    if (a is ButtonStyleButton && b is ButtonStyleButton) {
      final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
      final bothLongPress = (a.onLongPress != null) == (b.onLongPress != null);
      final styleEqual = a.style == b.style;
      final childEqual = (a.child == null && b.child == null) ||
          (a.child != null && b.child != null && isWidgetEquivalent(a.child!, b.child!, context, visited));
      return bothEnabled && bothLongPress && styleEqual && childEqual;
    }

    // IconButton functional comparison
    if (a is IconButton && b is IconButton) {
      final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
      final iconEqual = isWidgetEquivalent(a.icon, b.icon, context, visited);
      return bothEnabled && iconEqual && a.color == b.color && a.iconSize == b.iconSize;
    }

    // CupertinoButton functional comparison
    if (a is CupertinoButton && b is CupertinoButton) {
      final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
      final childEqual = isWidgetEquivalent(a.child, b.child, context, visited);
      return bothEnabled && childEqual && a.color == b.color;
    }

    // ListTile functional comparison
    if (a is ListTile && b is ListTile) {
      final bothTapActive = (a.onTap != null) == (b.onTap != null);
      final bothLongPress = (a.onLongPress != null) == (b.onLongPress != null);
      final titleEqual = (a.title == null && b.title == null) ||
          (a.title != null && b.title != null && isWidgetEquivalent(a.title!, b.title!, context, visited));
      final leadingEqual = (a.leading == null && b.leading == null) ||
          (a.leading != null && b.leading != null && isWidgetEquivalent(a.leading!, b.leading!, context, visited));
      final subtitleEqual = (a.subtitle == null && b.subtitle == null) ||
          (a.subtitle != null && b.subtitle != null && isWidgetEquivalent(a.subtitle!, b.subtitle!, context, visited));
      final trailingEqual = (a.trailing == null && b.trailing == null) ||
          (a.trailing != null && b.trailing != null && isWidgetEquivalent(a.trailing!, b.trailing!, context, visited));
      return bothTapActive && bothLongPress && titleEqual && leadingEqual && subtitleEqual && trailingEqual;
    }

    // Image widget comparison
    if (a is Image && b is Image) {
      return a.image == b.image &&
          a.width == b.width &&
          a.height == b.height &&
          a.fit == b.fit &&
          a.alignment == b.alignment &&
          a.color == b.color;
    }

    // ProgressIndicator comparison (CircularProgressIndicator, LinearProgressIndicator)
    if (a is ProgressIndicator && b is ProgressIndicator) {
      return a.value == b.value &&
          a.color == b.color &&
          a.backgroundColor == b.backgroundColor;
    }

    // Checkbox comparison
    if (a is Checkbox && b is Checkbox) {
      return a.value == b.value &&
          (a.onChanged != null) == (b.onChanged != null) &&
          a.activeColor == b.activeColor &&
          a.checkColor == b.checkColor;
    }

    // Switch comparison
    if (a is Switch && b is Switch) {
      return a.value == b.value &&
          (a.onChanged != null) == (b.onChanged != null) &&
          a.activeThumbColor == b.activeThumbColor &&
          a.activeTrackColor == b.activeTrackColor;
    }

    // Slider comparison
    if (a is Slider && b is Slider) {
      return a.value == b.value &&
          (a.onChanged != null) == (b.onChanged != null) &&
          a.min == b.min &&
          a.max == b.max &&
          a.activeColor == b.activeColor;
    }

    // Automatic unwrap for StatelessWidgets with lazy cycle detection
    if (context != null && a is StatelessWidget && b is StatelessWidget) {
      final seen = visited ?? HashSet<Widget>.identity();
      if (!seen.add(a)) {
        // Cycle detected: widget recursively builds or references itself
        return false;
      }
      try {
        // ignore: invalid_use_of_protected_member
        final builtA = a.build(context);
        // ignore: invalid_use_of_protected_member
        final builtB = b.build(context);
        return isWidgetEquivalent(builtA, builtB, context, seen);
      } catch (_) {
        // Fallback gracefully if custom build requires specialized element lifecycle
      } finally {
        seen.remove(a);
      }
    }

    return false;
  }

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftMultiChildDiffEngine) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftMultiChildDiffEngine<S>> createState() =>
      _GraftMultiChildDiffEngineState<S>();
}

class _GraftMultiChildDiffEngineState<S extends GraftState>
    extends State<GraftMultiChildDiffEngine<S>> {
  late List<ValueNotifier<Widget>> _slotNotifiers;

  @visibleForTesting
  List<ValueNotifier<Widget>> get slotNotifiers => _slotNotifiers;

  @override
  void initState() {
    super.initState();
    _initSlots();
    widget.graft.addListener(_onStateChanged);
  }

  void _initSlots() {
    final initialWidgets = GraftScopeGuard.run(
      widget.graft,
      'graft.slots',
      () => widget.childrenBuilder(widget.graft.state),
    );
    _slotNotifiers = initialWidgets.map((w) => ValueNotifier<Widget>(w)).toList();
  }

  void _disposeSlots() {
    for (final notifier in _slotNotifiers) {
      notifier.dispose();
    }
    _slotNotifiers.clear();
  }

  @override
  void reassemble() {
    super.reassemble();
    _onStateChanged();
  }

  @override
  void didUpdateWidget(covariant GraftMultiChildDiffEngine<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChanged);
      _disposeSlots();
      _initSlots();
      widget.graft.addListener(_onStateChanged);
    } else {
      _onStateChanged();
    }
  }

  void _onStateChanged() {
    if (!mounted) return;

    final newWidgets = GraftScopeGuard.run(
      widget.graft,
      'graft.slots',
      () => widget.childrenBuilder(widget.graft.state),
    );

    // If child count changed (e.g. conditional if-statement), rebuild container
    if (newWidgets.length != _slotNotifiers.length) {
      _disposeSlots();
      _slotNotifiers = newWidgets.map((w) => ValueNotifier<Widget>(w)).toList();
      setState(() {});
      return;
    }

    // Diff each slot individually
    for (int i = 0; i < newWidgets.length; i++) {
      final oldWidget = _slotNotifiers[i].value;
      final newWidget = newWidgets[i];

      // 1. Const identity match -> 0 rebuilds
      if (identical(oldWidget, newWidget)) {
        continue;
      }

      // 2. Content equivalence match -> 0 rebuilds
      if (GraftMultiChildDiffEngine.isWidgetEquivalent(oldWidget, newWidget, context)) {
        continue;
      }

      // 3. Changed slot -> update notifier to trigger isolated rebuild for slot i
      _slotNotifiers[i].value = newWidget;
      Graft.observer?.onSlotRebuild(widget.graft, i, newWidget);
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChanged);
    _disposeSlots();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wrappedChildren = List<Widget>.generate(_slotNotifiers.length, (i) {
      return _ChildSlotScope(
        key: ValueKey(i),
        graft: widget.graft,
        notifier: _slotNotifiers[i],
      );
    });

    final layoutWidget = widget.layoutBuilder(wrappedChildren);

    assert(() {
      if (wrappedChildren.isNotEmpty) {
        _verifySlotsContract(layoutWidget, wrappedChildren);
      }
      return true;
    }());

    return layoutWidget;
  }

  static void _verifySlotsContract(
    Widget rootWidget,
    List<Widget> expectedChildren,
  ) {
    Widget? current = rootWidget;
    List<Widget>? actualChildren;

    while (current != null && actualChildren == null) {
      if (current is MultiChildRenderObjectWidget) {
        actualChildren = current.children;
        break;
      } else if (current is ListView &&
          current.childrenDelegate is SliverChildListDelegate) {
        actualChildren =
            (current.childrenDelegate as SliverChildListDelegate).children;
        break;
      } else if (current is GridView &&
          current.childrenDelegate is SliverChildListDelegate) {
        actualChildren =
            (current.childrenDelegate as SliverChildListDelegate).children;
        break;
      }

      // Try unwrapping single child widgets (Container, Padding, Card, Scrollbar, etc.)
      Widget? next;
      if (current is SingleChildRenderObjectWidget) {
        next = current.child;
      } else if (current is Container) {
        next = current.child;
      } else if (current is Card) {
        next = current.child;
      } else {
        try {
          final dynamic dynamicWidget = current;
          final child = dynamicWidget.child;
          if (child is Widget) {
            next = child;
          }
        } catch (_) {}
      }

      if (next == null || identical(next, current)) {
        break;
      }
      current = next;
    }

    if (actualChildren != null && expectedChildren.isNotEmpty) {
      final containsSlots =
          actualChildren.any((c) => expectedChildren.contains(c));
      if (!containsSlots) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ERROR: UNUSED children IN graft.slots()\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'In graft.slots((children) => ...), the provided "children" list was NOT passed\n'
          'to your layout widget (${current?.runtimeType ?? rootWidget.runtimeType})!\n\n'
          'Why this is an error:\n'
          'Graft requires the provided "children" list because each child is wrapped in an\n'
          'isolated slot notifier for 0-rebuild diffing.\n\n'
          'Fix:\n'
          'Pass the provided "children" list directly into your layout widget:\n'
          '  graft.slots(\n'
          '    layout: (children) => ${current?.runtimeType ?? 'Column'}(children: children), // ✅ Pass children here!\n'
          '    children: (s) => [ ... ],\n'
          '  )\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
    }
  }
}

/// An isolated slot scope that rebuilds only when its specific slot notifier fires.
class _ChildSlotScope extends StatelessWidget {
  final Graft graft;
  final ValueNotifier<Widget> notifier;

  const _ChildSlotScope({
    super.key,
    required this.graft,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return InheritedGraftScope(
      graft: graft,
      caller: 'graft.slots',
      child: ValueListenableBuilder<Widget>(
        valueListenable: notifier,
        builder: (_, widget, __) => widget,
      ),
    );
  }
}

/// Single-child slot diff engine. Rebuilds only when the widget returned by [builder] changes.
///
/// ### Why use GraftSingleSlotScope?
/// Isolates a single widget builder so that modifications to unrelated fields in [GraftState]
/// do not cause this widget subtree to rebuild.
class GraftSingleSlotScope<S extends GraftState> extends StatefulWidget
    implements GraftEquivalent {
  /// The [Graft] controller providing state updates.
  final Graft<S> graft;

  /// Builder returning the child widget based on current [S].
  final Widget Function(S state) builder;

  /// Creates a [GraftSingleSlotScope] that isolates single child slot rebuilds.
  const GraftSingleSlotScope({
    super.key,
    required this.graft,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftSingleSlotScope) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftSingleSlotScope<S>> createState() => _GraftSingleSlotScopeState<S>();
}

class _GraftSingleSlotScopeState<S extends GraftState> extends State<GraftSingleSlotScope<S>> {
  late final ValueNotifier<Widget> _slotNotifier;

  @override
  void initState() {
    super.initState();
    _slotNotifier = ValueNotifier<Widget>(
      GraftScopeGuard.run(
        widget.graft,
        'graft.slot',
        () => widget.builder(widget.graft.state),
      ),
    );
    widget.graft.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (!mounted) return;
    final oldWidget = _slotNotifier.value;
    final newWidget = GraftScopeGuard.run(
      widget.graft,
      'graft.slot',
      () => widget.builder(widget.graft.state),
    );

    if (identical(oldWidget, newWidget)) return;
    if (GraftMultiChildDiffEngine.isWidgetEquivalent(oldWidget, newWidget, context)) return;

    _slotNotifier.value = newWidget;
    Graft.observer?.onSlotRebuild(widget.graft, 0, newWidget);
  }

  @override
  void reassemble() {
    super.reassemble();
    _onStateChanged();
  }

  @override
  void didUpdateWidget(covariant GraftSingleSlotScope<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChanged);
      _slotNotifier.value = GraftScopeGuard.run(
        widget.graft,
        'graft.slot',
        () => widget.builder(widget.graft.state),
      );
      widget.graft.addListener(_onStateChanged);
    } else {
      _onStateChanged();
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChanged);
    _slotNotifier.dispose();
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
          'A widget inside "${ancestorScope.caller}" is trying to observe the exact same ${widget.graft.runtimeType} with "graft.slot"!\n'
          'This creates duplicate element listeners on the same controller and degrades performance.\n\n'
          'Fix: Return widgets directly inside "${ancestorScope.caller}" without wrapping them in graft.slot().\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      return true;
    }());

    return InheritedGraftScope(
      graft: widget.graft,
      caller: 'graft.slot',
      child: ValueListenableBuilder<Widget>(
        valueListenable: _slotNotifier,
        builder: (_, child, __) => child,
      ),
    );
  }
}

/// A reactive item slot for lazy virtualized collections ([ListView.builder], [GridView.builder], [PageView.builder], etc.).
///
/// Only rebuilds when the value returned by [selector] changes.
class GraftItemSlot<S extends GraftState, T> extends StatefulWidget implements GraftEquivalent {
  /// The [Graft] instance providing state.
  final Graft<S> graft;

  /// Selector extracting the specific item slice [T] from state.
  final T Function(S state) selector;

  /// Widget builder called with the extracted [item].
  final Widget Function(BuildContext context, T item) builder;

  /// Creates a [GraftItemSlot] for fine-grained lazy item diffing.
  const GraftItemSlot({
    super.key,
    required this.graft,
    required this.selector,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftItemSlot) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftItemSlot<S, T>> createState() => _GraftItemSlotState<S, T>();
}

class _GraftItemSlotState<S extends GraftState, T> extends State<GraftItemSlot<S, T>> {
  T? _item;
  Widget? _cachedWidget;
  bool _hasInitialItem = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialItem();
    widget.graft.addListener(_onStateChange);
  }

  void _resolveInitialItem() {
    try {
      _item = widget.selector(widget.graft.state);
      _hasInitialItem = true;
    } catch (_) {
      _hasInitialItem = false;
    }
  }

  void _onStateChange() {
    if (!mounted) return;
    try {
      final nextItem = widget.selector(widget.graft.state);
      if (_hasInitialItem && (identical(_item, nextItem) || _item == nextItem)) {
        return; // 0 REBUILDS!
      }

      final nextWidget = widget.builder(context, nextItem);
      if (_cachedWidget != null &&
          (identical(_cachedWidget, nextWidget) ||
              GraftMultiChildDiffEngine.isWidgetEquivalent(_cachedWidget!, nextWidget, context))) {
        _item = nextItem;
        return; // 0 REBUILDS!
      }

      setState(() {
        _item = nextItem;
        _hasInitialItem = true;
        _cachedWidget = nextWidget;
      });
      Graft.observer?.onSlotRebuild(widget.graft, -1, nextWidget);
    } catch (_) {
      // Gracefully handle bounds exception if item was removed before element unmount
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _resolveInitialItem();
    _cachedWidget = null;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant GraftItemSlot<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChange);
      _resolveInitialItem();
      widget.graft.addListener(_onStateChange);
      _cachedWidget = null;
    } else {
      _cachedWidget = null;
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInitialItem) {
      _resolveInitialItem();
    }
    if (!_hasInitialItem) {
      return const SizedBox.shrink();
    }
    try {
      _cachedWidget ??= widget.builder(context, _item as T);
      return _cachedWidget!;
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

/// A layout-agnostic, 100% lazy virtualized collection engine with per-item slot diffing.
///
/// ### Why use GraftBuilderDiffEngine?
/// In standard Flutter, modifying an item in a list or grid inside a reactive builder
/// causes every visible item to rebuild.
/// [GraftBuilderDiffEngine] bridges any Flutter collection builder ([ListView.builder],
/// [GridView.builder], [PageView.builder], [SliverList.builder], etc.) with isolated item slots.
///
/// When an item in [itemCount] updates:
/// - Modified item: **1 rebuild** in Flutter DevTools.
/// - Unchanged items: **0 rebuilds** (evaluated via value equality & [GraftMultiChildDiffEngine.isWidgetEquivalent]).
/// - Offscreen items: 100% virtualized and recycled natively by Flutter.
class GraftBuilderDiffEngine<S extends GraftState, T> extends StatefulWidget
    implements GraftEquivalent {
  /// The [Graft] controller providing collection state.
  final Graft<S> graft;

  /// Layout builder delegating to any Flutter collection builder (e.g. [ListView.builder], [GridView.builder]).
  final Widget Function(int itemCount, NullableIndexedWidgetBuilder itemBuilder) layout;

  /// Selector extracting the current total item count.
  final int Function(S state) itemCount;

  /// Selector extracting item [T] at [index].
  final T Function(S state, int index) item;

  /// Builder for each lazy item slot.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional key provider for item slots (defaults to `ValueKey(index)`).
  final Key Function(T item)? itemKey;

  /// Creates a [GraftBuilderDiffEngine].
  const GraftBuilderDiffEngine({
    super.key,
    required this.graft,
    required this.layout,
    required this.itemCount,
    required this.item,
    required this.itemBuilder,
    this.itemKey,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftBuilderDiffEngine) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftBuilderDiffEngine<S, T>> createState() =>
      _GraftBuilderDiffEngineState<S, T>();
}

class _GraftBuilderDiffEngineState<S extends GraftState, T>
    extends State<GraftBuilderDiffEngine<S, T>> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.itemCount(widget.graft.state);
    widget.graft.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (!mounted) return;
    final nextCount = widget.itemCount(widget.graft.state);
    if (_count != nextCount) {
      setState(() {
        _count = nextCount;
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _count = widget.itemCount(widget.graft.state);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant GraftBuilderDiffEngine<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChange);
      _count = widget.itemCount(widget.graft.state);
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
    Widget? engineItemBuilder(BuildContext context, int index) {
      if (index < 0 || index >= _count) return null;
      return GraftItemSlot<S, T>(
        key: widget.itemKey != null
            ? widget.itemKey!(widget.item(widget.graft.state, index))
            : ValueKey(index),
        graft: widget.graft,
        selector: (s) {
          final count = widget.itemCount(s);
          if (index < 0 || index >= count) {
            throw RangeError.index(index, count);
          }
          return widget.item(s, index);
        },
        builder: (ctx, item) => widget.itemBuilder(ctx, item, index),
      );
    }

    final layoutWidget = widget.layout(_count, engineItemBuilder);

    assert(() {
      _verifyBuilderContract(layoutWidget, _count, engineItemBuilder);
      return true;
    }());

    return layoutWidget;
  }

  static void _verifyBuilderContract(
    Widget rootWidget,
    int expectedCount,
    NullableIndexedWidgetBuilder expectedBuilder,
  ) {
    Widget? current = rootWidget;
    SliverChildDelegate? delegate;

    while (current != null && delegate == null) {
      if (current is ListView) {
        delegate = current.childrenDelegate;
        break;
      } else if (current is GridView) {
        delegate = current.childrenDelegate;
        break;
      } else if (current is PageView) {
        delegate = current.childrenDelegate;
        break;
      } else if (current is SliverMultiBoxAdaptorWidget) {
        delegate = current.delegate;
        break;
      }

      // Try unwrapping single child widgets (Scrollbar, RefreshIndicator, Padding, Container, etc.)
      Widget? next;
      if (current is SingleChildRenderObjectWidget) {
        next = current.child;
      } else if (current is Container) {
        next = current.child;
      } else {
        try {
          final dynamic dynamicWidget = current;
          final child = dynamicWidget.child;
          if (child is Widget) {
            next = child;
          }
        } catch (_) {}
      }

      if (next == null || identical(next, current)) {
        break;
      }
      current = next;
    }

    if (delegate is SliverChildBuilderDelegate) {
      if (!identical(delegate.builder, expectedBuilder)) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ERROR: UNUSED itemBuilder IN graft.builder()\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'In graft.builder((itemCount, itemBuilder) => ...), the provided "itemBuilder"\n'
          'was NOT passed to your collection widget (${current?.runtimeType ?? rootWidget.runtimeType})!\n\n'
          'Why this is an error:\n'
          'Graft requires the provided "itemBuilder" to wrap each visible item in an isolated\n'
          'GraftItemSlot for 100% lazy virtualization and 1-rebuild performance.\n\n'
          'Fix:\n'
          'Pass the provided "itemBuilder" directly into your collection widget:\n'
          '  graft.builder(\n'
          '    (itemCount, itemBuilder) => ${current?.runtimeType ?? 'ListView'}.builder(\n'
          '      itemCount: itemCount,\n'
          '      itemBuilder: itemBuilder, // ✅ Pass the provided itemBuilder here!\n'
          '    ),\n'
          '    items: (s) => ...,\n'
          '    itemBuilder: (context, item, index) => ...,\n'
          '  )\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }

      if (delegate.childCount != null && delegate.childCount != expectedCount) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ERROR: MISMATCHED itemCount IN graft.builder()\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'The collection widget (${current?.runtimeType ?? rootWidget.runtimeType}) was created with itemCount: ${delegate.childCount},\n'
          'but the engine provided itemCount: $expectedCount.\n\n'
          'Fix:\n'
          'Pass the provided "itemCount" directly:\n'
          '  graft.builder(\n'
          '    (itemCount, itemBuilder) => ${current?.runtimeType ?? 'ListView'}.builder(\n'
          '      itemCount: itemCount, // ✅ Use provided itemCount\n'
          '      itemBuilder: itemBuilder,\n'
          '    ),\n'
          '    items: (s) => ...,\n'
          '    itemBuilder: (context, item, index) => ...,\n'
          '  )\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
    }
  }
}


/// Internal guard that tracks active builder executions to detect and prevent anti-pattern nesting.
abstract final class GraftScopeGuard {
  static final Set<Graft> _activeBuilders = {};
  static final Map<Graft, String> _activeCallers = {};

  /// Runs [action] within the registered scope of [caller] on [graft].
  ///
  /// Throws a descriptive [FlutterError] in debug mode if [graft] is already being built
  /// by another builder.
  static R run<R>(Graft graft, String caller, R Function() action) {
    assert(() {
      if (_activeBuilders.contains(graft)) {
        final existing = _activeCallers[graft] ?? 'another builder';
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: REDUNDANT NESTING ON ${graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'You called "$caller" directly inside the builder of "$existing" for the exact same ${graft.runtimeType} instance!\n\n'
          'Why this is a problem:\n'
          '1. In "$existing", children/slots are already isolated or observed.\n'
          '2. Nesting another builder on the same Graft creates duplicate listeners, thrashes widget state, and degrades performance.\n\n'
          'How to fix:\n'
          '• Inside graft.slots:\n'
          '  Simply return normal widgets without wrapping them in graft.slot().\n'
          '  Example:\n'
          '    graft.slots(\n'
          '      layout: (children) => Column(children: children),\n'
          '      children: (s) => [\n'
          '        Text(s.name), // ✅ Return directly!\n'
          '      ],\n'
          '    )\n'
          '• Inside graft.compute:\n'
          '  Do not use graft.slot() inside compute, as compute already isolates the builder.\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      _activeBuilders.add(graft);
      _activeCallers[graft] = caller;
      return true;
    }());

    try {
      return action();
    } finally {
      assert(() {
        _activeBuilders.remove(graft);
        _activeCallers.remove(graft);
        return true;
      }());
    }
  }

  /// Verifies that [graft] is not currently inside an active builder when [caller] is invoked.
  static void verifyNotActive(Graft graft, String caller) {
    assert(() {
      if (_activeBuilders.contains(graft)) {
        final existing = _activeCallers[graft] ?? 'another builder';
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: REDUNDANT NESTING ON ${graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'You called "$caller" directly inside the builder of "$existing" for the exact same ${graft.runtimeType} instance!\n\n'
          'Why this is a problem:\n'
          '1. In "$existing", children/slots are already isolated or observed.\n'
          '2. Nesting another builder on the same Graft creates duplicate listeners, thrashes widget state, and degrades performance.\n\n'
          'How to fix:\n'
          '• Inside graft.slots:\n'
          '  Simply return normal widgets without wrapping them in graft.slot().\n'
          '  Example:\n'
          '    graft.slots(\n'
          '      layout: (children) => Column(children: children),\n'
          '      children: (s) => [\n'
          '        Text(s.name), // ✅ Return directly!\n'
          '      ],\n'
          '    )\n'
          '• Inside graft.compute:\n'
          '  Do not use graft.slot() inside compute, as compute already isolates the builder.\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      return true;
    }());
  }
}

/// An internal [InheritedWidget] to detect duplicate Graft slot scopes in the element tree.
class InheritedGraftScope extends InheritedWidget {
  /// The [Graft] instance providing state to this scope.
  final Graft graft;

  /// The caller identifier (e.g. 'graft.slots', 'graft.slot', 'graft.compute').
  final String caller;

  /// Creates an [InheritedGraftScope] wrapping [child].
  const InheritedGraftScope({
    super.key,
    required this.graft,
    required this.caller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedGraftScope oldWidget) =>
      oldWidget.graft != graft || oldWidget.caller != caller;
}

