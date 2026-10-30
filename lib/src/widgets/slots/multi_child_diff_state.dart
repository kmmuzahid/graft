part of '../child_slot_engine.dart';

class _GraftMultiChildDiffEngineState<S extends GraftState>
    extends State<GraftMultiChildDiffEngine<S>> {
  late List<SlotMetadata> _slotTable;
  late List<Widget> _wrappedChildren;
  bool _contractVerified = false;
  GraftMask _commonIgnoredMask = GraftMask.empty;

  void _setStateTrigger() => setState(() {});

  @visibleForTesting
  List<ValueNotifier<Widget>> get slotNotifiers =>
      _slotTable.map((s) => s.notifier).toList();

  @visibleForTesting
  List<SlotMetadata> get slotTable => _slotTable;

  @override
  void initState() {
    super.initState();
    _initSlots();
    widget.graft.addMaskListener(_onStateDirty);
  }

  void _initSlots() {
    final initialWidgets = GraftScopeGuard.run(
      widget.graft,
      'graft.slots',
      () => widget.slots(widget.graft.state),
    );
    _slotTable = List.generate(
      initialWidgets.length,
      (i) {
        final w = initialWidgets[i];
        return SlotMetadata(
          slotIndex: i,
          isStatic: false,
          widgetType: w.runtimeType,
          contentFingerprint: SlotMetadata.computeFingerprint(w),
          initialWidget: w,
          graft: widget.graft,
        );
      },
      growable: true,
    );
    _wrappedChildren = List.generate(
      _slotTable.length,
      (i) => _ChildSlotScope(
        key: _slotTable[i].currentWidget.key ?? ObjectKey(_slotTable[i]),
        slot: _slotTable[i],
      ),
      growable: true,
    );
  }

  void _disposeSlots() {
    for (final slot in _slotTable) {
      if (slot.isStatic) {
        slot.notifier.detachElement();
      }
      slot.dispose();
    }
    _slotTable = [];
  }

  @override
  void reassemble() {
    super.reassemble();
    _commonIgnoredMask = GraftMask.empty;
    for (final slot in _slotTable) {
      slot.ignoredMask = GraftMask.empty;
    }
    _onStateDirty(GraftMask.allDirty);
  }

  @override
  void didUpdateWidget(covariant GraftMultiChildDiffEngine<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layout != oldWidget.layout) {
      _contractVerified = false;
    }

    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeMaskListener(_onStateDirty);
      _disposeSlots();
      _initSlots();
      widget.graft.addMaskListener(_onStateDirty);
      return;
    }

    _onStateDirty(GraftMask.allDirty);
  }

  void _onStateDirty(GraftMask dirtyMask) =>
      _onMultiChildStateDirty(this, dirtyMask);

  @override
  void dispose() {
    widget.graft.removeMaskListener(_onStateDirty);
    _disposeSlots();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layoutWidget = _resolveMultiChildLayout(widget.layout, _wrappedChildren);

    assert(() {
      if (!_contractVerified && _wrappedChildren.isNotEmpty) {
        _verifyMultiChildSlotsContract(layoutWidget, _wrappedChildren);
        _contractVerified = true;
      }
      return true;
    }());

    return layoutWidget;
  }
}
