import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_async.dart';
import '../core/graft_state.dart';
import '../core/value_graft.dart';
import 'child_slot_engine.dart';

part 'graft_computation.dart';
part 'graft_collection_widgets.dart';
part 'graft_value_widgets.dart';

/// Extension on [Graft<S>] providing high-performance reactive Flutter widget builders.
extension GraftWidgetsX<S extends GraftState> on Graft<S> {
  /// Creates an isolated single-child slot that diffs its content.
  Widget slot({
    required Widget Function(S state) builder,
    Key? key,
    String caller = 'graft.slot',
  }) {
    GraftScopeGuard.verifyNotActive(this, caller);
    return GraftSingleSlotScope<S>(
      key: key,
      graft: this,
      builder: builder,
      caller: caller,
    );
  }

  /// Callable syntax shortcut allowing `graft((s) => Text(s.name))` as the ultra-clean reactive entry point!
  Widget call(Widget Function(S state) builder, {Key? key}) =>
      slot(builder: builder, key: key);

  /// Creates an isolated reactive slot that declaratively pattern-matches on a [GraftAsync] state.
  Widget async<T>({
    required GraftAsync<T> Function(S state) selector,
    required Widget Function(T data) data,
    required Widget Function() loading,
    required Widget Function(Object error, StackTrace? stackTrace) error,
    Widget Function()? idle,
    Key? key,
  }) {
    return slot(
      key: key,
      caller: 'graft.async',
      builder: (s) {
        final asyncVal = selector(s);
        return asyncVal.when(
          idle: idle,
          loading: loading,
          data: data,
          error: error,
        );
      },
    );
  }

  /// Creates a reactive multi-child container whose child slots diff independently.
  Widget slots({
    required dynamic layout,
    required List<Widget> Function(S state) slots,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slots');
    return GraftMultiChildDiffEngine<S>(
      graft: this,
      layout: layout,
      slots: slots,
    );
  }

  /// Computes a derived value [R] from state and rebuilds **ONLY** when that computed value changes.
  Widget compute<R>({
    required R Function(S state) compute,
    required Widget Function(R value) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.compute');
    return _GraftComputation<S, R>(
      key: key,
      graft: this,
      computation: compute,
      builder: builder,
    );
  }
}
