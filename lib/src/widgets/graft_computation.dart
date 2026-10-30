part of 'graft_widgets.dart';

class _GraftComputation<S extends GraftState, R> extends StatefulWidget
    implements GraftEquivalent {
  final Graft<S> graft;
  final R Function(S state) computation;
  final Widget Function(R value) builder;

  const _GraftComputation({
    super.key,
    required this.graft,
    required this.computation,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! _GraftComputation) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<_GraftComputation<S, R>> createState() =>
      _GraftComputationState<S, R>();
}

class _GraftComputationState<S extends GraftState, R>
    extends State<_GraftComputation<S, R>> {
  late R _computedValue;

  @override
  void initState() {
    super.initState();
    _computedValue = GraftScopeGuard.run(
      widget.graft,
      'graft.compute',
      () => widget.computation(widget.graft.state),
    );
    widget.graft.addListener(_onStateChange);
  }

  void _onStateChange() {
    final newValue = GraftScopeGuard.run(
      widget.graft,
      'graft.compute',
      () => widget.computation(widget.graft.state),
    );
    if (_computedValue != newValue) {
      setState(() {
        _computedValue = newValue;
      });
      Graft.observer?.onSlotRebuild(widget.graft, 0, widget.builder(newValue));
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _onStateChange();
  }

  @override
  void didUpdateWidget(covariant _GraftComputation<S, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChange);
      _computedValue = GraftScopeGuard.run(
        widget.graft,
        'graft.compute',
        () => widget.computation(widget.graft.state),
      );
      widget.graft.addListener(_onStateChange);
    } else {
      _onStateChange();
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      final ancestorScope =
          context.getInheritedWidgetOfExactType<InheritedGraftScope>();
      if (ancestorScope != null &&
          identical(ancestorScope.graft, widget.graft)) {
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: NESTED ELEMENT TREE SCOPE ON ${widget.graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'A widget inside "${ancestorScope.caller}" is trying to observe the exact same ${widget.graft.runtimeType} with "graft.compute"!\n'
          'This creates duplicate element listeners on the same controller and degrades performance.\n\n'
          'Fix: Use the value directly inside "${ancestorScope.caller}" without wrapping it in graft.compute().\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      return true;
    }());

    return InheritedGraftScope(
      graft: widget.graft,
      caller: 'graft.compute',
      child: widget.builder(_computedValue),
    );
  }
}

