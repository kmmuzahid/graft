part of '../child_slot_engine.dart';

void _verifyBuilderContract(
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

    Widget? next;
    if (current is SingleChildRenderObjectWidget) {
      next = current.child;
    } else if (current is Container) {
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

  if (delegate is SliverChildBuilderDelegate) {
    if (!identical(delegate.builder, expectedBuilder)) {
      throw FlutterError(
        '\n════════════════════════════════════════════════════════════════════════════════\n'
        '⚠️ GRAFT ERROR: UNUSED itemBuilder IN graft.builder()\n'
        '════════════════════════════════════════════════════════════════════════════════\n'
        'In graft.builder((itemCount, itemBuilder) => ...), the provided "itemBuilder"\n'
        'was NOT passed to your collection widget (${current?.runtimeType ?? rootWidget.runtimeType})!\n\n'
        'Fix:\n'
        'Pass the provided "itemBuilder" directly into your collection widget:\n'
        '  graft.builder(\n'
        '    (itemCount, itemBuilder) => ${current?.runtimeType ?? 'ListView'}.builder(\n'
        '      itemCount: itemCount,\n'
        '      itemBuilder: itemBuilder,\n'
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
        '      itemCount: itemCount,\n'
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

