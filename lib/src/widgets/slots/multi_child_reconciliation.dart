part of '../child_slot_engine.dart';

void _reconcileDynamicSlots(
  _GraftMultiChildDiffEngineState state,
  List<Widget> newWidgets,
  GraftMask dirtyMask,
) {
  final oldSlots = List<SlotMetadata?>.from(state._slotTable);
  final reconciled = List<SlotMetadata?>.filled(newWidgets.length, null);

  // Pass 1: Match by explicit Key
  for (int i = 0; i < newWidgets.length; i++) {
    final newKey = newWidgets[i].key;
    if (newKey != null) {
      for (int j = 0; j < oldSlots.length; j++) {
        final oldSlot = oldSlots[j];
        if (oldSlot != null && oldSlot.currentWidget.key == newKey) {
          reconciled[i] = oldSlot;
          oldSlots[j] = null;
          break;
        }
      }
    }
  }

  // Pass 2: Match by exact content equivalence
  for (int i = 0; i < newWidgets.length; i++) {
    if (reconciled[i] == null) {
      for (int j = 0; j < oldSlots.length; j++) {
        final oldSlot = oldSlots[j];
        if (oldSlot != null &&
            GraftMultiChildDiffEngine.isWidgetEquivalent(
                oldSlot.currentWidget, newWidgets[i], state.context)) {
          reconciled[i] = oldSlot;
          oldSlots[j] = null;
          break;
        }
      }
    }
  }

  // Pass 3: Match by runtimeType
  for (int i = 0; i < newWidgets.length; i++) {
    if (reconciled[i] == null) {
      for (int j = 0; j < oldSlots.length; j++) {
        final oldSlot = oldSlots[j];
        if (oldSlot != null &&
            oldSlot.currentWidget.runtimeType == newWidgets[i].runtimeType) {
          reconciled[i] = oldSlot;
          oldSlots[j] = null;
          break;
        }
      }
    }
  }

  // Pass 4: Build new slots or update matched slots
  for (int i = 0; i < newWidgets.length; i++) {
    final matchedSlot = reconciled[i];
    if (matchedSlot == null) {
      reconciled[i] = SlotMetadata(
        slotIndex: i,
        isStatic: false,
        widgetType: newWidgets[i].runtimeType,
        contentFingerprint: SlotMetadata.computeFingerprint(newWidgets[i]),
        initialWidget: newWidgets[i],
        graft: state.widget.graft,
      );
    } else {
      matchedSlot.slotIndex = i;
      if (!GraftMultiChildDiffEngine.isWidgetEquivalent(
          matchedSlot.currentWidget, newWidgets[i], state.context)) {
        matchedSlot.ignoredMask = GraftMask.empty;
        if (Graft.observer != null) {
          matchedSlot.contentFingerprint =
              SlotMetadata.computeFingerprint(newWidgets[i]);
        }
        matchedSlot.rebuildCount++;
        matchedSlot.updateWidget(newWidgets[i]);
        Graft.observer?.onSlotRebuild(
            state.widget.graft, matchedSlot.slotIndex, newWidgets[i]);

        if (dirtyMask.isNotEmpty && !dirtyMask.isAllDirty) {
          final singleField = dirtyMask.singleBitIndex;
          if (singleField != null) {
            matchedSlot.fieldDependenciesMask =
                matchedSlot.fieldDependenciesMask.withBit(singleField);
          } else if (matchedSlot.fieldDependenciesMask.isEmpty) {
            matchedSlot.fieldDependenciesMask = dirtyMask;
          }
        }
      }
    }
  }

  // Pass 5: Dispose unmatched old slots
  for (final oldSlot in oldSlots) {
    if (oldSlot != null) {
      if (oldSlot.isStatic) {
        oldSlot.notifier.detachElement();
      }
      oldSlot.dispose();
    }
  }

  // Pass 6: Assemble updated wrapped children and trigger parent layout update
  state._slotTable = reconciled.cast<SlotMetadata>();
  state._wrappedChildren = List.generate(
    state._slotTable.length,
    (i) => _ChildSlotScope(
      key: state._slotTable[i].currentWidget.key ?? ObjectKey(state._slotTable[i]),
      slot: state._slotTable[i],
    ),
    growable: true,
  );

  state._setStateTrigger();
}

