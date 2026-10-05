import 'package:flutter/widgets.dart';

/// A lightweight [BuildContext] proxy that inspects [InheritedWidget] values
/// (e.g. [Theme], [MediaQuery]) without subscribing the caller as a dependency.
///
/// Used during slot diffing to safely invoke `StatelessWidget.build` without
/// leaking dependencies to ancestor diff engines.
class NoSubscriptionContext implements BuildContext {
  final BuildContext _inner;

  /// Creates a [NoSubscriptionContext] wrapping [_inner].
  const NoSubscriptionContext(this._inner);

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    // Read the inherited element directly without calling dependOnInheritedElement
    final element = _inner.getElementForInheritedWidgetOfExactType<T>();
    return element?.widget as T?;
  }

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) {
    return ancestor.widget as InheritedWidget;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return _inner.getElementForInheritedWidgetOfExactType<T>();
  }

  @override
  Widget get widget => _inner.widget;

  @override
  BuildOwner? get owner => _inner.owner;

  @override
  bool get mounted => _inner.mounted;

  @override
  bool get debugDoingBuild => _inner.debugDoingBuild;

  @override
  Size? get size => _inner.size;

  @override
  dynamic noSuchMethod(Invocation invocation) => _inner.noSuchMethod(invocation);
}
