part of '../child_slot_engine.dart';

/// Single-child slot diff engine. Rebuilds only when the widget returned by [builder] changes.
class GraftSingleSlotScope<S extends GraftState> extends Widget
    implements GraftEquivalent {
  final Graft<S> graft;
  final Widget Function(S state) builder;
  final String caller;

  const GraftSingleSlotScope({
    super.key, required this.graft, required this.builder, this.caller = 'graft.slot',
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftSingleSlotScope) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  Element createElement() => _GraftSingleSlotElement<S>(this);
}

class _GraftSingleSlotElement<S extends GraftState> extends ComponentElement
    implements GraftFastReceiver {
  _GraftSingleSlotElement(GraftSingleSlotScope<S> super.widget);

  @override
  GraftSingleSlotScope<S> get widget => super.widget as GraftSingleSlotScope<S>;

  late Widget Function(S state) _builder;
  late Graft<S> _graft;
  late S _state;
  late Widget _currentWidget;
  GraftMask _ignoredMask = GraftMask.empty;
  GraftMask? _pendingMask;
  bool _isDirty = false;
  bool _fastPathActive = false;
  bool _isSingleScalar = false;

  @override
  @pragma('vm:prefer-inline')
  void markFastDirty([GraftMask? mask]) {
    _isDirty = true;
    _pendingMask = mask;
    markNeedsBuild();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    final w = widget;
    _builder = w.builder;
    _graft = w.graft;
    _state = GraftEngine.getState(_graft);
    GraftStateEngine.props(_state);
    _isSingleScalar = GraftEngine.getScalarCount(_graft) == 1;
    if (!_isSingleScalar) {
      _currentWidget = GraftScopeGuard.run(
        _graft,
        w.caller,
        () => _builder(_state),
      );
    }
    super.mount(parent, newSlot);
    assert(() {
      _singleSlotVerifyAncestors(this, _graft, widget.caller);
      return true;
    }());
    _graft.addMaskListener(_onMaskDirty);
    if (!_fastPathActive && GraftEngine.canActivateFastReceiver(_graft)) {
      GraftEngine.setFastDirectReceiver(_graft, this);
      GraftEngine.setFastDirectMask(_graft, GraftMask.allDirty);
      _fastPathActive = true;
    }
  }

  @override
  void update(covariant GraftSingleSlotScope<S> newWidget) {
    final oldGraft = _graft;
    super.update(newWidget);
    _builder = newWidget.builder;
    _graft = newWidget.graft;
    _state = GraftEngine.getState(_graft);
    GraftStateEngine.props(_state);
    _isSingleScalar = GraftEngine.getScalarCount(_graft) == 1;
    if (oldGraft != _graft) {
      oldGraft.removeMaskListener(_onMaskDirty);
      if (_fastPathActive &&
          identical(GraftEngine.getFastDirectReceiver(oldGraft), this)) {
        GraftEngine.setFastDirectReceiver(oldGraft, null);
        GraftEngine.setFastDirectMask(oldGraft, GraftMask.empty);
      }
      _fastPathActive = false;
      _ignoredMask = GraftMask.empty;
      _currentWidget = GraftScopeGuard.run(
        _graft,
        newWidget.caller,
        () => _builder(_graft.state),
      );
      _graft.addMaskListener(_onMaskDirty);
      if (GraftEngine.canActivateFastReceiver(_graft)) {
        GraftEngine.setFastDirectReceiver(_graft, this);
        GraftEngine.setFastDirectMask(_graft, GraftMask.allDirty);
        _fastPathActive = true;
      }
    } else {
      _ignoredMask = GraftMask.empty;
      _onMaskDirty(GraftMask.allDirty);
    }
    _isDirty = false;
    rebuild(force: true);
  }

  @override
  void unmount() {
    _graft.removeMaskListener(_onMaskDirty);
    if (_fastPathActive &&
        identical(GraftEngine.getFastDirectReceiver(_graft), this)) {
      GraftEngine.setFastDirectReceiver(_graft, null);
      GraftEngine.setFastDirectMask(_graft, GraftMask.empty);
      _fastPathActive = false;
    }
    super.unmount();
  }

  @override
  void reassemble() {
    super.reassemble();
    _ignoredMask = GraftMask.empty;
    _isDirty = true;
    markNeedsBuild();
  }

  void _onMaskDirty(GraftMask dirtyMask) =>
      _singleSlotOnMaskDirty(this, dirtyMask);

  @override
  @pragma('vm:prefer-inline')
  Widget build() {
    if (_isSingleScalar) {
      final w = _builder(_state);
      if (Graft.observer != null) {
        Graft.observer!.onSlotRebuild(_graft, 0, w);
      }
      return w;
    }
    return _singleSlotBuild(this);
  }
}

