import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class SearchState extends GraftState {
  String? searchResult;
  bool isLoading;
  String? error;

  SearchState({
    this.searchResult,
    this.isLoading = false,
    this.error,
  });

  @override
  GraftProps get props => propsOf(searchResult, isLoading, error);
}

class SearchGraft extends Graft<SearchState> {
  int _requestId = 0;

  SearchGraft() : super(SearchState());

  Future<void> search(String query, Duration delay) async {
    final currentId = ++_requestId;
    state
      ..isLoading = true
      ..error = null
      ..update();

    await Future.delayed(delay);

    // Stale guard: only apply if this request is still the latest one
    if (currentId != _requestId) return;

    state
      ..searchResult = 'Result for: $query'
      ..isLoading = false
      ..update();
  }

  Future<void> failingSearch(Duration delay) async {
    final currentId = ++_requestId;
    state
      ..isLoading = true
      ..error = null
      ..update();

    await Future.delayed(delay);

    if (currentId != _requestId) return;

    state
      ..error = 'Search failed'
      ..isLoading = false
      ..update();
  }
}

void main() {
  group('Standard Dart Async Concurrency & Stale Response Guard Tests', () {
    test('drops stale response when newer task is launched before first completes', () async {
      final graft = SearchGraft();

      // Launch Task 1: Slow (100ms)
      final future1 = graft.search('slow', const Duration(milliseconds: 100));

      // After 20ms, launch Task 2: Fast (20ms)
      await Future.delayed(const Duration(milliseconds: 20));
      final future2 = graft.search('fast', const Duration(milliseconds: 20));

      // Wait for both to finish
      await Future.wait([future1, future2]);

      // State MUST contain Task 2's result ('Result for: fast')
      // Task 1's late response was dropped
      expect(graft.state.searchResult, 'Result for: fast');
      expect(graft.state.isLoading, false);

      graft.dispose();
    });

    test('captures errors from latest task only', () async {
      final graft = SearchGraft();

      // Launch Task 1: Slow failure (100ms)
      final future1 = graft.failingSearch(const Duration(milliseconds: 100));

      // Launch Task 2: Fast success (20ms)
      await Future.delayed(const Duration(milliseconds: 20));
      final future2 = graft.search('fast_success', const Duration(milliseconds: 20));

      await Future.wait([future1, future2]);

      // State must be successful Task 2, NOT overwritten by Task 1's error!
      expect(graft.state.searchResult, 'Result for: fast_success');
      expect(graft.state.error, isNull);
      expect(graft.state.isLoading, false);

      graft.dispose();
    });

    test('Sequential async calls execute and update state cleanly when no overlap occurs', () async {
      final graft = SearchGraft();

      await graft.search('first', const Duration(milliseconds: 10));
      expect(graft.state.searchResult, 'Result for: first');

      await graft.search('second', const Duration(milliseconds: 10));
      expect(graft.state.searchResult, 'Result for: second');

      graft.dispose();
    });
  });
}
