part of '../child_slot_engine.dart';

void _singleSlotVerifyAncestors(Element element, Graft graft, String caller) {
  element.visitAncestorElements((ancestor) {
    if (ancestor is _GraftSingleSlotElement &&
        identical(ancestor.widget.graft, graft)) {
      throw FlutterError(
        '\n════════════════════════════════════════════════════════════════════════════════\n'
        '⚠️ GRAFT ANTI-PATTERN DETECTED: NESTED ELEMENT TREE SCOPE ON ${graft.runtimeType}\n'
        '════════════════════════════════════════════════════════════════════════════════\n'
        'A widget inside "${ancestor.widget.caller}" is trying to observe the exact same ${graft.runtimeType} with "$caller"!\n'
        'This creates duplicate element listeners on the same controller and degrades performance.\n\n'
        'Fix: Return widgets directly inside "${ancestor.widget.caller}" without wrapping them in $caller().\n'
        '════════════════════════════════════════════════════════════════════════════════\n',
      );
    }
    if (ancestor is StatefulElement &&
        ancestor.state is _GraftMultiChildDiffEngineState) {
      final diffEngine =
          (ancestor.state as _GraftMultiChildDiffEngineState).widget;
      if (identical(diffEngine.graft, graft)) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: NESTED ELEMENT TREE SCOPE ON ${graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'A widget inside "graft.slots" is trying to observe the exact same ${graft.runtimeType} with "$caller"!\n'
          'This creates duplicate element listeners on the same controller and degrades performance.\n\n'
          'Fix: Return widgets directly inside "graft.slots" without wrapping them in $caller().\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
    }
    return true;
  });
}

void _singleSlotOnMaskDirty<S extends GraftState>(_GraftSingleSlotElement<S> element, GraftMask dirtyMask) {
  if (!element.mounted) return;

  if (!dirtyMask.isAllDirty) {
    if (element._ignoredMask.isNotEmpty && dirtyMask.isSubsetOf(element._ignoredMask)) {
      return;
    }
  }

  if (element.widget.caller != 'graft.async' &&
      !dirtyMask.isAllDirty &&
      dirtyMask.isNotEmpty &&
      GraftStateEngine.hasAsyncProps(element._graft.state)) {
    final props = GraftStateEngine.props(element._graft.state);
    bool allAsync = true;
    for (int i = 0; i < props.length; i++) {
      if (dirtyMask.isBitSet(i)) {
        if (props[i] is! GraftAsync) {
          allAsync = false;
          break;
        }
      }
    }
    if (allAsync) return;
  }

  final oldWidget = element._currentWidget;
  final newWidget = element._builder(element._graft.state);

  if (identical(oldWidget, newWidget)) return;

  if (GraftMultiChildDiffEngine.isWidgetEquivalent(oldWidget, newWidget, element)) {
    if (dirtyMask.isNotEmpty && !dirtyMask.isAllDirty) {
      final single = dirtyMask.singleBitIndex;
      if (single != null) {
        element._ignoredMask = element._ignoredMask.withBit(single);
      } else {
        element._ignoredMask = element._ignoredMask.union(dirtyMask);
      }
    }
    return;
  }

  element._ignoredMask = GraftMask.empty;
  element._isDirty = false;
  element._currentWidget = newWidget;
  element.markNeedsBuild();
  Graft.observer?.onSlotRebuild(element._graft, 0, newWidget);
}
