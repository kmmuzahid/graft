import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class CustomEquivalentWidget extends StatelessWidget implements GraftEquivalent {
  final int id;
  const CustomEquivalentWidget(this.id, {super.key});

  @override
  bool isEquivalentTo(Widget other) => other is CustomEquivalentWidget && other.id == id;

  @override
  Widget build(BuildContext context) => Text('ID: $id');
}

class CyclicalWidget extends StatelessWidget {
  const CyclicalWidget({super.key});

  @override
  Widget build(BuildContext context) => this;
}

class DeepState extends GraftState {
  int value;
  DeepState(this.value);

  @override
  GraftProps get props => propsOf(value);
}

class DeepGraft extends Graft<DeepState> {
  DeepGraft() : super(DeepState(0));

  void updateVal(int v) {
    state.value = v;
    state.update();
  }
}

void main() {
  group('child_slot_engine.dart isWidgetEquivalent Exhaustive Diffing', () {
    testWidgets('RichText diffing', (tester) async {
      final w1 = RichText(text: const TextSpan(text: 'Hello'));
      final w2 = RichText(text: const TextSpan(text: 'Hello'));
      final w3 = RichText(text: const TextSpan(text: 'World'));

      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(w1, w2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(w1, w3), isFalse);
    });

    testWidgets('Icon diffing', (tester) async {
      const w1 = Icon(Icons.star, size: 24, color: Colors.amber);
      const w2 = Icon(Icons.star, size: 24, color: Colors.amber);
      const w3 = Icon(Icons.star, size: 30, color: Colors.amber);

      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(w1, w2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(w1, w3), isFalse);
    });

    testWidgets('SizedBox and Padding diffing', (tester) async {
      const sb1 = SizedBox(width: 10, height: 10, child: Text('A'));
      const sb2 = SizedBox(width: 10, height: 10, child: Text('A'));
      const sb3 = SizedBox(width: 20, height: 10, child: Text('A'));
      const sb4 = SizedBox(width: 10, height: 10, child: Text('B'));

      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sb1, sb2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sb1, sb3), isFalse);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sb1, sb4), isFalse);

      const p1 = Padding(padding: EdgeInsets.all(8), child: Text('A'));
      const p2 = Padding(padding: EdgeInsets.all(8), child: Text('A'));
      const p3 = Padding(padding: EdgeInsets.all(16), child: Text('A'));
      const p4 = Padding(padding: EdgeInsets.all(8), child: Text('B'));

      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(p1, p2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(p1, p3), isFalse);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(p1, p4), isFalse);
    });

    testWidgets('ColoredBox, Align, DecoratedBox, Opacity, ClipRRect diffing', (tester) async {
      const cb1 = ColoredBox(color: Colors.red, child: Text('A'));
      const cb2 = ColoredBox(color: Colors.red, child: Text('A'));
      const cb3 = ColoredBox(color: Colors.blue, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb3), isFalse);

      const al1 = Align(alignment: Alignment.center, child: Text('A'));
      const al2 = Align(alignment: Alignment.center, child: Text('A'));
      const al3 = Align(alignment: Alignment.topLeft, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(al1, al2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(al1, al3), isFalse);

      const dec1 = DecoratedBox(decoration: BoxDecoration(color: Colors.black), child: Text('A'));
      const dec2 = DecoratedBox(decoration: BoxDecoration(color: Colors.black), child: Text('A'));
      const dec3 = DecoratedBox(decoration: BoxDecoration(color: Colors.white), child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(dec1, dec2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(dec1, dec3), isFalse);

      const op1 = Opacity(opacity: 0.5, child: Text('A'));
      const op2 = Opacity(opacity: 0.5, child: Text('A'));
      const op3 = Opacity(opacity: 0.8, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(op1, op2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(op1, op3), isFalse);

      final clip1 = ClipRRect(borderRadius: BorderRadius.circular(8), child: const Text('A'));
      final clip2 = ClipRRect(borderRadius: BorderRadius.circular(8), child: const Text('A'));
      final clip3 = ClipRRect(borderRadius: BorderRadius.circular(16), child: const Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(clip1, clip2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(clip1, clip3), isFalse);
    });

    testWidgets('ShaderMask, DefaultTextStyle, Flex, Flexible, FittedBox diffing', (tester) async {
      final sm1 = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(colors: [Colors.red, Colors.blue]).createShader(bounds),
        child: const Text('A'),
      );
      final sm2 = ShaderMask(
        shaderCallback: sm1.shaderCallback,
        child: const Text('A'),
      );
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sm1, sm2), isTrue);

      const ts1 = DefaultTextStyle(style: TextStyle(fontSize: 14), child: Text('A'));
      const ts2 = DefaultTextStyle(style: TextStyle(fontSize: 14), child: Text('A'));
      const ts3 = DefaultTextStyle(style: TextStyle(fontSize: 18), child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ts1, ts2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ts1, ts3), isFalse);

      const row1 = Row(children: [Text('A'), Text('B')]);
      const row2 = Row(children: [Text('A'), Text('B')]);
      const row3 = Row(children: [Text('A'), Text('C')]);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(row1, row2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(row1, row3), isFalse);

      const flx1 = Flexible(flex: 1, fit: FlexFit.loose, child: Text('A'));
      const flx2 = Flexible(flex: 1, fit: FlexFit.loose, child: Text('A'));
      const flx3 = Flexible(flex: 2, fit: FlexFit.loose, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(flx1, flx2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(flx1, flx3), isFalse);

      const fit1 = FittedBox(fit: BoxFit.cover, child: Text('A'));
      const fit2 = FittedBox(fit: BoxFit.cover, child: Text('A'));
      const fit3 = FittedBox(fit: BoxFit.contain, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(fit1, fit2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(fit1, fit3), isFalse);
    });

    testWidgets('ConstrainedBox, AspectRatio, FractionallySizedBox, Stack, Positioned, Wrap diffing', (tester) async {
      final cb1 = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 100), child: const Text('A'));
      final cb2 = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 100), child: const Text('A'));
      final cb3 = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200), child: const Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb3), isFalse);

      const ar1 = AspectRatio(aspectRatio: 16 / 9, child: Text('A'));
      const ar2 = AspectRatio(aspectRatio: 16 / 9, child: Text('A'));
      const ar3 = AspectRatio(aspectRatio: 4 / 3, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ar1, ar2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ar1, ar3), isFalse);

      const fs1 = FractionallySizedBox(widthFactor: 0.5, child: Text('A'));
      const fs2 = FractionallySizedBox(widthFactor: 0.5, child: Text('A'));
      const fs3 = FractionallySizedBox(widthFactor: 0.8, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(fs1, fs2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(fs1, fs3), isFalse);

      const st1 = Stack(children: [Text('A')]);
      const st2 = Stack(children: [Text('A')]);
      const st3 = Stack(children: [Text('B')]);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(st1, st2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(st1, st3), isFalse);

      const pos1 = Positioned(left: 10, top: 10, child: Text('A'));
      const pos2 = Positioned(left: 10, top: 10, child: Text('A'));
      const pos3 = Positioned(left: 20, top: 10, child: Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(pos1, pos2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(pos1, pos3), isFalse);

      const wr1 = Wrap(spacing: 8, children: [Text('A')]);
      const wr2 = Wrap(spacing: 8, children: [Text('A')]);
      const wr3 = Wrap(spacing: 16, children: [Text('A')]);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(wr1, wr2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(wr1, wr3), isFalse);
    });

    testWidgets('GestureDetector, InkWell, IconButton, CupertinoButton diffing', (tester) async {
      final gd1 = GestureDetector(onTap: () {}, child: const Text('A'));
      final gd2 = GestureDetector(onTap: () {}, child: const Text('A'));
      final gd3 = GestureDetector(onTap: null, child: const Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(gd1, gd2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(gd1, gd3), isFalse);

      final ink1 = InkWell(onTap: () {}, child: const Text('A'));
      final ink2 = InkWell(onTap: () {}, child: const Text('A'));
      final ink3 = InkWell(onTap: null, child: const Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ink1, ink2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ink1, ink3), isFalse);

      final ib1 = IconButton(icon: const Icon(Icons.star), onPressed: () {}, color: Colors.blue);
      final ib2 = IconButton(icon: const Icon(Icons.star), onPressed: () {}, color: Colors.blue);
      final ib3 = IconButton(icon: const Icon(Icons.star), onPressed: null, color: Colors.blue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ib1, ib2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(ib1, ib3), isFalse);

      final cb1 = CupertinoButton(onPressed: () {}, color: Colors.red, child: const Text('A'));
      final cb2 = CupertinoButton(onPressed: () {}, color: Colors.red, child: const Text('A'));
      final cb3 = CupertinoButton(onPressed: null, color: Colors.red, child: const Text('A'));
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(cb1, cb3), isFalse);
    });

    testWidgets('Image, ProgressIndicator, Checkbox, Switch, Slider diffing', (tester) async {
      final img1 = Image.network('https://example.com/1.png', width: 50, height: 50);
      final img2 = Image.network('https://example.com/1.png', width: 50, height: 50);
      final img3 = Image.network('https://example.com/1.png', width: 100, height: 50);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(img1, img2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(img1, img3), isFalse);

      final prog1 = CircularProgressIndicator(value: 0.5, color: Colors.blue);
      final prog2 = CircularProgressIndicator(value: 0.5, color: Colors.blue);
      final prog3 = CircularProgressIndicator(value: 0.8, color: Colors.blue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(prog1, prog2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(prog1, prog3), isFalse);

      final chk1 = Checkbox(value: true, onChanged: (_) {});
      final chk2 = Checkbox(value: true, onChanged: (_) {});
      final chk3 = Checkbox(value: false, onChanged: (_) {});
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(chk1, chk2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(chk1, chk3), isFalse);

      final sw1 = Switch(value: true, onChanged: (_) {});
      final sw2 = Switch(value: true, onChanged: (_) {});
      final sw3 = Switch(value: false, onChanged: (_) {});
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sw1, sw2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sw1, sw3), isFalse);

      final sl1 = Slider(value: 0.5, min: 0, max: 1, onChanged: (_) {});
      final sl2 = Slider(value: 0.5, min: 0, max: 1, onChanged: (_) {});
      final sl3 = Slider(value: 0.8, min: 0, max: 1, onChanged: (_) {});
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sl1, sl2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(sl1, sl3), isFalse);
    });

    testWidgets('GraftEquivalent and lazy cycle detection', (tester) async {
      const eq1 = CustomEquivalentWidget(10);
      const eq2 = CustomEquivalentWidget(10);
      const eq3 = CustomEquivalentWidget(20);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(eq1, eq2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(eq1, eq3), isFalse);

      // Deeply nested widgets (> 20 levels deep) now diff successfully without arbitrary cutoffs:
      Widget buildDeepTree(int depth) {
        if (depth == 0) return const Text('leaf');
        return Padding(padding: const EdgeInsets.all(1), child: buildDeepTree(depth - 1));
      }

      final deepTreeA = buildDeepTree(25);
      final deepTreeB = buildDeepTree(25);
      expect(
        GraftMultiChildDiffEngine.isWidgetEquivalent(deepTreeA, deepTreeB),
        isTrue,
      );

      // Cycle detection: self-referential widget safely returns false without stack overflow
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              const cyclicA = CyclicalWidget();
              const cyclicB = CyclicalWidget();
              final isEq = GraftMultiChildDiffEngine.isWidgetEquivalent(
                cyclicA,
                cyclicB,
                context,
              );
              expect(isEq, isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('graft.builder with separate itemCount, item and itemKey', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<int>(
              items: (s) => List.generate(s.value, (index) => index * 2),
              itemKey: (item) => ValueKey('key_$item'),
              itemBuilder: (item, index) => Text('Item: $item'),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);

      graft.updateVal(3);
      await tester.pump();

      expect(find.text('Item: 0'), findsOneWidget);
      expect(find.text('Item: 2'), findsOneWidget);
      expect(find.text('Item: 4'), findsOneWidget);
    });

    testWidgets('graft.compute nested anti-pattern detection throws FlutterError', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.compute(
              compute: (s) => s.value,
              builder: (v1) => graft.compute(
                compute: (s) => s.value,
                builder: (v2) => Text('$v1-$v2'),
              ),
            ),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect((error as FlutterError).message, contains('GRAFT ANTI-PATTERN DETECTED'));
      graft.dispose();
    });

    testWidgets('graft.compute didUpdateWidget updates graft reference', (tester) async {
      final graft1 = DeepGraft();
      final graft2 = DeepGraft();
      graft2.updateVal(99);

      Widget buildTree(DeepGraft g) {
        return MaterialApp(
          home: Scaffold(
            body: g.compute<int>(
              compute: (s) => s.value,
              builder: (val) => Text('Computed: $val'),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTree(graft1));
      expect(find.text('Computed: 0'), findsOneWidget);

      await tester.pumpWidget(buildTree(graft2));
      expect(find.text('Computed: 99'), findsOneWidget);

      graft2.updateVal(100);
      await tester.pump();
      expect(find.text('Computed: 100'), findsOneWidget);

      graft1.dispose();
      graft2.dispose();
    });

    testWidgets('ListTile detailed property equivalence', (tester) async {
      final lt1 = ListTile(
        title: const Text('Title'),
        subtitle: const Text('Sub'),
        leading: const Icon(Icons.star),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
        onLongPress: () {},
      );
      final lt2 = ListTile(
        title: const Text('Title'),
        subtitle: const Text('Sub'),
        leading: const Icon(Icons.star),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
        onLongPress: () {},
      );
      final ltTitleDiff = ListTile(
        title: const Text('Other'),
        subtitle: const Text('Sub'),
        leading: const Icon(Icons.star),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
        onLongPress: () {},
      );
      final ltSubDiff = ListTile(
        title: const Text('Title'),
        subtitle: const Text('OtherSub'),
        leading: const Icon(Icons.star),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
        onLongPress: () {},
      );
      final ltLeadDiff = ListTile(
        title: const Text('Title'),
        subtitle: const Text('Sub'),
        leading: const Icon(Icons.home),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
        onLongPress: () {},
      );
      final ltTrailDiff = ListTile(
        title: const Text('Title'),
        subtitle: const Text('Sub'),
        leading: const Icon(Icons.star),
        trailing: const Icon(Icons.close),
        onTap: () {},
        onLongPress: () {},
      );

      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(lt1, lt2), isTrue);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(lt1, ltTitleDiff), isFalse);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(lt1, ltSubDiff), isFalse);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(lt1, ltLeadDiff), isFalse);
      expect(GraftMultiChildDiffEngine.isWidgetEquivalent(lt1, ltTrailDiff), isFalse);
    });

    testWidgets('GraftMultiChildDiffEngine unwraps ListView, GridView, Card, Padding, Container', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                graft.slots(
                  layout: (children) => ListView(shrinkWrap: true, children: children),
                  slots: [(s) => Text('ListView: ${s.value}')],
                ),
                graft.slots(
                  layout: (children) => GridView.count(shrinkWrap: true, crossAxisCount: 2, children: children),
                  slots: [(s) => Text('GridView: ${s.value}')],
                ),
                graft.slots(
                  layout: (children) => Card(child: Column(children: children)),
                  slots: [(s) => Text('Card: ${s.value}')],
                ),
                graft.slots(
                  layout: (children) => Padding(padding: const EdgeInsets.all(4), child: Column(children: children)),
                  slots: [(s) => Text('Padding: ${s.value}')],
                ),
                graft.slots(
                  layout: (children) => Container(child: Column(children: children)),
                  slots: [(s) => Text('Container: ${s.value}')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ListView: 0'), findsOneWidget);
      expect(find.text('GridView: 0'), findsOneWidget);
      expect(find.text('Card: 0'), findsOneWidget);
      expect(find.text('Padding: 0'), findsOneWidget);
      expect(find.text('Container: 0'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('GraftMultiChildDiffEngine and GraftSingleSlotScope didUpdateWidget and reassemble', (tester) async {
      final graft1 = DeepGraft();
      final graft2 = DeepGraft();
      graft2.updateVal(50);

      Widget buildSlotTree(DeepGraft g) {
        return MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                g.slot(builder: (s) => Text('Slot: ${s.value}')),
                g.slots(
                  layout: (children) => Column(children: children),
                  slots: [(s) => Text('Slots: ${s.value}')],
                ),
              ],
            ),
          ),
        );
      }

      await tester.pumpWidget(buildSlotTree(graft1));
      expect(find.text('Slot: 0'), findsOneWidget);
      expect(find.text('Slots: 0'), findsOneWidget);

      // Reassemble triggers hot reload re-sync
      tester.binding.reassembleApplication();
      await tester.pump();

      // Switch graft instance (didUpdateWidget branch)
      await tester.pumpWidget(buildSlotTree(graft2));
      expect(find.text('Slot: 50'), findsOneWidget);
      expect(find.text('Slots: 50'), findsOneWidget);

      graft1.dispose();
      graft2.dispose();
    });

    testWidgets('GraftBuilderDiffEngine with PageView, Scrollbar, RefreshIndicator, Padding', (tester) async {
      final graft = DeepGraft();
      graft.updateVal(2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: graft.builder<int>(
                    items: (s) => List.generate(s.value, (i) => i),
                    itemBuilder: (item, index) => Text('Page: $item'),
                    layout: (count, builder) => PageView.builder(itemCount: count, itemBuilder: builder),
                  ),
                ),
                Expanded(
                  child: graft.builder<int>(
                    items: (s) => List.generate(s.value, (i) => i),
                    itemBuilder: (item, index) => Text('Scroll: $item'),
                    layout: (count, builder) => Scrollbar(
                      child: ListView.builder(itemCount: count, itemBuilder: builder),
                    ),
                  ),
                ),
                Expanded(
                  child: graft.builder<int>(
                    items: (s) => List.generate(s.value, (i) => i),
                    itemBuilder: (item, index) => Text('Refresh: $item'),
                    layout: (count, builder) => RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(itemCount: count, itemBuilder: builder),
                    ),
                  ),
                ),
                Expanded(
                  child: graft.builder<int>(
                    items: (s) => List.generate(s.value, (i) => i),
                    itemBuilder: (item, index) => Text('Pad: $item'),
                    layout: (count, builder) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: ListView.builder(itemCount: count, itemBuilder: builder),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Page: 0'), findsOneWidget);
      expect(find.text('Scroll: 0'), findsOneWidget);
      expect(find.text('Refresh: 0'), findsOneWidget);
      graft.dispose();
    });

    testWidgets('GraftSingleSlotScope, GraftBuilderDiffEngine, and _GraftComputation isEquivalentTo', (tester) async {
      final graft = DeepGraft();

      final slot1 = graft.slot(builder: (s) => Text('${s.value}'));
      final slot2 = graft.slot(builder: (s) => Text('${s.value}'));
      expect((slot1 as GraftEquivalent).isEquivalentTo(slot2), isTrue);
      expect((slot1 as GraftEquivalent).isEquivalentTo(const SizedBox()), isFalse);

      final builder1 = graft.builder<int>(
        items: (s) => [1],
        itemBuilder: (item, i) => Text('$item'),
      );
      final builder2 = graft.builder<int>(
        items: (s) => [1],
        itemBuilder: (item, i) => Text('$item'),
      );
      expect((builder1 as GraftEquivalent).isEquivalentTo(builder2), isTrue);
      expect((builder1 as GraftEquivalent).isEquivalentTo(const SizedBox()), isFalse);

      final comp1 = graft.compute(compute: (s) => s.value, builder: (v) => Text('$v'));
      final comp2 = graft.compute(compute: (s) => s.value, builder: (v) => Text('$v'));
      expect((comp1 as GraftEquivalent).isEquivalentTo(comp2), isTrue);
      expect((comp1 as GraftEquivalent).isEquivalentTo(const SizedBox()), isFalse);

      graft.dispose();
    });

    testWidgets('GraftScopeGuard throws FlutterError when slot is nested inside builder', (tester) async {
      final graft = DeepGraft();

      expect(() {
        GraftScopeGuard.run(graft, 'test_scope', () {
          GraftScopeGuard.verifyNotActive(graft, 'nested_call');
        });
      }, throwsA(isA<FlutterError>()));

      graft.dispose();
    });

    testWidgets('Nesting graft.slot inside graft.slot throws FlutterError', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slot(builder: (s) => graft.slot(builder: (s2) => Text('${s.value}'))),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect((error as FlutterError).message, contains('GRAFT ANTI-PATTERN DETECTED'));

      graft.dispose();
    });

    testWidgets('GraftBuilderDiffEngine switches graft on didUpdateWidget', (tester) async {
      final g1 = DeepGraft();
      final g2 = DeepGraft();
      g2.updateVal(5);

      Widget buildTree(DeepGraft g) {
        return MaterialApp(
          home: Scaffold(
            body: g.builder<int>(
              items: (s) => List.generate(s.value, (i) => i),
              itemBuilder: (item, index) => Text('Item: $item'),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTree(g1));
      await tester.pumpWidget(buildTree(g2));

      expect(find.text('Item: 0'), findsOneWidget);
      expect(find.text('Item: 4'), findsOneWidget);

      g1.dispose();
      g2.dispose();
    });

    testWidgets('InheritedGraftScope element tree nesting detection throws FlutterError', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slot(builder: (s) {
              return Builder(
                builder: (ctx) {
                  return graft.slot(builder: (s2) => Text('${s2.value}'));
                },
              );
            }),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect((error as FlutterError).message, contains('GRAFT ANTI-PATTERN DETECTED: NESTED ELEMENT TREE SCOPE'));

      graft.dispose();
    });

    test('GraftScopeGuard.run nested throws FlutterError', () {
      final graft = DeepGraft();
      expect(() {
        GraftScopeGuard.run(graft, 'outer', () {
          GraftScopeGuard.run(graft, 'inner', () {});
        });
      }, throwsA(isA<FlutterError>()));
      graft.dispose();
    });

    testWidgets('graft.builder with CustomScrollView and SliverList', (tester) async {
      final graft = DeepGraft();
      graft.updateVal(2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<int>(
              items: (s) => [10, 20],
              itemBuilder: (item, i) => Text('Sliver: $item'),
              layout: (count, builder) => CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(builder, childCount: count),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sliver: 10'), findsOneWidget);
      expect(find.text('Sliver: 20'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('GraftItemSlot edge cases and reassemble', (tester) async {
      final graft = DeepGraft();
      final slotWidget = graft.item<int>(
        selector: (s) => s.value,
        builder: (val) => Text('SlotItem: $val'),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: slotWidget)));
      expect(find.text('SlotItem: 0'), findsOneWidget);

      // Reassemble
      tester.binding.reassembleApplication();
      await tester.pump();
      expect(find.text('SlotItem: 0'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('GraftItemSlot isEquivalentTo, didUpdateWidget, error selector and equivalence branch', (tester) async {
      final g1 = DeepGraft();
      final g2 = DeepGraft();

      final itemSlot1 = g1.item<int>(selector: (s) => s.value, builder: (v) => Text('$v'));
      final itemSlot2 = g1.item<int>(selector: (s) => s.value, builder: (v) => Text('$v'));
      expect((itemSlot1 as GraftEquivalent).isEquivalentTo(itemSlot2), isTrue);
      expect((itemSlot1 as GraftEquivalent).isEquivalentTo(const SizedBox()), isFalse);

      Widget buildItemSlotTree(DeepGraft g) {
        return MaterialApp(
          home: Scaffold(
            body: g.item<int>(
              selector: (s) => s.value,
              builder: (v) => Text('Val: $v'),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildItemSlotTree(g1));
      expect(find.text('Val: 0'), findsOneWidget);

      // Rebuild with equivalent widget on state notify
      g1.updateVal(0);
      await tester.pump();

      // Switch graft (didUpdateWidget branch)
      g2.updateVal(77);
      await tester.pumpWidget(buildItemSlotTree(g2));
      expect(find.text('Val: 77'), findsOneWidget);

      // Selector throws initially
      final throwingSlot = g1.item<int>(
        selector: (s) => throw FormatException('Initial error'),
        builder: (v) => Text('$v'),
      );
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: throwingSlot)));
      expect(find.byType(SizedBox), findsWidgets);

      g1.dispose();
      g2.dispose();
    });

    testWidgets('_GraftComputation reassemble and didUpdateWidget with same graft', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.compute<int>(
              compute: (s) => s.value,
              builder: (val) => Text('CompVal: $val'),
            ),
          ),
        ),
      );
      expect(find.text('CompVal: 0'), findsOneWidget);

      // Reassemble triggers _GraftComputationState.reassemble
      tester.binding.reassembleApplication();
      await tester.pump();
      expect(find.text('CompVal: 0'), findsOneWidget);

      // didUpdateWidget with same graft instance
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.compute<int>(
              compute: (s) => s.value,
              builder: (val) => Text('UpdatedCompVal: $val'),
            ),
          ),
        ),
      );
      expect(find.text('UpdatedCompVal: 0'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('Custom wrapper and throwing child layout contracts in diff engine', (tester) async {
      final graft = DeepGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                graft.slots(
                  layout: (children) => CustomWrapperWithChild(child: Column(children: children)),
                  slots: [(s) => Text('CustomWrap: ${s.value}')],
                ),
                graft.slots(
                  layout: (children) => CustomThrowingChildWidget(childWidget: Column(children: children)),
                  slots: [(s) => Text('ThrowWrap: ${s.value}')],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CustomWrap: 0'), findsOneWidget);
      expect(find.text('ThrowWrap: 0'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('graft.builder with direct SliverMultiBoxAdaptorWidget root', (tester) async {
      final graft = DeepGraft();

      final sliverWidget = graft.builder<int>(
        items: (s) => [100],
        itemBuilder: (item, i) => Text('DirectSliver: $item'),
        layout: (count, builder) => SliverList(
          delegate: SliverChildBuilderDelegate(builder, childCount: count),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [sliverWidget],
            ),
          ),
        ),
      );

      expect(find.text('DirectSliver: 100'), findsOneWidget);
      graft.dispose();
    });

    testWidgets('GraftItemSlot identical widget check and builder CustomWrapperWithChild dynamic unwrapping', (tester) async {
      final graft = DeepGraft();
      const staticWidget = Text('StaticConst');

      // Test line 853: identical(_cachedWidget, nextWidget)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.item<int>(
              selector: (s) => s.value,
              builder: (v) => staticWidget,
            ),
          ),
        ),
      );
      expect(find.text('StaticConst'), findsOneWidget);

      graft.updateVal(555);
      await tester.pump();
      expect(find.text('StaticConst'), findsOneWidget);

      // Test line 1063: dynamicWidget.child in graft.builder
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<int>(
              items: (s) => [1, 2],
              itemBuilder: (item, i) => Text('WrappedItem: $item'),
              layout: (count, builder) => CustomWrapperWithChild(
                child: ListView.builder(itemCount: count, itemBuilder: builder),
              ),
            ),
          ),
        ),
      );
      expect(find.text('WrappedItem: 1'), findsOneWidget);

      // Test line 1063: Container in graft.builder
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<int>(
              items: (s) => [1, 2],
              itemBuilder: (item, i) => Text('ContainerItem: $item'),
              layout: (count, builder) => Container(
                child: ListView.builder(itemCount: count, itemBuilder: builder),
              ),
            ),
          ),
        ),
      );
      expect(find.text('ContainerItem: 1'), findsOneWidget);

      graft.dispose();
    });
  });
}

class CustomWrapperWithChild extends StatelessWidget {
  final Widget child;
  const CustomWrapperWithChild({required this.child, super.key});

  @override
  Widget build(BuildContext context) => child;
}

class CustomThrowingChildWidget extends StatelessWidget {
  final Widget childWidget;
  const CustomThrowingChildWidget({required this.childWidget, super.key});

  Widget get child => throw UnimplementedError();

  @override
  Widget build(BuildContext context) => childWidget;
}
