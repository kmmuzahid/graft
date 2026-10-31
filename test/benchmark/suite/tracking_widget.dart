import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:graft/graft.dart';

/// Rebuild tracking widget implementing [GraftEquivalent] to verify
/// surgical diffing and fine-grained rebuild isolation.
class TrackingWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const TrackingWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! TrackingWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return _TrackingRenderBoxWidget(label: label);
  }
}

class _TrackingRenderBoxWidget extends LeafRenderObjectWidget {
  final String label;
  const _TrackingRenderBoxWidget({required this.label});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTrackingBox();

  @override
  void updateRenderObject(
      BuildContext context, _RenderTrackingBox renderObject) {}
}

class _RenderTrackingBox extends RenderBox {
  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(const Size(100, 20));

  @override
  void performLayout() {
    size = constraints.constrain(const Size(100, 20));
  }

  @override
  void paint(PaintingContext context, Offset offset) {}
}

/// Helper counter holding exact rebuild statistics for target and static children.
class RebuildCounter {
  int dynamicBuilds = 0;
  final List<int> staticBuilds;

  RebuildCounter(int staticChildCount)
      : staticBuilds = List<int>.filled(staticChildCount, 0);

  void reset() {
    dynamicBuilds = 0;
    for (int i = 0; i < staticBuilds.length; i++) {
      staticBuilds[i] = 0;
    }
  }

  int get totalStaticBuilds =>
      staticBuilds.fold(0, (sum, count) => sum + count);

  int get totalBuilds => dynamicBuilds + totalStaticBuilds;
}
