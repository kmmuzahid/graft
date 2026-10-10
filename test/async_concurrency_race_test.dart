import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class SearchState extends GraftState {
  GraftAsync<String> searchResult;
  SearchState({this.searchResult = const GraftAsync.idle()});

  @override
  GraftProps get props => propsOf(searchResult);
}

class SearchGraft extends Graft<SearchState> {
  SearchGraft() : super(SearchState());

  Future<void> search(String query, Duration delay) async {
    await runAsync<String>(
      task: () async {
        await Future.delayed(delay);
        return 'Result for: $query';
      },
      onUpdate: (res) {
        state
          ..searchResult = res
          ..update();
      },
    );
  }

  Future<void> failingSearch(Duration delay) async {
    await runAsync<String>(
      task: () async {
        await Future.delayed(delay);
        throw Exception('Search failed');
      },
      onUpdate: (res) {
        state
          ..searchResult = res
          ..update();
      },
    );
  }
}

void main() {
  group('Pillar 5: Async Concurrency & Stale Response Guard Tests', () {
    test('runAsync drops stale response when newer task is launched before first completes', () async {
      final graft = SearchGraft();

      // Launch Task 1: Slow (100ms)
      final future1 = graft.search('slow', const Duration(milliseconds: 100));

      // After 20ms, launch Task 2: Fast (20ms)
      await Future.delayed(const Duration(milliseconds: 20));
      final future2 = graft.search('fast', const Duration(milliseconds: 20));

      // Wait for both to finish
      await Future.wait([future1, future2]);

      // State MUST contain Task 2's result ('Result for: fast')
      // Task 1's late response must have been dropped!
      expect(graft.state.searchResult, isA<AsyncData<String>>());
      final data = graft.state.searchResult as AsyncData<String>;
      expect(data.data, 'Result for: fast');

      graft.dispose();
    });

    test('runAsync captures errors from latest task only', () async {
      final graft = SearchGraft();

      // Launch Task 1: Slow failure (100ms)
      final future1 = graft.failingSearch(const Duration(milliseconds: 100));

      // Launch Task 2: Fast success (20ms)
      await Future.delayed(const Duration(milliseconds: 20));
      final future2 = graft.search('fast_success', const Duration(milliseconds: 20));

      await Future.wait([future1, future2]);

      // State must be successful Task 2, NOT overwritten by Task 1's error!
      expect(graft.state.searchResult, isA<AsyncData<String>>());
      final data = graft.state.searchResult as AsyncData<String>;
      expect(data.data, 'Result for: fast_success');

      graft.dispose();
    });

    test('Sequential runAsync calls execute and update state cleanly when no overlap occurs', () async {
      final graft = SearchGraft();

      await graft.search('first', const Duration(milliseconds: 10));
      expect(graft.state.searchResult.dataOrNull, 'Result for: first');

      await graft.search('second', const Duration(milliseconds: 10));
      expect(graft.state.searchResult.dataOrNull, 'Result for: second');

      graft.dispose();
    });
  });
}
