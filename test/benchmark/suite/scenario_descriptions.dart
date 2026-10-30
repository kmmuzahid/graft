// -----------------------------------------------------------------------------
// Scenario Descriptions: Transparent 1-2 Line Benchmark Methodologies
// -----------------------------------------------------------------------------

/// Transparent methodology descriptions for each benchmark scenario.
/// Explains in 1-2 lines what was tested, how it was timed, and correctness criteria.
abstract final class ScenarioDescriptions {
  static const Map<String, String> _scenarios = {
    'A1_10k_increments':
        'Measures pure in-place state mutation throughput across 10,000 synchronous scalar increments without UI listeners, verifying zero-allocation GC footprint and bitmask diff speed.',
    'A2_100k_increments':
        'Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments, verifying JIT optimization stability and zero memory bloat under continuous CPU load.',
    'A3_multi_field_5':
        'Executes 2,000 multi-property transactions modifying 5 distinct fields simultaneously (10,000 total mutations), measuring SIMD register diffing and single-notification batching efficiency.',
    'A4_depth8_nested':
        'Mutates a leaf node nested 8 levels deep in an object hierarchy, measuring ancestor dirty-flag propagation latency and evaluating direct root-pointer notification dispatch.',
    'B1_10_slot_column_120_frames':
        'Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0, measuring frame rendering latency and asserting zero rebuilds across all 9 static siblings.',
    'B2_50_slot_column_120_frames':
        'Evaluates high-density rebuild isolation across 120 animation frames in a 50-slot Column, verifying that dirty-mask dispatch scales smoothly without leaking rebuilds to 49 static slots.',
    'C1_5k_items_300_rapid_updates':
        'Performs 300 rapid updates to an item in a virtualized 5,000-item ListView, measuring localized slot rebuild latency and proving zero static rebuilds on the 4,999 unaffected items.',
    'C2_20k_items_300_rapid_updates':
        'Tests ultra-scale list virtualization by firing 300 updates into a 20,000-item ListView, verifying that receiver indexing maintains O(1) dispatch time regardless of list size.',
    'C3_random_insert_remove_100x':
        'Executes 100 random insert and remove operations across an indexed collection of 1,000 items, measuring array splice performance, structural diffing, and collection notification overhead.',
    'D1_product_catalog_and_cart':
        'Simulates a multi-controller e-commerce workflow with 200 catalog items and reactive cart totals, measuring cross-controller synchronization speed and zero-GC state sharing.',
    'D2_form_12_interdependent_fields':
        'Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation recalculations, measuring branchless register diffing and atomic dirty-mask resolution.',
    'D3_navigation_and_dialog_sharing':
        'Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by an underlying page, measuring transient controller borrowing and lifecycle safety.',
    'E1_route_push_pop_and_dialog_lifecycle':
        'Automates 50 route transitions to stress-test memory cleanup, asserting that route-scoped controllers are automatically disposed without leaks or lingering event listeners.',
    'E2_hot_reload_reassemble_simulation':
        'Simulates 30 consecutive Flutter hot reload cycles calling reassemble(), measuring state reconstruction speed, observer re-registration, and zero state corruption.',
    'E3_disposed_controller_access_safety':
        'Fires 1,000 updates to a previously disposed controller, verifying that Graft safely handles stale references with zero exceptions, zero crashes, and zero memory leaks.',
    'F1_reactive_diamond_glitch_test':
        r'Executes 5,000 rapid updates in a reactive diamond graph ($A \to B, C \to D$), asserting that downstream consumer $D$ evaluates exactly once per update with zero transient glitches.',
    'G1_transactional_multi_field_batching':
        'Tests multi-field transaction containment across 2,000 updates mutating 5 fields each, proving that exactly one notification fires per transaction with zero wasted notifications.',
  };

  /// Returns the 1-2 line methodology description for a scenario.
  static String forScenario(String scenarioName) {
    return _scenarios[scenarioName] ??
        'Empirical benchmark measuring throughput, latency distribution, rebuild containment, and memory stability.';
  }
}

