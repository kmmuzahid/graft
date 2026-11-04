import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TaggedListState extends GraftState {
  final List<String> tags;

  TaggedListState({required this.tags});

  @override
  GraftProps get props => propsOfCollection(tags);
}

class SingleListFieldState extends GraftState {
  List<String> items;
  int count;

  SingleListFieldState({required this.items, this.count = 0});

  @override
  GraftProps get props => propsOf(items, count);
}

class TaggedListGraft extends Graft<TaggedListState> {
  TaggedListGraft() : super(TaggedListState(tags: ['a', 'b', 'c']));

  void updateTag(int index, String newTag) {
    state
      ..tags[index] = newTag
      ..update();
  }
}

class CollectionObserver extends GraftObserver {
  final List<GraftChange<dynamic>> captured = [];

  @override
  void onChange(dynamic graft, GraftChange change) {
    captured.add(change);
  }
}

void main() {
  group('propsOfCollection & Domain List Property Tests', () {
    test('propsOfCollection flattens collection into individual properties', () {
      final state = TaggedListState(tags: ['apple', 'banana', 'cherry']);
      final props = state.props;

      expect(props.length, 3);
      expect(props[0], 'apple');
      expect(props[1], 'banana');
      expect(props[2], 'cherry');
    });

    test('graft controller tracks diffs accurately through propsOfCollection', () {
      final observer = CollectionObserver();
      Graft.observer = observer;

      final graft = TaggedListGraft();

      // Mutation: update tag at index 1 ('b' -> 'beta')
      graft.updateTag(1, 'beta');

      expect(observer.captured.length, 1);
      final change = observer.captured[0];
      expect(change.isDirty(0), isFalse); // 'a' unchanged
      expect(change.isDirty(1), isTrue); // 'b' -> 'beta' changed
      expect(change.isDirty(2), isFalse); // 'c' unchanged

      graft.dispose();
      Graft.observer = null;
    });

    test('propsOf treats a domain List field as a single property', () {
      final state = SingleListFieldState(items: ['x', 'y'], count: 5);
      final props = state.props;

      // Exactly 2 properties: items (index 0) and count (index 1)
      expect(props.length, 2);
      expect(props[0], ['x', 'y']);
      expect(props[1], 5);
    });
  });
}
