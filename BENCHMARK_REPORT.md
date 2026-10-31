# 🚀 Late 2026 Flutter State Management Benchmark Report

**A Comprehensive, Empirical Comparison of Graft vs. Leading State Management Solutions**

---

## 📋 Executive Summary

This benchmark suite evaluates **Graft** against the primary Flutter state management paradigms:
1. **Graft** (`1.0.0-alpha.7`) — Self-optimizing bitmask diff engine with zero-wrapper ambient lifecycle
2. **Riverpod (Notifier / Codegen-style)** — Class-based `Notifier` with immutable transitions
3. **Riverpod (StateNotifier / Legacy)** — `StateNotifier` without code generation
4. **flutter_bloc + Cubit** (`8.1.6`) — Stream/Equatable domain state with `BlocSelector`
5. **signals_flutter** (`5.5.1`) — Preact fine-grained reactive signals and `Watch`
6. **GetX** (`4.7.3`) — Reactive `.obs` with `Obx` element micro-rebuilds
7. **Provider** (`6.1.5+1`) — Classical `ChangeNotifier` + `Selector`

---

## ⚙️ Environment & Methodology

| Specification | Value |
| :--- | :--- |
| **Flutter SDK** | `Flutter 3.47.6 (stable channel)` |
| **Dart SDK** | `Dart 3.13.5 (stable)` |
| **Operating System & Architecture** | `Version 27.0.1 (Build 26A434)` |
| **Execution Mode** | Profile / Benchmark Mode |
| **Warm-up Protocol** | 3 to 25 full iterations discarded per scenario |
| **Measurement Protocol** | **Minimum 15 measured runs per scenario** |
| **Metrics Tracked** | Latency (Mean, Median, p95), Target Rebuilds, Static Wasted Rebuilds, Glitches, Wasted Notifications, Resource Leaks |

---

## 🏆 Section A: Unified Correctness & Reliability Scorecard

Raw speed without architectural correctness or rebuild fidelity is actively harmful in production.
The scorecard below aggregates empirical correctness, glitch resistance, and rebuild integrity across all scenarios:

| Framework | Overall Status | Scenarios Run | Scenarios Failed | Reactive Glitches | Wasted Notifications | Resource Leaks | Rebuild Efficiency | Architectural Verdict |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **BLoC** | ✅ **PASSED** | 3 | 0 | 0 | 0 | 0 | 100.0% | 🛡️ **Flawless (Immutable Stream & Cubit)** |
| **BLoC (Cubit)** | ✅ **PASSED** | 13 | 0 | 0 | 0 | 0 | 100.0% | 🛡️ **Flawless (Immutable Stream & Cubit)** |
| **GetX** | ⚠️ **DEGRADED** | 10 | 2 | ❌ **5000** | ❌ **8000** | 0 | 100.0% | ❌ **Flawed (Unsorted Workers Glitch & Unbatched Churn)** |
| **GetX (RxList)** | ✅ **PASSED** | 1 | 0 | 0 | 0 | 0 | 100.0% | ⚡ **Fast (Specialized List Mutation)** |
| **Graft** | ✅ **PASSED** | 15 | 0 | 0 | 0 | 0 | 100.0% | ⚡ **Flawless (Register Bitmask & Ambient Engine)** |
| **Graft (leaf slot)** | ✅ **PASSED** | 2 | 0 | 0 | 0 | 0 | 100.0% | ⚡ **Flawless (Register Bitmask & Ambient Engine)** |
| **Graft (slots)** | ✅ **PASSED** | 2 | 0 | 0 | 0 | 0 | 100.0% | ⚡ **Flawless (Register Bitmask & Ambient Engine)** |
| **Provider** | ✅ **PASSED** | 10 | 0 | 0 | 0 | 0 | 100.0% | ⚠️ **Pass (Requires Manual Selector Boilerplate)** |
| **Riverpod (Notifier)** | ✅ **PASSED** | 11 | 0 | 0 | 0 | 0 | 100.0% | 🛡️ **Flawless (Topological Provider Graph)** |
| **Riverpod (StateNotifier)** | ✅ **PASSED** | 6 | 0 | 0 | 0 | 0 | 100.0% | 🛡️ **Flawless (Topological Provider Graph)** |
| **Signals** | ✅ **PASSED** | 12 | 0 | 0 | 0 | 0 | 100.0% | 🛡️ **Flawless (Reactive Preact DAG)** |

---

## 🏗️ Section B: Widget Build Count & Rebuild Efficiency Audit

This section audits widget rebuild containment across Column layouts and virtualized ListView builders.
A **100.0% Rebuild Efficiency** indicates that zero static siblings or off-screen widgets were rebuilt.

| Scenario | Framework | Dynamic Builds (Target) | Static Builds (Wasted) | Total Builds | Rebuild Efficiency | Wasted Rebuild Rate | Rebuild Containment |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `B1_10_slot_column_120_frames` | **Graft (leaf slot)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **Graft (slots)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **Riverpod (Notifier)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **Riverpod (StateNotifier)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **BLoC (Cubit)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **Signals** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **GetX** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B1_10_slot_column_120_frames` | **Provider** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Graft (leaf slot)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Graft (slots)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Riverpod (Notifier)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Riverpod (StateNotifier)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **BLoC (Cubit)** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Signals** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **GetX** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `B2_50_slot_column_120_frames` | **Provider** | 120 | 0 | 120 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **Graft** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **Riverpod (Notifier)** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **BLoC (Cubit)** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **Signals** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **GetX** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C1_5k_items_300_rapid_updates` | **Provider** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **Graft** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **Riverpod (Notifier)** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **BLoC (Cubit)** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **Signals** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **GetX** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |
| `C2_20k_items_300_rapid_updates` | **Provider** | 300 | 0 | 300 | 100.0% | 0.0% | ✅ **100% Isolated** |

---

## 🛡️ Section C: The Reactive Glitch & Diamond Dependency Audit

Evaluates the classic reactive diamond dependency ($A \to (B, C) \to D$) across 5,000 rapid updates.
Without topological DAG sorting or synchronous getters, frameworks suffer from **glitches** (reading intermediate corrupt state):

| Framework | Root Updates | Expected Evals | Actual Evals | Glitches Caught | Glitch Rate | Correctness Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Graft** | 5000 | 5000 | 5000 | 0 | 0.0% (Glitch-Free) | ✅ **GLITCH-FREE** |
| **Signals** | 5000 | 5000 | 5000 | 0 | 0.0% (Glitch-Free) | ✅ **GLITCH-FREE** |
| **Riverpod (Notifier)** | 5000 | 5000 | 5000 | 0 | 0.0% (Glitch-Free) | ✅ **GLITCH-FREE** |
| **BLoC (Cubit)** | 5000 | 5000 | 5000 | 0 | 0.0% (Glitch-Free) | ✅ **GLITCH-FREE** |
| **GetX** | 5000 | 5000 | 10000 | 5000 | 50.0% (Corrupt Reads) | ❌ **GLITCHED (2x Evals)** |

---

## 🧪 Section D: Transactional Batching & Notification Burst Efficiency

Measures notification containment when 2,000 multi-field transactions modify 5 fields simultaneously (10,000 total mutations):

| Framework | Transactions | Total Field Mutations | Notifications Fired | Wasted Notifications | Batching Efficiency | Notification Containment |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **BLoC (Cubit)** | 2000 | 10000 | 2000 | 0 | 100.0% | ✅ **100% Batched (1 fire/txn)** |
| **Graft** | 2000 | 10000 | 2000 | 0 | 100.0% | ✅ **100% Batched (1 fire/txn)** |
| **Riverpod (Notifier)** | 2000 | 10000 | 2000 | 0 | 100.0% | ✅ **100% Batched (1 fire/txn)** |
| **Signals** | 2000 | 10000 | 2000 | 0 | 100.0% | ✅ **100% Batched (1 fire/txn)** |
| **GetX** | 2000 | 10000 | 10000 | 8000 | 20.0% | ❌ **UNBATCHED (5x wasted fires)** |

---

## 📊 Section E: Scenario-by-Scenario Benchmark Latencies

Presents detailed execution timing distributions (mean, median, p95, min, max, standard deviation) and GC object churn across at least 15 measured runs per framework.

### 🔹 Scenario: A1_10k_increments

> Measures pure in-place state mutation throughput across 10,000 synchronous scalar increments without UI listeners.
> Evaluates register-level bitmask diffing and baseline snapshot comparison directly in CPU registers without intermediate copy allocations.
> Critical for high-frequency game loops, physics simulations, and rapid scalar updates where GC pauses degrade frame rates.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.05 | 0.05 | 0.05 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.12 | 0.12 | 0.14 | 0.11 | 0.15 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.14 | 0.12 | 0.20 | 0.12 | 0.22 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.21 | 0.12 | 0.16 | 0.11 | 1.38 | 0.32 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.56 | 0.55 | 0.62 | 0.50 | 0.65 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.81 | 0.81 | 0.83 | 0.78 | 0.86 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 2.25 | 2.24 | 2.33 | 2.16 | 2.36 | 0.07 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

> Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments.
> Verifies Dart VM JIT tiered compilation stability, register inlining, and zero heap memory bloat under continuous CPU load.
> Proves that state updates maintain predictable nanosecond-level execution times without memory leakage during sustained throughput.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.56 | 0.55 | 0.65 | 0.53 | 0.71 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 1.24 | 1.22 | 1.29 | 1.17 | 1.44 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 1.33 | 1.33 | 1.41 | 1.28 | 1.42 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 3.51 | 3.37 | 5.54 | 1.05 | 8.98 | 2.16 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 5.70 | 5.55 | 6.04 | 5.38 | 6.91 | 0.40 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 7.84 | 7.87 | 7.96 | 7.70 | 7.99 | 0.09 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 21.98 | 21.99 | 22.23 | 21.82 | 22.27 | 0.15 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

> Executes 2,000 transactional batch mutations modifying 5 distinct properties simultaneously (10,000 total field updates).
> Measures multi-scalar register writes (_s0.._s4) and verifies single-notification batching efficiency across multiple field changes.
> Essential for transactional form submissions and synchronized multi-property data updates where individual field notifications cause UI churn.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.11 | 0.10 | 0.12 | 0.10 | 0.14 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.14 | 0.13 | 0.15 | 0.13 | 0.24 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.35 | 0.35 | 0.37 | 0.33 | 0.43 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.39 | 0.18 | 0.24 | 0.18 | 3.24 | 0.79 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.57 | 0.56 | 0.62 | 0.53 | 0.68 | 0.04 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.92 | 0.90 | 0.99 | 0.87 | 1.01 | 0.05 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 8.23 | 8.22 | 8.38 | 7.99 | 8.53 | 0.13 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

> Mutates a leaf node nested 8 levels deep in a hierarchical domain object tree.
> Measures deep recursive snapshot diffing and evaluates dirty-flag propagation latency up to root controllers.
> Critical for complex nested enterprise models (e.g. user -> organization -> settings -> preferences -> theme) without requiring copyWith chains.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.03 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.02 | 0.01 | 0.03 | 0.01 | 0.04 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.17 | 0.03 | 0.04 | 0.03 | 2.12 | 0.54 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 0.24 | 0.24 | 0.30 | 0.13 | 0.39 | 0.08 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Riverpod (Notifier)** | 0.61 | 0.52 | 1.05 | 0.49 | 1.40 | 0.26 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 7 | **Signals** | 1.78 | 0.64 | 3.89 | 0.47 | 6.07 | 1.76 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

> Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0 on every frame.
> Verifies that native ComponentElement slots isolate rebuilds to the mutated child, maintaining 0 rebuilds on all 9 static siblings.
> Directly impacts animation smoothness and battery life by eliminating wasteful parent layout rebuilds during rapid UI updates.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 12.67 | 12.61 | 13.56 | 11.89 | 14.15 | 0.67 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft (leaf slot)** | 13.07 | 12.95 | 13.84 | 12.42 | 13.94 | 0.45 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (StateNotifier)** | 13.34 | 13.42 | 14.38 | 12.06 | 14.50 | 0.73 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **GetX** | 13.36 | 13.03 | 14.78 | 12.50 | 14.98 | 0.79 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Graft (slots)** | 13.49 | 13.31 | 14.24 | 12.67 | 15.23 | 0.66 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Signals** | 14.38 | 14.38 | 15.98 | 13.11 | 16.32 | 1.00 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **BLoC (Cubit)** | 14.94 | 14.06 | 20.57 | 13.13 | 21.22 | 2.52 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Provider** | 16.26 | 15.96 | 19.27 | 13.77 | 20.11 | 2.00 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

> Evaluates high-density rebuild containment across 120 animation frames in a heavy 50-slot Column layout.
> Tests that dirty-mask dispatch scales smoothly to large widget trees without leaking rebuilds to the 49 unaffected static slots.
> Guarantees 60fps/120fps fluid scrolling and animation performance in complex production dashboards and dense data forms.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 25.85 | 25.61 | 27.45 | 23.50 | 27.49 | 1.24 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft (leaf slot)** | 26.19 | 25.70 | 27.37 | 25.01 | 27.57 | 1.00 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 26.28 | 26.34 | 28.15 | 24.11 | 29.56 | 1.48 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 26.46 | 26.39 | 29.32 | 24.26 | 29.54 | 1.53 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 27.13 | 26.47 | 28.99 | 25.61 | 29.12 | 1.33 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **GetX** | 27.56 | 27.15 | 29.17 | 26.10 | 30.23 | 1.21 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Provider** | 29.36 | 28.89 | 31.71 | 26.83 | 32.12 | 1.64 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Graft (slots)** | 32.71 | 28.49 | 45.46 | 25.72 | 66.44 | 10.82 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

> Performs 300 rapid updates to an item in a virtualized 5,000-item ListView.
> Measures localized slot rebuild latency and verifies that the remaining 4,999 items experience 0 wasted rebuilds.
> Proves that large scrollable feeds and data tables can update individual rows in real time without lag or frame drops.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.32 | 28.29 | 29.09 | 27.10 | 30.06 | 0.70 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 31.37 | 31.40 | 32.24 | 29.84 | 33.39 | 0.82 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 🥉 | **Signals** | 31.70 | 30.31 | 33.57 | 28.80 | 49.59 | 5.12 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 46.79 | 46.80 | 49.45 | 44.34 | 51.13 | 1.87 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **Provider** | 55.53 | 55.84 | 57.63 | 52.36 | 58.80 | 2.00 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 6 | **GetX** | 65.45 | 64.19 | 66.23 | 61.60 | 84.87 | 5.51 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

> Stresses ultra-scale list virtualization by firing 300 updates into a massive 20,000-item ListView.
> Verifies that the two-tier chunked receiver directory (List<List<GraftItemReceiver?>?>) maintains O(1) bit-shift dispatch regardless of list size.
> Demonstrates enterprise-grade scalability for massive datasets, infinite feeds, and large virtualized catalog grids.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.16 | 29.80 | 38.05 | 29.40 | 50.17 | 5.55 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 41.47 | 37.77 | 62.20 | 32.58 | 64.29 | 10.69 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 47.00 | 45.15 | 49.41 | 42.63 | 71.76 | 7.08 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 65.14 | 63.65 | 65.59 | 60.12 | 92.13 | 7.60 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 73.26 | 71.01 | 72.85 | 68.27 | 105.16 | 8.95 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 79.09 | 75.59 | 91.23 | 68.75 | 103.22 | 9.14 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

> Executes 100 random insert and remove operations across an indexed collection of 1,000 items.
> Measures array splice performance, collection structural diffing, and targeted item receiver re-indexing.
> Essential for dynamic lists with frequent additions, deletions, reordering, and filter changes.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.28 | 0.28 | 0.31 | 0.25 | 0.34 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX (RxList)** | 0.84 | 0.83 | 0.91 | 0.78 | 0.91 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 1.00 | 0.47 | 4.25 | 0.43 | 4.65 | 1.41 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 1.21 | 0.49 | 5.53 | 0.46 | 6.13 | 1.88 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 1.24 | 0.54 | 5.57 | 0.51 | 5.99 | 1.85 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

> Simulates a production e-commerce workflow with a 200-item catalog and reactive shopping cart updates.
> Measures multi-controller synchronization speed, derived cart totals, and zero-GC state sharing across UI boundaries.
> Reflects real-world app performance where multiple features (catalog, cart badge, checkout button) coordinate synchronously.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.04 | 0.00 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

> Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation calculations.
> Tests the uniform 8-field L1 cache-line chunk kernel diffing across 12 fields with single-pass dirty-mask resolution.
> Eliminates lag while typing in complex enterprise forms with real-time cross-field validation rules.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.05 | 0.05 | 0.05 | 0.05 | 0.05 | 0.00 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.08 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

> Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by a parent page.
> Evaluates the Ref-Counted Ambient Engine's transient PopupRoute protection, ensuring host controllers survive dialog dismissal.
> Prevents common crashes where closing a dialog prematurely disposes state needed by the underlying screen.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 3.56 | 3.36 | 5.35 | 2.52 | 5.75 | 0.94 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 4.90 | 3.88 | 9.22 | 3.02 | 12.64 | 2.67 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

> Automates 50 route push and pop transitions to stress-test memory cleanup and controller lifecycle management.
> Asserts that route-scoped controllers are automatically disposed on pop with zero memory leaks or lingering event listeners.
> Eliminates memory leaks and dangling listeners in large navigation hierarchies without manual dispose calls.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.37 | 6.33 | 7.42 | 5.29 | 7.63 | 0.70 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

> Simulates 30 consecutive Flutter hot reload cycles calling reassemble().
> Measures state reconstruction speed, fast direct receiver re-indexing, and confirms zero double-build regressions.
> Guarantees a lightning-fast developer experience with instant hot reload feedback and zero state corruption during debugging.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 0.91 | 0.86 | 1.15 | 0.78 | 1.27 | 0.14 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.92 | 0.90 | 1.11 | 0.82 | 1.19 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E3_disposed_controller_access_safety

> Fires 1,000 updates to a previously disposed controller to test defensive error containment.
> Verifies that Graft safely handles stale references with zero unhandled exceptions, zero crashes, and zero memory leaks.
> Protects production apps from crashing when delayed async responses or animations complete after screen dismissal.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: F1_reactive_diamond_glitch_test

> Executes 5,000 rapid updates in a classic reactive diamond graph ($A \to B, C \to D$).
> Asserts that downstream consumer D evaluates exactly once per update with zero transient glitches or corrupt intermediate reads.
> Guarantees mathematical correctness and UI integrity in complex reactive dependency networks.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.07 | 0.06 | 0.11 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.09 | 0.03 | 0.16 | 0.03 | 0.19 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 3.76 | 3.76 | 3.91 | 3.62 | 3.99 | 0.12 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 11.04 | 11.01 | 11.21 | 10.87 | 11.27 | 0.12 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.40 | 0.39 | 0.44 | 0.38 | 0.46 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

> Tests multi-field transaction containment across 2,000 updates mutating 5 fields each (10,000 total mutations).
> Proves that notifications are 100% batched into exactly 1 notification per transaction with 0 wasted notifications.
> Prevents UI thrashing and redundant rebuild cascades during complex multi-property state transitions.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.31 | 0.28 | 0.42 | 0.12 | 0.88 | 0.18 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 0.34 | 0.32 | 0.41 | 0.30 | 0.65 | 0.09 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 1.77 | 1.76 | 1.94 | 1.65 | 2.02 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.16 | 0.15 | 0.17 | 0.15 | 0.17 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

