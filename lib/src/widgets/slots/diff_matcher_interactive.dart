part of '../child_slot_engine.dart';

bool _diffMatchInteractive(
  Widget a,
  Widget b, [
  BuildContext? context,
  Set<Widget>? visited,
]) {
  if (a is GestureDetector && b is GestureDetector) {
    final bothTapActive = (a.onTap != null) == (b.onTap != null);
    final bothDoubleTapActive = (a.onDoubleTap != null) == (b.onDoubleTap != null);
    final bothLongPressActive = (a.onLongPress != null) == (b.onLongPress != null);
    final behaviorEqual = a.behavior == b.behavior;
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return bothTapActive &&
        bothDoubleTapActive &&
        bothLongPressActive &&
        behaviorEqual &&
        childEqual;
  }

  if (a is InkWell && b is InkWell) {
    final bothTapActive = (a.onTap != null) == (b.onTap != null);
    final bothDoubleTapActive = (a.onDoubleTap != null) == (b.onDoubleTap != null);
    final bothLongPressActive = (a.onLongPress != null) == (b.onLongPress != null);
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return bothTapActive &&
        bothDoubleTapActive &&
        bothLongPressActive &&
        childEqual &&
        a.borderRadius == b.borderRadius;
  }

  if (a is ButtonStyleButton && b is ButtonStyleButton) {
    final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
    final bothLongPress = (a.onLongPress != null) == (b.onLongPress != null);
    final styleEqual = a.style == b.style;
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return bothEnabled && bothLongPress && styleEqual && childEqual;
  }

  if (a is IconButton && b is IconButton) {
    final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
    final iconEqual =
        GraftMultiChildDiffEngine.isWidgetEquivalent(a.icon, b.icon, context, visited);
    return bothEnabled &&
        iconEqual &&
        a.color == b.color &&
        a.iconSize == b.iconSize;
  }

  if (a is CupertinoButton && b is CupertinoButton) {
    final bothEnabled = (a.onPressed != null) == (b.onPressed != null);
    final childEqual =
        GraftMultiChildDiffEngine.isWidgetEquivalent(a.child, b.child, context, visited);
    return bothEnabled && childEqual && a.color == b.color;
  }

  if (a is ListTile && b is ListTile) {
    final bothTapActive = (a.onTap != null) == (b.onTap != null);
    final bothLongPress = (a.onLongPress != null) == (b.onLongPress != null);
    final titleEqual = (a.title == null && b.title == null) ||
        (a.title != null &&
            b.title != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.title!, b.title!, context, visited));
    final leadingEqual = (a.leading == null && b.leading == null) ||
        (a.leading != null &&
            b.leading != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.leading!, b.leading!, context, visited));
    final subtitleEqual = (a.subtitle == null && b.subtitle == null) ||
        (a.subtitle != null &&
            b.subtitle != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.subtitle!, b.subtitle!, context, visited));
    final trailingEqual = (a.trailing == null && b.trailing == null) ||
        (a.trailing != null &&
            b.trailing != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.trailing!, b.trailing!, context, visited));
    return bothTapActive &&
        bothLongPress &&
        titleEqual &&
        leadingEqual &&
        subtitleEqual &&
        trailingEqual;
  }

  if (a is Checkbox && b is Checkbox) {
    return a.value == b.value &&
        (a.onChanged != null) == (b.onChanged != null) &&
        a.activeColor == b.activeColor &&
        a.checkColor == b.checkColor;
  }

  if (a is Switch && b is Switch) {
    return a.value == b.value &&
        (a.onChanged != null) == (b.onChanged != null) &&
        a.activeThumbColor == b.activeThumbColor &&
        a.activeTrackColor == b.activeTrackColor;
  }

  if (a is Slider && b is Slider) {
    return a.value == b.value &&
        (a.onChanged != null) == (b.onChanged != null) &&
        a.min == b.min &&
        a.max == b.max &&
        a.activeColor == b.activeColor;
  }

  if (context != null &&
      a is StatelessWidget &&
      b is StatelessWidget &&
      a is! Builder &&
      a.runtimeType == b.runtimeType) {
    if (a.key != null && b.key != null && a.key == b.key) {
      return true;
    }
    visited ??= <Widget>{};
    if (!visited.contains(a) && !visited.contains(b)) {
      visited.add(a);
      visited.add(b);
      try {
        final safeContext = context is NoSubscriptionContext
            ? context
            : NoSubscriptionContext(context);
        final builtA = (a as dynamic).build(safeContext);
        final builtB = (b as dynamic).build(safeContext);
        if (builtA is Widget && builtB is Widget) {
          return GraftMultiChildDiffEngine.isWidgetEquivalent(builtA, builtB, safeContext, visited);
        }
      } catch (_) {}
    }
  }

  return false;
}

