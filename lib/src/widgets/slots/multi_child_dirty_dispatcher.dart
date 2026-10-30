part of '../child_slot_engine.dart';

void _onMultiChildStateDirty<S extends GraftState>(
  _GraftMultiChildDiffEngineState<S> state,
  GraftMask dirtyMask,
) {
  if (!state.mounted) return;

  if (dirtyMask.isNotEmpty &&
      !dirtyMask.isAllDirty &&
      state._slotTable.isNotEmpty) {
    if (state._commonIgnoredMask.isNotEmpty &&
        dirtyMask.isSubsetOf(state._commonIgnoredMask)) {
      return;
    }
    if (state._slotTable.every((s) =>
        s.ignoredMask.isNotEmpty && dirtyMask.isSubsetOf(s.ignoredMask))) {
      state._commonIgnoredMask = state._commonIgnoredMask.union(dirtyMask);
      return;
    }
  }

  final newWidgets = state.widget.slots(state.widget.graft.state);

  if (newWidgets.length == state._slotTable.length) {
    final len = newWidgets.length;
    for (int i = 0; i < len; i++) {
      final slot = state._slotTable[i];
      if (!dirtyMask.isAllDirty &&
          slot.ignoredMask.isNotEmpty &&
          dirtyMask.isSubsetOf(slot.ignoredMask)) {
        continue;
      }

      final oldWidget = slot.currentWidget;
      final newWidget = newWidgets[i];
      if (identical(oldWidget, newWidget)) continue;

      if (GraftMultiChildDiffEngine.isWidgetEquivalent(
          oldWidget, newWidget, state.context)) {
        if (dirtyMask.isNotEmpty && !dirtyMask.isAllDirty) {
          final single = dirtyMask.singleBitIndex;
          if (single != null) {
            slot.ignoredMask = slot.ignoredMask.withBit(single);
          } else {
            slot.ignoredMask = slot.ignoredMask.union(dirtyMask);
          }
        }
        continue;
      }

      slot.ignoredMask = GraftMask.empty;
      state._commonIgnoredMask = GraftMask.empty;
      if (Graft.observer != null) {
        slot.contentFingerprint = SlotMetadata.computeFingerprint(newWidget);
      }
      slot.rebuildCount++;
      slot.updateWidget(newWidget);
      Graft.observer?.onSlotRebuild(state.widget.graft, slot.slotIndex, newWidget);

      if (dirtyMask.isNotEmpty && !dirtyMask.isAllDirty) {
        final singleField = dirtyMask.singleBitIndex;
        if (singleField != null) {
          slot.fieldDependenciesMask =
              slot.fieldDependenciesMask.withBit(singleField);
        } else if (slot.fieldDependenciesMask.isEmpty) {
          slot.fieldDependenciesMask = dirtyMask;
        }
      }
    }
    return;
  }

  _reconcileDynamicSlots(state, newWidgets, dirtyMask);
}

