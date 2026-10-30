part of 'graft_widgets.dart';

/// Extension on [Graft<S>] providing high-performance collection and builder slots.
extension GraftCollectionWidgetsX<S extends GraftState> on Graft<S> {
  /// Creates a 100% lazy, virtualized collection with per-item slot diffing.
  ///
  /// Works out-of-the-box with automatic [ListView.builder], or customize with **ANY** Flutter builder.
  Widget builder<T>({
    required List<T> Function(S state) items,
    Widget Function(T item, int index)? itemBuilder,
    Widget Function(T item)? item,
    Key Function(T item)? itemKey,
    Widget Function(int itemCount, NullableIndexedWidgetBuilder itemBuilder)?
        layout,
    Key? key,
  }) {
    assert(
      itemBuilder != null || item != null,
      'Either provide `itemBuilder: (item, index) => ...` or `item: (item) => ...`.',
    );
    GraftScopeGuard.verifyNotActive(this, 'graft.builder');
    final effectiveLayout = layout ??
        (count, b) => ListView.builder(
              itemCount: count,
              itemBuilder: b,
            );
    final effectiveItemBuilder = itemBuilder ?? (T itm, int _) => item!(itm);
    return GraftBuilderDiffEngine<S, T>(
      key: key,
      graft: this,
      layout: effectiveLayout,
      itemCount: (s) => items(s).length,
      item: (s, i) => items(s)[i],
      itemBuilder: (context, itm, index) => effectiveItemBuilder(itm, index),
      itemKey: itemKey,
    );
  }

  /// Universal lazy item slot adapter.
  Widget item<T>({
    required T Function(S state) selector,
    required Widget Function(T item) builder,
    int? index,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.item');
    return GraftItemSlot<S, T>(
      key: key,
      index: index,
      graft: this,
      selector: selector,
      valueBuilder: builder,
    );
  }

  /// Universal fine-grained selector slot adapter.
  Widget select<T>(
    T Function(S state) selector, {
    required Widget Function(T value) builder,
    int? index,
    Key? key,
  }) =>
      item<T>(selector: selector, builder: builder, index: index, key: key);
}

