part of '../child_slot_engine.dart';

/// Internal guard that tracks active builder executions to detect and prevent anti-pattern nesting.
abstract final class GraftScopeGuard {
  static final Set<Graft> _activeBuilders = {};
  static final Map<Graft, String> _activeCallers = {};

  static R run<R>(Graft graft, String caller, R Function() action) {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      if (_activeBuilders.contains(graft)) {
        final existing = _activeCallers[graft] ?? 'another builder';
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: REDUNDANT NESTING ON ${graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'You called "$caller" directly inside the builder of "$existing" for the exact same ${graft.runtimeType} instance!\n\n'
          'Why this is a problem:\n'
          '1. In "$existing", children/slots are already isolated or observed.\n'
          '2. Nesting another builder on the same Graft creates duplicate listeners, thrashes widget state, and degrades performance.\n\n'
          'How to fix:\n'
          '• Inside graft.slots:\n'
          '  Simply return normal widgets without wrapping them in graft.slot().\n'
          '  Example:\n'
          '    graft.slots(\n'
          '      (children) => Column(children: children),\n'
          '      [\n'
          '        (s) => Text(s.name), // ✅ Return directly!\n'
          '      ],\n'
          '    )\n'
          '• Inside graft.compute:\n'
          '  Do not use graft.slot() inside compute, as compute already isolates the builder.\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      _activeBuilders.add(graft);
      _activeCallers[graft] = caller;
      return true;
    }());

    if (!isDebug) return action();

    try {
      return action();
    } finally {
      _activeBuilders.remove(graft);
      _activeCallers.remove(graft);
    }
  }

  static void verifyNotActive(Graft graft, String caller) {
    assert(() {
      if (_activeBuilders.contains(graft)) {
        final existing = _activeCallers[graft] ?? 'another builder';
        throw FlutterError(
          '\n════════════════════════════════════════════════════════════════════════════════\n'
          '⚠️ GRAFT ANTI-PATTERN DETECTED: REDUNDANT NESTING ON ${graft.runtimeType}\n'
          '════════════════════════════════════════════════════════════════════════════════\n'
          'You called "$caller" directly inside the builder of "$existing" for the exact same ${graft.runtimeType} instance!\n\n'
          'Why this is a problem:\n'
          '1. In "$existing", children/slots are already isolated or observed.\n'
          '2. Nesting another builder on the same Graft creates duplicate listeners, thrashes widget state, and degrades performance.\n\n'
          'How to fix:\n'
          '• Inside graft.slots:\n'
          '  Simply return normal widgets without wrapping them in graft.slot().\n'
          '  Example:\n'
          '    graft.slots(\n'
          '      (children) => Column(children: children),\n'
          '      [\n'
          '        (s) => Text(s.name), // ✅ Return directly!\n'
          '      ],\n'
          '    )\n'
          '• Inside graft.compute:\n'
          '  Do not use graft.slot() inside compute, as compute already isolates the builder.\n'
          '════════════════════════════════════════════════════════════════════════════════\n',
        );
      }
      return true;
    }());
  }
}

/// An internal [InheritedWidget] to detect duplicate Graft slot scopes in the element tree.
class InheritedGraftScope extends InheritedWidget {
  final Graft graft;
  final String caller;

  const InheritedGraftScope({
    super.key,
    required this.graft,
    required this.caller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedGraftScope oldWidget) =>
      oldWidget.graft != graft || oldWidget.caller != caller;
}

