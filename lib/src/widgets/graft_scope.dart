import 'package:flutter/widgets.dart';
import '../core/graft.dart';

/// Provides a subtree-scoped lifecycle boundary for [Graft] instances.
///
/// Particularly useful for modern declarative routing like `GoRouter`'s `StatefulShellRoute`,
/// persistent bottom navigation tabs, modal sheets, and nested dialogs.
/// All [Graft] instances managed by [GraftScope] are automatically disposed
/// when [GraftScope] is unmounted from the element tree.
class GraftScope extends StatefulWidget {
  final List<Graft Function()> factories;
  final List<Graft> instances;
  final Widget child;

  const GraftScope({
    super.key,
    this.factories = const [],
    this.instances = const [],
    required this.child,
  });

  /// Convenience constructor for scoping a single [Graft] instance.
  GraftScope.single({
    super.key,
    required Graft graft,
    required Widget child,
  })  : factories = const [],
        instances = [graft],
        child = child;

  @override
  State<GraftScope> createState() => GraftScopeState();

  /// Looks up an active [Graft] of type [T] from the nearest [GraftScope] ancestor.
  static T? maybeOf<T extends Graft>(BuildContext context) {
    final state = context.findAncestorStateOfType<GraftScopeState>();
    return state?.find<T>();
  }
}

class GraftScopeState extends State<GraftScope> {
  final Map<Type, Graft> _instances = {};

  @override
  void initState() {
    super.initState();
    for (final instance in widget.instances) {
      _instances[instance.runtimeType] = instance;
    }
    for (final factory in widget.factories) {
      final instance = factory();
      _instances[instance.runtimeType] = instance;
    }
  }

  /// Finds an existing instance of type [T] in this scope.
  T? find<T extends Graft>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }
    return null;
  }

  /// Registers a newly created [graft] to be owned and disposed by this scope.
  void register<T extends Graft>(T graft) {
    _instances[T] = graft;
  }

  @override
  void dispose() {
    for (final graft in _instances.values) {
      if (!graft.isDisposed) {
        graft.dispose();
      }
    }
    _instances.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
