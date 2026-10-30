part of '../child_slot_engine.dart';

Widget _resolveMultiChildLayout(dynamic layout, List<Widget> children) {
  if (layout is Widget Function(List<Widget>)) {
    return layout(children);
  }
  if (layout is Column) {
    return Column(
      key: layout.key,
      mainAxisAlignment: layout.mainAxisAlignment,
      mainAxisSize: layout.mainAxisSize,
      crossAxisAlignment: layout.crossAxisAlignment,
      textDirection: layout.textDirection,
      verticalDirection: layout.verticalDirection,
      textBaseline: layout.textBaseline,
      children: children,
    );
  }
  if (layout is Row) {
    return Row(
      key: layout.key,
      mainAxisAlignment: layout.mainAxisAlignment,
      mainAxisSize: layout.mainAxisSize,
      crossAxisAlignment: layout.crossAxisAlignment,
      textDirection: layout.textDirection,
      verticalDirection: layout.verticalDirection,
      textBaseline: layout.textBaseline,
      children: children,
    );
  }
  if (layout is Stack) {
    return Stack(
      key: layout.key,
      alignment: layout.alignment,
      textDirection: layout.textDirection,
      fit: layout.fit,
      clipBehavior: layout.clipBehavior,
      children: children,
    );
  }
  if (layout is Wrap) {
    return Wrap(
      key: layout.key,
      direction: layout.direction,
      alignment: layout.alignment,
      spacing: layout.spacing,
      runAlignment: layout.runAlignment,
      runSpacing: layout.runSpacing,
      crossAxisAlignment: layout.crossAxisAlignment,
      textDirection: layout.textDirection,
      verticalDirection: layout.verticalDirection,
      clipBehavior: layout.clipBehavior,
      children: children,
    );
  }
  if (layout is Flex) {
    return Flex(
      key: layout.key,
      direction: layout.direction,
      mainAxisAlignment: layout.mainAxisAlignment,
      mainAxisSize: layout.mainAxisSize,
      crossAxisAlignment: layout.crossAxisAlignment,
      textDirection: layout.textDirection,
      verticalDirection: layout.verticalDirection,
      textBaseline: layout.textBaseline,
      clipBehavior: layout.clipBehavior,
      children: children,
    );
  }
  if (layout is ListView &&
      layout.childrenDelegate is SliverChildListDelegate) {
    final delegate = layout.childrenDelegate as SliverChildListDelegate;
    return ListView(
      key: layout.key,
      scrollDirection: layout.scrollDirection,
      reverse: layout.reverse,
      controller: layout.controller,
      primary: layout.primary,
      physics: layout.physics,
      shrinkWrap: layout.shrinkWrap,
      padding: layout.padding,
      itemExtent: layout.itemExtent,
      prototypeItem: layout.prototypeItem,
      addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
      addRepaintBoundaries: delegate.addRepaintBoundaries,
      addSemanticIndexes: delegate.addSemanticIndexes,
      clipBehavior: layout.clipBehavior,
      dragStartBehavior: layout.dragStartBehavior,
      keyboardDismissBehavior: layout.keyboardDismissBehavior,
      restorationId: layout.restorationId,
      children: children,
    );
  }
  if (layout is Widget) {
    throw FlutterError(
      'Direct widget layout "${layout.runtimeType}" cannot be auto-cloned.\n'
      'For custom layouts, use a builder function: layout: (children) => ${layout.runtimeType}(children: children)',
    );
  }
  throw ArgumentError('Invalid layout parameter in graft.slots: $layout');
}

void _verifyMultiChildSlotsContract(Widget rootWidget, List<Widget> expectedChildren) {
  Widget? current = rootWidget;
  List<Widget>? actualChildren;

  while (current != null && actualChildren == null) {
    if (current is MultiChildRenderObjectWidget) {
      actualChildren = current.children;
      break;
    } else if (current is ListView &&
        current.childrenDelegate is SliverChildListDelegate) {
      actualChildren = (current.childrenDelegate as SliverChildListDelegate).children;
      break;
    } else if (current is GridView &&
        current.childrenDelegate is SliverChildListDelegate) {
      actualChildren = (current.childrenDelegate as SliverChildListDelegate).children;
      break;
    }

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
        if (child is Widget) next = child;
      } catch (_) {}
    }

    if (next == null || identical(next, current)) break;
    current = next;
  }

  if (actualChildren != null && expectedChildren.isNotEmpty) {
    final containsSlots = actualChildren.any((c) => expectedChildren.contains(c));
    if (!containsSlots) {
      throw FlutterError(
        '\n════════════════════════════════════════════════════════════════════════════════\n'
        '⚠️ GRAFT ERROR: UNUSED children IN graft.slots()\n'
        '════════════════════════════════════════════════════════════════════════════════\n'
        'In graft.slots((children) => ...), the provided "children" list was NOT passed\n'
        'to your layout widget (${current?.runtimeType ?? rootWidget.runtimeType})!\n\n'
        'Fix:\n'
        'Pass the provided "children" list directly into your layout widget:\n'
        '  graft.slots(\n'
        '    (children) => ${current?.runtimeType ?? 'Column'}(children: children),\n'
        '    [ ... ],\n'
        '  )\n'
        '════════════════════════════════════════════════════════════════════════════════\n',
      );
    }
  }
}

