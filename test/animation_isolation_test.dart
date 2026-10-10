import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AnimationBenchmarkState extends GraftState {
  int counter;
  bool isExpanded;
  String status;

  AnimationBenchmarkState({
    this.counter = 0,
    this.isExpanded = false,
    this.status = 'idle',
  });

  @override
  GraftProps get props => propsOf(counter, isExpanded, status);

  @override
  void onReset() {
    counter = 0;
    isExpanded = false;
    status = 'idle';
  }
}

class AnimationBenchmarkGraft extends Graft<AnimationBenchmarkState> {
  AnimationBenchmarkGraft() : super(AnimationBenchmarkState());

  void increment() {
    state
      ..counter += 1
      ..update();
  }

  void toggleExpanded() {
    state
      ..isExpanded = !state.isExpanded
      ..update();
  }

  void setStatus(String status) {
    state
      ..status = status
      ..update();
  }
}

class HeavyTrackingWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const HeavyTrackingWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! HeavyTrackingWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(label),
    );
  }
}

class AnimatedSpinnerSlot extends StatefulWidget {
  final AnimationController controller;
  final VoidCallback onFrameBuild;

  const AnimatedSpinnerSlot({
    super.key,
    required this.controller,
    required this.onFrameBuild,
  });

  @override
  State<AnimatedSpinnerSlot> createState() => _AnimatedSpinnerSlotState();
}

class _AnimatedSpinnerSlotState extends State<AnimatedSpinnerSlot> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        widget.onFrameBuild();
        return Transform.rotate(
          angle: widget.controller.value * 2.0 * 3.14159265,
          child: const Icon(Icons.refresh),
        );
      },
    );
  }
}

void main() {
  group('High-Frequency Animation & 60fps/120fps Rebuild Isolation Tests', () {
    testWidgets('60fps Animation inside graft.slots isolates ticker: Sibling slots have 0 rebuilds across 60 frames',
        (tester) async {
      final graft = AnimationBenchmarkGraft();
      late AnimationController animationController;

      int heavyHeaderBuildCount = 0;
      int animatedSlotFrameCount = 0;
      int reactiveTextBuildCount = 0;
      int layoutBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return _TestTickerHost(
                  onInit: (tickerProvider) {
                    animationController = AnimationController(
                      vsync: tickerProvider,
                      duration: const Duration(seconds: 1),
                    );
                  },
                  child: graft.slots(
                    layout: (children) {
                      layoutBuildCount++;
                      return Column(children: children);
                    },
                    slots: [
                      // Slot 0: Static Heavy Widget
                      (_) => HeavyTrackingWidget(
                        label: 'Heavy Static Header',
                        onBuild: () => heavyHeaderBuildCount++,
                      ),
                      // Slot 1: 60fps High-frequency animated spinner
                      (_) => AnimatedSpinnerSlot(
                        controller: animationController,
                        onFrameBuild: () => animatedSlotFrameCount++,
                      ),
                      // Slot 2: Graft state text
                      (s) => HeavyTrackingWidget(
                        label: 'Status: ${s.status}',
                        onBuild: () => reactiveTextBuildCount++,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial Mount Assertions: each widget builds once
      expect(heavyHeaderBuildCount, equals(1));
      expect(reactiveTextBuildCount, equals(1));
      expect(layoutBuildCount, equals(1));
      expect(animatedSlotFrameCount, equals(1));

      // Reset counters to track only the animation frames
      heavyHeaderBuildCount = 0;
      reactiveTextBuildCount = 0;
      layoutBuildCount = 0;
      animatedSlotFrameCount = 0;

      // Start 60fps animation: 60 frames over 1000ms (~16.6ms per frame)
      animationController.forward();

      const int totalFrames = 60;
      for (int i = 0; i < totalFrames; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Assertions:
      // 1. The animated widget ticked on each frame
      expect(animatedSlotFrameCount, greaterThanOrEqualTo(59));

      // 2. Heavy static widget experienced STRICTLY 0 REBUILDS across all 60 animation frames!
      expect(heavyHeaderBuildCount, equals(0),
          reason: 'Heavy static sibling slot must have 0 rebuilds during the entire 60fps animation');

      // 3. Reactive state text slot experienced STRICTLY 0 REBUILDS across all 60 frames!
      expect(reactiveTextBuildCount, equals(0),
          reason: 'Reactive sibling slot must have 0 rebuilds when Graft state did not mutate');

      // 4. graft.slots layout experienced STRICTLY 0 REBUILDS!
      expect(layoutBuildCount, equals(0),
          reason: 'graft.slots layout must NOT rebuild when only an inner slot animates');

      animationController.dispose();
    });

    testWidgets('Concurrent 60fps Animation + Rapid Graft State Mutations',
        (tester) async {
      final graft = AnimationBenchmarkGraft();
      late AnimationController animationController;

      int heavyHeaderBuildCount = 0;
      int animatedSlotFrameCount = 0;
      int reactiveTextBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestTickerHost(
              onInit: (tickerProvider) {
                animationController = AnimationController(
                  vsync: tickerProvider,
                  duration: const Duration(seconds: 1),
                );
              },
              child: graft.slots(
                layout: (children) => Column(children: children),
                slots: [
                  (_) => HeavyTrackingWidget(
                    label: 'Heavy Header',
                    onBuild: () => heavyHeaderBuildCount++,
                  ),
                  (_) => AnimatedSpinnerSlot(
                    controller: animationController,
                    onFrameBuild: () => animatedSlotFrameCount++,
                  ),
                  (s) => HeavyTrackingWidget(
                    label: 'Counter: ${s.counter}',
                    onBuild: () => reactiveTextBuildCount++,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Reset build counts
      heavyHeaderBuildCount = 0;
      animatedSlotFrameCount = 0;
      reactiveTextBuildCount = 0;

      animationController.repeat();

      const int totalFrames = 60;
      int expectedMutations = 0;

      // Pump 60 frames; mutate Graft state every 10 frames (6 mutations total)
      for (int frame = 0; frame < totalFrames; frame++) {
        if (frame % 10 == 0) {
          graft.increment();
          expectedMutations++;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }

      // 1. Animated slot ticked 60 frames uninterrupted
      expect(animatedSlotFrameCount, greaterThanOrEqualTo(59));

      // 2. Reactive counter slot rebuilt strictly on the 6 mutation frames
      expect(reactiveTextBuildCount, equals(expectedMutations),
          reason: 'Slot 2 should only rebuild when its counter value changes');

      // 3. Heavy static header had STRICTLY 0 REBUILDS throughout the entire concurrent sequence!
      expect(heavyHeaderBuildCount, equals(0),
          reason: 'Heavy header must never rebuild despite 60 animation frames + 6 state updates');

      animationController.dispose();
    });

    testWidgets('GraftBoundary isolates 60fps Ticker: Outer container never rebuilds',
        (tester) async {
      final graft = AnimationBenchmarkGraft();
      late AnimationController animationController;
      int outerContainerBuildCount = 0;
      int boundaryBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestTickerHost(
              onInit: (tickerProvider) {
                animationController = AnimationController(
                  vsync: tickerProvider,
                  duration: const Duration(seconds: 1),
                );
              },
              child: HeavyTrackingWidget(
                label: 'Outer Paint Container',
                onBuild: () => outerContainerBuildCount++,
              ),
            ),
          ),
        ),
      );

      expect(outerContainerBuildCount, equals(1));

      // Rebuild tree with GraftBoundary nested inside
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestTickerHost(
              onInit: (tickerProvider) {
                animationController = AnimationController(
                  vsync: tickerProvider,
                  duration: const Duration(seconds: 1),
                );
              },
              child: Column(
                children: [
                  HeavyTrackingWidget(
                    label: 'Outer Paint Container',
                    onBuild: () => outerContainerBuildCount++,
                  ),
                  GraftBoundary(
                    builder: (context) {
                      boundaryBuildCount++;
                      return Column(
                        children: [
                          Text('Graft State: ${graft.state.status}'),
                          AnimatedSpinnerSlot(
                            controller: animationController,
                            onFrameBuild: () {},
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Reset counts to isolate 60-frame run
      outerContainerBuildCount = 0;
      boundaryBuildCount = 0;

      animationController.forward();

      // Tick 60 frames
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Outer container and boundary both have STRICTLY 0 REBUILDS!
      expect(outerContainerBuildCount, equals(0),
          reason: 'Outer container above boundary must never rebuild when inner boundary animates');
      expect(boundaryBuildCount, equals(0),
          reason: 'Boundary builder itself does not rebuild when child AnimatedBuilder ticks');

      animationController.dispose();
    });

    testWidgets('Graft-Driven Implicit Animation (AnimatedContainer) isolates tweening to animated slot',
        (tester) async {
      final graft = AnimationBenchmarkGraft();
      int siblingBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              slots: [
                (_) => HeavyTrackingWidget(
                  label: 'Sibling Static Slot',
                  onBuild: () => siblingBuildCount++,
                ),
                (s) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: s.isExpanded ? 200.0 : 50.0,
                  child: const Text('Animated Box'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(siblingBuildCount, equals(1));
      siblingBuildCount = 0;

      // Trigger state change that kicks off 300ms AnimatedContainer tween
      graft.toggleExpanded();
      await tester.pump(); // frame 0

      // Step through 300ms of animation (18 frames)
      for (int i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Sibling slot must have STRICTLY 0 EXTRA REBUILDS while AnimatedContainer interpolates!
      expect(siblingBuildCount, equals(0),
          reason: 'Sibling slot must have 0 rebuilds while AnimatedContainer animates');
    });

    testWidgets('Ticker Lifecycle Safety: AnimationController inside Graft slot disposes without leaks',
        (tester) async {
      late AnimationController activeController;
      bool isMounted = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                if (!isMounted) return const SizedBox.shrink();
                return _SelfDisposingAnimatedWidget(
                  onCreated: (c) => activeController = c,
                );
              },
            ),
          ),
        ),
      );

      expect(activeController.isAnimating, isTrue);

      // Unmount the animated widget
      isMounted = false;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      // Verify no pending ticker assertions thrown
      expect(tester.takeException(), isNull);
    });
  });
}

class _TestTickerHost extends StatefulWidget {
  final void Function(TickerProvider) onInit;
  final Widget child;

  const _TestTickerHost({
    required this.onInit,
    required this.child,
  });

  @override
  State<_TestTickerHost> createState() => _TestTickerHostState();
}

class _TestTickerHostState extends State<_TestTickerHost>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onInit(this);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SelfDisposingAnimatedWidget extends StatefulWidget {
  final void Function(AnimationController) onCreated;

  const _SelfDisposingAnimatedWidget({required this.onCreated});

  @override
  State<_SelfDisposingAnimatedWidget> createState() =>
      _SelfDisposingAnimatedWidgetState();
}

class _SelfDisposingAnimatedWidgetState
    extends State<_SelfDisposingAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    widget.onCreated(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Text('Tick: ${_controller.value}'),
    );
  }
}
