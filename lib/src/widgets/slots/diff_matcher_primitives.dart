part of '../child_slot_engine.dart';

bool _diffMatchPrimitives(
  Widget a,
  Widget b, [
  BuildContext? context,
  Set<Widget>? visited,
]) {
  if (a is Text && b is Text) {
    return a.data == b.data &&
        a.style == b.style &&
        a.textAlign == b.textAlign &&
        a.maxLines == b.maxLines &&
        a.overflow == b.overflow;
  }

  if (a is RichText && b is RichText) {
    return a.text == b.text &&
        a.textAlign == b.textAlign &&
        a.maxLines == b.maxLines &&
        a.overflow == b.overflow;
  }

  if (a is Icon && b is Icon) {
    return a.icon == b.icon &&
        a.size == b.size &&
        a.color == b.color &&
        a.semanticLabel == b.semanticLabel;
  }

  if (a is SizedBox && b is SizedBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.width == b.width && a.height == b.height;
  }

  if (a is Padding && b is Padding) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.padding == b.padding;
  }

  if (a is Container && b is Container) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    if (!childEqual) return false;

    return a.color == b.color &&
        a.padding == b.padding &&
        a.margin == b.margin &&
        a.alignment == b.alignment &&
        a.decoration == b.decoration &&
        a.constraints == b.constraints &&
        a.clipBehavior == b.clipBehavior;
  }

  if (a is ColoredBox && b is ColoredBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.color == b.color;
  }

  if (a is Align && b is Align) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual &&
        a.alignment == b.alignment &&
        a.widthFactor == b.widthFactor &&
        a.heightFactor == b.heightFactor;
  }

  if (a is DecoratedBox && b is DecoratedBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual &&
        a.decoration == b.decoration &&
        a.position == b.position;
  }

  if (a is Opacity && b is Opacity) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.opacity == b.opacity;
  }

  if (a is ClipRRect && b is ClipRRect) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual &&
        a.borderRadius == b.borderRadius &&
        a.clipBehavior == b.clipBehavior;
  }

  if (a is ShaderMask && b is ShaderMask) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.blendMode == b.blendMode;
  }

  if (a is DefaultTextStyle && b is DefaultTextStyle) {
    return a.style == b.style &&
        a.textAlign == b.textAlign &&
        GraftMultiChildDiffEngine.isWidgetEquivalent(
            a.child, b.child, context, visited);
  }

  return false;
}

