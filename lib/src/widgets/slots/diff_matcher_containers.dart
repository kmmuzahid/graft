part of '../child_slot_engine.dart';

bool _diffMatchContainers(
  Widget a,
  Widget b, [
  BuildContext? context,
  Set<Widget>? visited,
]) {
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
      if (!GraftMultiChildDiffEngine.isWidgetEquivalent(
          a.children[i], b.children[i], context, visited)) {
        return false;
      }
    }
    return true;
  }

  if (a is Flexible && b is Flexible) {
    final childEqual =
        GraftMultiChildDiffEngine.isWidgetEquivalent(a.child, b.child, context, visited);
    return childEqual && a.flex == b.flex && a.fit == b.fit;
  }

  if (a is FittedBox && b is FittedBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual &&
        a.fit == b.fit &&
        a.alignment == b.alignment &&
        a.clipBehavior == b.clipBehavior;
  }

  if (a is ConstrainedBox && b is ConstrainedBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.constraints == b.constraints;
  }

  if (a is AspectRatio && b is AspectRatio) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual && a.aspectRatio == b.aspectRatio;
  }

  if (a is FractionallySizedBox && b is FractionallySizedBox) {
    final childEqual = (a.child == null && b.child == null) ||
        (a.child != null &&
            b.child != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                a.child!, b.child!, context, visited));
    return childEqual &&
        a.widthFactor == b.widthFactor &&
        a.heightFactor == b.heightFactor &&
        a.alignment == b.alignment;
  }

  if (a is Stack && b is Stack) {
    if (a.alignment != b.alignment ||
        a.textDirection != b.textDirection ||
        a.fit != b.fit ||
        a.clipBehavior != b.clipBehavior ||
        a.children.length != b.children.length) {
      return false;
    }
    for (int i = 0; i < a.children.length; i++) {
      if (!GraftMultiChildDiffEngine.isWidgetEquivalent(
          a.children[i], b.children[i], context, visited)) {
        return false;
      }
    }
    return true;
  }

  if (a is Positioned && b is Positioned) {
    final childEqual =
        GraftMultiChildDiffEngine.isWidgetEquivalent(a.child, b.child, context, visited);
    return childEqual &&
        a.left == b.left &&
        a.top == b.top &&
        a.right == b.right &&
        a.bottom == b.bottom &&
        a.width == b.width &&
        a.height == b.height;
  }

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
      if (!GraftMultiChildDiffEngine.isWidgetEquivalent(
          a.children[i], b.children[i], context, visited)) {
        return false;
      }
    }
    return true;
  }

  if (a is Image && b is Image) {
    return a.image == b.image &&
        a.width == b.width &&
        a.height == b.height &&
        a.fit == b.fit &&
        a.alignment == b.alignment &&
        a.color == b.color;
  }

  if (a is ProgressIndicator && b is ProgressIndicator) {
    return a.value == b.value &&
        a.color == b.color &&
        a.backgroundColor == b.backgroundColor;
  }

  return false;
}

