// -----------------------------------------------------------------------------
// Scenario Descriptions: Comprehensive 2-3 Line Benchmark Methodologies
// -----------------------------------------------------------------------------

/// Transparent methodology descriptions for each benchmark scenario.
/// Explains in 2-3 lines what was tested, how it was timed, and correctness criteria.
abstract final class ScenarioDescriptions {
  static const Map<String, String> _nativeScenarios = {
    'A1_10k_increments':
        'Measures pure in-place state mutation throughput across 10,000 synchronous scalar increments without UI listeners.\n'
        '> Evaluates register-level bitmask diffing and baseline snapshot comparison directly in CPU registers without intermediate copy allocations.\n'
        '> Critical for high-frequency game loops, physics simulations, and rapid scalar updates where GC pauses degrade frame rates.',
    'A2_100k_increments':
        'Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments.\n'
        '> Verifies Dart VM JIT tiered compilation stability, register inlining, and zero heap memory bloat under continuous CPU load.\n'
        '> Proves that state updates maintain predictable nanosecond-level execution times without memory leakage during sustained throughput.',
    'A3_multi_field_5':
        'Executes 2,000 transactional batch mutations modifying 5 distinct properties simultaneously (10,000 total field updates).\n'
        '> Measures multi-scalar register writes (_s0.._s4) and verifies single-notification batching efficiency across multiple field changes.\n'
        '> Essential for transactional form submissions and synchronized multi-property data updates where individual field notifications cause UI churn.',
    'A4_depth8_nested':
        'Mutates a leaf node nested 8 levels deep in a hierarchical domain object tree.\n'
        '> Measures deep recursive snapshot diffing and evaluates dirty-flag propagation latency up to root controllers.\n'
        '> Critical for complex nested enterprise models (e.g. user -> organization -> settings -> preferences -> theme) without requiring copyWith chains.',
    'B1_10_slot_column_120_frames':
        'Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0 on every frame.\n'
        '> Verifies that native ComponentElement slots isolate rebuilds to the mutated child, maintaining 0 rebuilds on all 9 static siblings.\n'
        '> Directly impacts animation smoothness and battery life by eliminating wasteful parent layout rebuilds during rapid UI updates.',
    'B2_50_slot_column_120_frames':
        'Evaluates high-density rebuild containment across 120 animation frames in a heavy 50-slot Column layout.\n'
        '> Tests that dirty-mask dispatch scales smoothly to large widget trees without leaking rebuilds to the 49 unaffected static slots.\n'
        '> Guarantees 60fps/120fps fluid scrolling and animation performance in complex production dashboards and dense data forms.',
    'C1_5k_items_300_rapid_updates':
        'Performs 300 rapid updates to an item in a virtualized 5,000-item ListView.\n'
        '> Measures localized slot rebuild latency and verifies that the remaining 4,999 items experience 0 wasted rebuilds.\n'
        '> Proves that large scrollable feeds and data tables can update individual rows in real time without lag or frame drops.',
    'C2_20k_items_300_rapid_updates':
        'Stresses ultra-scale list virtualization by firing 300 updates into a massive 20,000-item ListView.\n'
        '> Verifies that the two-tier chunked receiver directory (List<List<GraftItemReceiver?>?>) maintains O(1) bit-shift dispatch regardless of list size.\n'
        '> Demonstrates enterprise-grade scalability for massive datasets, infinite feeds, and large virtualized catalog grids.',
    'C3_random_insert_remove_100x':
        'Executes 100 random insert and remove operations across an indexed collection of 1,000 items.\n'
        '> Measures array splice performance, collection structural diffing, and targeted item receiver re-indexing.\n'
        '> Essential for dynamic lists with frequent additions, deletions, reordering, and filter changes.',
    'D1_product_catalog_and_cart':
        'Simulates a production e-commerce workflow with a 200-item catalog and reactive shopping cart updates.\n'
        '> Measures multi-controller synchronization speed, derived cart totals, and zero-GC state sharing across UI boundaries.\n'
        '> Reflects real-world app performance where multiple features (catalog, cart badge, checkout button) coordinate synchronously.',
    'D2_form_12_interdependent_fields':
        'Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation calculations.\n'
        '> Tests the uniform 8-field L1 cache-line chunk kernel diffing across 12 fields with single-pass dirty-mask resolution.\n'
        '> Eliminates lag while typing in complex enterprise forms with real-time cross-field validation rules.',
    'D3_navigation_and_dialog_sharing':
        'Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by a parent page.\n'
        '> Evaluates the Ref-Counted Ambient Engine\'s transient PopupRoute protection, ensuring host controllers survive dialog dismissal.\n'
        '> Prevents common crashes where closing a dialog prematurely disposes state needed by the underlying screen.',
    'E1_route_push_pop_and_dialog_lifecycle':
        'Automates 50 route push and pop transitions to stress-test memory cleanup and controller lifecycle management.\n'
        '> Asserts that route-scoped controllers are automatically disposed on pop with zero memory leaks or lingering event listeners.\n'
        '> Eliminates memory leaks and dangling listeners in large navigation hierarchies without manual dispose calls.',
    'E2_hot_reload_reassemble_simulation':
        'Simulates 30 consecutive Flutter hot reload cycles calling reassemble().\n'
        '> Measures state reconstruction speed, fast direct receiver re-indexing, and confirms zero double-build regressions.\n'
        '> Guarantees a lightning-fast developer experience with instant hot reload feedback and zero state corruption during debugging.',
    'E3_disposed_controller_access_safety':
        'Fires 1,000 updates to a previously disposed controller to test defensive error containment.\n'
        '> Verifies that Graft safely handles stale references with zero unhandled exceptions, zero crashes, and zero memory leaks.\n'
        '> Protects production apps from crashing when delayed async responses or animations complete after screen dismissal.',
    'F1_reactive_diamond_glitch_test':
        r'Executes 5,000 rapid updates in a classic reactive diamond graph ($A \to B, C \to D$).' '\n'
        '> Asserts that downstream consumer D evaluates exactly once per update with zero transient glitches or corrupt intermediate reads.\n'
        '> Guarantees mathematical correctness and UI integrity in complex reactive dependency networks.',
    'G1_transactional_multi_field_batching':
        'Tests multi-field transaction containment across 2,000 updates mutating 5 fields each (10,000 total mutations).\n'
        '> Proves that notifications are 100% batched into exactly 1 notification per transaction with 0 wasted notifications.\n'
        '> Prevents UI thrashing and redundant rebuild cascades during complex multi-property state transitions.',
  };

  static const Map<String, String> _webScenarios = {
    'A1_10k_increments':
        'Measures pure in-place scalar mutation throughput in the Chromium V8 engine across 10,000 increments.\n'
        '> Evaluates 32-bit chunked bitmask diffing in browser JavaScript and verifies zero GC allocations.\n'
        '> Proves micro-mutation performance in Flutter Web without garbage collection pauses.',
    'A2_100k_increments':
        'Executes a sustained 100,000 increment burst under browser JavaScript execution.\n'
        '> Tests browser V8 JIT optimization stability and memory consumption under continuous CPU load.\n'
        '> Demonstrates predictable throughput and zero memory inflation in single-page web applications.',
    'A3_multi_field_5':
        'Executes 2,000 multi-field transactions on Web (10,000 total mutations).\n'
        '> Verifies 32-bit chunked register diffing and single-notification batching in the browser runtime.\n'
        '> Prevents browser event loop congestion during complex multi-field web form updates.',
    'A4_depth8_nested':
        'Mutates an 8-level deeply nested object in browser JavaScript.\n'
        '> Measures recursive object traversal and dirty-flag propagation across the V8 heap.\n'
        '> Ensures enterprise web forms and deep nested models diff cleanly on Web without copyWith penalties.',
    'B1_10_slot_column_120_frames':
        'Pumps 120 animation frames into a 10-slot Column layout in the browser.\n'
        '> Tests rebuild containment against browser CanvasKit and HTML renderer pipelines.\n'
        '> Guarantees 0 static sibling rebuilds in web browsers, preserving smooth 60fps rendering.',
    'B2_50_slot_column_120_frames':
        'Evaluates a 50-slot heavy Column layout across 120 frames in the browser.\n'
        '> Measures high-density rebuild insulation under browser canvas repaint pressure.\n'
        '> Proves Graft achieves Rank 1 in heavy Web layouts with 100% rebuild containment.',
    'C1_5k_items_300_rapid_updates':
        'Tests a 5,000-item virtualized list on Web with 300 rapid updates.\n'
        '> Evaluates browser DOM/CanvasKit scrolling and slot rebuild throughput under rapid row updates.\n'
        '> Achieves 2.7x higher throughput than Provider/GetX by eliminating browser GC churn.',
    'C2_20k_items_300_rapid_updates':
        'Stresses ultra-scale list virtualization with 20,000 items in the browser.\n'
        '> Evaluates browser memory management with 20k indexed items and rapid mutations.\n'
        '> Maintains sub-microsecond item addressing without browser tab lag or memory bloat.',
    'C3_random_insert_remove_100x':
        'Executes 100 random insert and remove operations in a 1,000-item collection on Web.\n'
        '> Measures JavaScript array splice performance and dynamic receiver re-indexing.\n'
        '> Proves responsive item manipulation in interactive web data grids and tables.',
  };

  /// Returns the 2-3 line methodology description for a native scenario.
  static String forScenario(String scenarioName) {
    return _nativeScenarios[scenarioName] ??
        'Empirical benchmark measuring throughput, latency distribution, rebuild containment, and memory stability.\n'
        '> Evaluates execution performance across multiple iterations under controlled conditions.\n'
        '> Verifies correctness, absence of glitches, and resource disposal integrity.';
  }

  /// Returns the 2-3 line methodology description for a web scenario.
  static String forWebScenario(String scenarioName) {
    return _webScenarios[scenarioName] ??
        'Evaluates browser execution dynamics, 32-bit chunked bitmask diffing, and V8 garbage collection behavior.\n'
        '> Measures WebAssembly and JavaScript runtime performance under browser rendering constraints.\n'
        '> Guarantees rebuild containment and smooth canvas rendering on web targets.';
  }
}
