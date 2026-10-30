part of 'slot_metadata.dart';

/// Computes a fast 64-bit integer fingerprint of a widget's content in nanoseconds.
@pragma('vm:prefer-inline')
int _computeWidgetFingerprint(Widget w) {
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
  if (w is SizedBox) {
    return Object.hash(
      w.width,
      w.height,
      w.child != null ? _computeWidgetFingerprint(w.child!) : 0,
    );
  }
  if (w is Padding) {
    return Object.hash(
      w.padding,
      w.child != null ? _computeWidgetFingerprint(w.child!) : 0,
    );
  }
  if (w is ColoredBox) {
    return Object.hash(
      w.color,
      w.child != null ? _computeWidgetFingerprint(w.child!) : 0,
    );
  }
  if (w is Align) {
    return Object.hash(
      w.alignment,
      w.widthFactor,
      w.heightFactor,
      w.child != null ? _computeWidgetFingerprint(w.child!) : 0,
    );
  }
  if (w is Opacity) {
    return Object.hash(
      w.opacity,
      w.child != null ? _computeWidgetFingerprint(w.child!) : 0,
    );
  }
  if (w.key != null) {
    return Object.hash(w.runtimeType, w.key);
  }
  return w.hashCode;
}

