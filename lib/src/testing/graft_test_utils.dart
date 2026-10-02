import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import '../core/graft.dart';
import '../core/graft_state.dart';

/// Declarative testing utility for [Graft], modeled after `blocTest`.
///
/// ### Why use graftTest?
/// - **Blazing Fast (Sub-Millisecond):** Executes pure Dart unit tests without pumping widgets or inflating elements.
/// - **Clean Structure:** Standardizes tests into declarative phases: `build`, `setUp`, `act`, `expect`, `verify`, and `tearDown`.
/// - **Automatic Teardown:** Automatically removes listeners and disposes the [Graft] instance after the test finishes, preventing memory leaks.
/// - **Timeouts & Delays:** Easily handles asynchronous debounce or network latencies via [wait].
///
/// ### Parameters:
/// - [description]: The name and explanation of the test case.
/// - [build]: A factory closure returning a fresh instance of the [Graft] under test.
/// - [setUp]: Optional hook executed before [act] to set up mocks, stubs, or seed state.
/// - [act]: Optional action closure to trigger business logic methods on the Graft.
/// - [wait]: Optional [Duration] to wait (e.g. for streams or debounce timers) before running expectations.
/// - [expect]: Optional closure returning a Matcher or `List` of expected emitted state objects.
/// - [verify]: Optional verification hook to perform post-execution assertions (e.g. mock calls or final state values).
/// - [tearDown]: Optional cleanup hook executed after testing completes.
///
/// ### Example:
/// ```dart
/// graftTest<UserGraft, UserState>(
///   'updates profile name and notifies listeners',
///   build: () => UserGraft(),
///   act: (graft) => graft.updateName('Alice'),
///   expect: () => [
///     isA<UserState>().having((s) => s.name, 'name', 'Alice'),
///   ],
///   verify: (graft) {
///     expect(graft.state.name, 'Alice');
///   },
/// );
/// ```
void graftTest<G extends Graft<S>, S extends GraftState>(
  String description, {
  required G Function() build,
  void Function(G graft)? setUp,
  FutureOr<void> Function(G graft)? act,
  Duration? wait,
  dynamic Function()? expect,
  void Function(G graft)? verify,
  void Function(G graft)? tearDown,
  dynamic tags,
}) {
  test(
    description,
    () async {
      final states = <S>[];
      final graft = build();

      setUp?.call(graft);

      // Listen for emitted states
      void listener() {
        states.add(graft.state);
      }

      graft.addListener(listener);

      try {
        if (act != null) {
          await act(graft);
        }

        if (wait != null) {
          await Future.delayed(wait);
        }

        if (expect != null) {
          final expected = expect();
          expectLater(states, expected);
        }

        verify?.call(graft);
      } finally {
        graft.removeListener(listener);
        tearDown?.call(graft);
        if (!graft.isDisposed) {
          graft.dispose();
        }
      }
    },
    tags: tags,
  );
}

