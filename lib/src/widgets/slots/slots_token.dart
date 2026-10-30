part of '../child_slot_engine.dart';

/// Interface for widgets that provide custom equivalence checking for slot diffing.
abstract interface class GraftEquivalent {
  /// Returns `true` if this widget has identical visual properties to [other].
  bool isEquivalentTo(Widget other);
}

/// Token class representing the child slots inside layout declarations.
class _GraftSlotsToken implements List<Widget> {
  const _GraftSlotsToken();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(
        'The `slots` token is only a structural placeholder for layout widgets (e.g. Column(children: slots)).\n'
        'It cannot be evaluated directly as a runtime list.',
      );
}

/// Token to represent the slot widgets inside direct layout widgets.
///
/// Example:
/// ```dart
/// graft.slots(
///   layout: Column(
///     children: slots, // 👈 Clean token syntax
///   ),
///   slots: (s) => [ Text(s.name), Text(s.email) ],
/// )
/// ```
const slots = _GraftSlotsToken();

