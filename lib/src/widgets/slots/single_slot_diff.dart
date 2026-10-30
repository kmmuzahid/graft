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

void _singleSlotOnMaskDirty<S extends GraftState>(
    _GraftSingleSlotElement<S> element, GraftMask dirtyMask) {
  if (!element.mounted) return;

  if (element._isSingleScalar) {
    element.markNeedsBuild();
    return;
  }

  if (!dirtyMask.isAllDirty) {
    if (element._ignoredMask.isNotEmpty &&
        dirtyMask.isSubsetOf(element._ignoredMask)) {
      return;
    }
  }

  if (element.widget.caller != 'graft.async' &&
      !dirtyMask.isAllDirty &&
      dirtyMask.isNotEmpty &&
      GraftStateEngine.hasAsyncProps(element._state)) {
    final props = GraftStateEngine.props(element._state);
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

  element._pendingMask = dirtyMask;
  element._isDirty = true;
  element.markNeedsBuild();
}

Widget _singleSlotBuild<S extends GraftState>(
    _GraftSingleSlotElement<S> element) {
  if (element._isDirty) {
    element._isDirty = false;
    final newWidget = element._builder(element._state);
    if (GraftMultiChildDiffEngine.isWidgetEquivalent(
        element._currentWidget, newWidget, element)) {
      final m = element._pendingMask;
      if (m != null && !m.isAllDirty && m.isNotEmpty) {
        final single = m.singleBitIndex;
        if (single != null) {
          element._ignoredMask = element._ignoredMask.withBit(single);
        } else {
          element._ignoredMask = element._ignoredMask.union(m);
        }
      }
      return element._currentWidget;
    }
    element._ignoredMask = GraftMask.empty;
    element._currentWidget = newWidget;
    Graft.observer?.onSlotRebuild(element._graft, 0, newWidget);
  }
  return element._currentWidget;
}
