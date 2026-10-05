import 'package:flutter/widgets.dart';

/// Retained structural metadata for each child slot in `graft.slots`.
///
/// Enables the self-optimizing adaptive change detection engine to evaluate
/// dirty state in 1 CPU clock cycle and bypass clean slots with 0 element rebuilds.
class SlotMetadata {
  /// Positional index in the layout array (0, 1, 2...)
  final int slotIndex;

  /// Whether this slot contains a static/const widget.
  /// If true, permanently bypassed with 0 CPU cycles.
  final bool isStatic;

  /// The runtime type of the child widget (e.g. [Text], [Icon], [ListTile]).
  Type widgetType;

  /// Fast integer content fingerprint for sub-nanosecond comparisons.
  int contentFingerprint;

  /// The cumulative learned field bitmask in the state's `dirtyMask` this slot correlates to.
  /// When learned, allows 1-cycle CPU bitwise evaluation: `(dirtyMask & fieldDependenciesMask) != 0`.
  int fieldDependenciesMask;

  /// Returns the single bound field index if exactly one field is bound, or null if unmapped / multi-bound.
  int? get boundFieldIndex {
    if (fieldDependenciesMask > 0 && (fieldDependenciesMask & (fieldDependenciesMask - 1)) == 0) {
      return fieldDependenciesMask.bitLength - 1;
    }
    return null;
  }

  set boundFieldIndex(int? index) {
    if (index == null) {
      fieldDependenciesMask = 0;
    } else {
      fieldDependenciesMask |= (1 << index);
    }
  }

  /// The individual surgical trigger for this slot's leaf Element.
  final ValueNotifier<Widget> notifier;

  /// Rebuild counter for profiling and DevTools.
  int rebuildCount = 0;

  SlotMetadata({
    required this.slotIndex,
    required this.isStatic,
    required this.widgetType,
    required this.contentFingerprint,
    required Widget initialWidget,
    int? boundFieldIndex,
    int fieldDependenciesMask = 0,
  })  : fieldDependenciesMask = boundFieldIndex != null
            ? (1 << boundFieldIndex)
            : fieldDependenciesMask,
        notifier = ValueNotifier<Widget>(initialWidget);

  /// Fast evaluation of whether this slot needs to rebuild given [dirtyMask].
  @pragma('vm:prefer-inline')
  bool isDirty(int dirtyMask) {
    if (isStatic) return false;
    if (dirtyMask == -1 || fieldDependenciesMask == 0) return true; // All dirty on first build or unmapped
    return (dirtyMask & fieldDependenciesMask) != 0;
  }

  /// Disposes this slot's internal notifier.
  void dispose() {
    notifier.dispose();
  }

  /// Computes a fast 64-bit integer fingerprint of a widget's content in nanoseconds.
  @pragma('vm:prefer-inline')
  static int computeFingerprint(Widget w) {
    if (w is Text) {
      return Object.hash(
        w.data,
        w.style?.fontSize,
        w.style?.color,
        w.style?.fontWeight,
        w.textAlign,
      );
    }
    if (w is Icon) {
      return Object.hash(
        w.icon,
        w.color,
        w.size,
        w.semanticLabel,
      );
    }
    if (w.key != null) {
      return Object.hash(w.runtimeType, w.key);
    }
    return w.hashCode;
  }
}
