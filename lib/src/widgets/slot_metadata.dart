import 'package:flutter/widgets.dart';
import '../core/graft_mask.dart';

part 'slot_fingerprint.dart';
part 'slot_notifier.dart';

/// Retained structural metadata for each child slot in `graft.slots`.
///
/// Enables the self-optimizing adaptive change detection engine to evaluate
/// dirty state in 1 CPU clock cycle and bypass clean slots with 0 element rebuilds.
class SlotMetadata {
  /// Positional index in the layout array (0, 1, 2...)
  int slotIndex;

  /// Whether this slot contains a static/const widget.
  /// If true, permanently bypassed with 0 CPU cycles.
  final bool isStatic;

  /// The runtime type of the child widget (e.g. [Text], [Icon], [ListTile]).
  Type widgetType;

  /// Fast integer content fingerprint for sub-nanosecond comparisons.
  int contentFingerprint;

  /// The cumulative learned property bitmask in the state's `dirtyMask` this slot correlates to.
  /// When learned, allows 1-cycle CPU bitwise evaluation: `dirtyMask.intersects(fieldDependenciesMask)`.
  GraftMask fieldDependenciesMask;

  /// Bitmask of fields that have been verified NOT to affect this slot.
  GraftMask ignoredMask;

  /// Returns the single bound field index if exactly one field is bound, or null if unmapped / multi-bound.
  int? get boundFieldIndex => fieldDependenciesMask.singleBitIndex;

  set boundFieldIndex(int? index) {
    if (index == null) {
      fieldDependenciesMask = GraftMask.empty;
    } else {
      fieldDependenciesMask = fieldDependenciesMask.withBit(index);
    }
  }

  /// The currently retained widget for this slot.
  Widget currentWidget;

  /// The active leaf element for this slot, allowing direct rebuild dispatch without ValueNotifier.
  Element? element;

  /// The individual surgical trigger for this slot's leaf Element.
  final SlotNotifier notifier;

  /// Rebuild counter for profiling and DevTools.
  int rebuildCount = 0;

  /// Pre-compiled typed evaluator function for 0-reflection runtime dispatch.
  final Widget Function(dynamic state)? evaluator;

  /// Lazy evaluator closure returning the latest widget.
  final Widget Function()? evaluate;

  /// The parent Graft controller.
  final dynamic graft;

  SlotMetadata({
    required this.slotIndex,
    required this.isStatic,
    required this.widgetType,
    required this.contentFingerprint,
    required Widget initialWidget,
    this.evaluator,
    this.evaluate,
    this.graft,
    int? boundFieldIndex,
    GraftMask fieldDependenciesMask = GraftMask.empty,
    this.ignoredMask = GraftMask.empty,
  })  : currentWidget = initialWidget,
        fieldDependenciesMask = boundFieldIndex != null
            ? GraftMask.fromIndex(boundFieldIndex)
            : fieldDependenciesMask,
        notifier = SlotNotifier(initialWidget);

  /// Updates this slot's widget and dispatches direct element rebuild.
  @pragma('vm:prefer-inline')
  void updateWidget(Widget newWidget) {
    currentWidget = newWidget;
    if (notifier.hasExternalListeners) {
      notifier.value = newWidget;
    }
    element?.markNeedsBuild();
  }

  /// Fast evaluation of whether this slot needs to rebuild given [dirtyMask].
  @pragma('vm:prefer-inline')
  bool isDirty(GraftMask dirtyMask) {
    if (isStatic) return false;
    if (dirtyMask.isAllDirty) return true;
    if (ignoredMask.isNotEmpty && dirtyMask.isSubsetOf(ignoredMask)) {
      return false;
    }
    if (fieldDependenciesMask.isEmpty) {
      return true; // All dirty on first build or unmapped
    }
    return dirtyMask.intersects(fieldDependenciesMask);
  }

  /// Disposes this slot's internal notifier.
  void dispose() {
    element = null;
    notifier.dispose();
  }

  /// Computes a fast 64-bit integer fingerprint of a widget's content in nanoseconds.
  @pragma('vm:prefer-inline')
  static int computeFingerprint(Widget w) => _computeWidgetFingerprint(w);
}
