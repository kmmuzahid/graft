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

> Measures pure in-place state mutation throughput across 10,000 synchronous scalar increments without UI listeners, verifying zero-allocation GC footprint and bitmask diff speed.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.16 | 0.14 | 0.18 | 0.14 | 0.34 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.17 | 0.13 | 0.32 | 0.13 | 0.42 | 0.09 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.35 | 0.13 | 0.17 | 0.13 | 3.23 | 0.80 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.72 | 0.66 | 0.98 | 0.52 | 1.41 | 0.23 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.13 | 1.15 | 1.42 | 0.88 | 1.43 | 0.18 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 2.94 | 2.82 | 3.48 | 2.44 | 3.72 | 0.40 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

> Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments, verifying JIT optimization stability and zero memory bloat under continuous CPU load.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.72 | 0.52 | 1.49 | 0.51 | 1.71 | 0.40 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 1.53 | 1.50 | 1.66 | 1.48 | 1.70 | 0.07 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 1.68 | 1.61 | 2.00 | 1.43 | 2.06 | 0.21 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 4.73 | 4.82 | 7.36 | 1.66 | 9.28 | 2.39 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 7.50 | 7.30 | 8.31 | 6.79 | 9.21 | 0.67 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 10.33 | 10.38 | 11.16 | 8.96 | 11.21 | 0.64 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 27.12 | 25.31 | 34.74 | 24.03 | 38.00 | 4.22 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

> Executes 2,000 multi-property transactions modifying 5 distinct fields simultaneously (10,000 total mutations), measuring SIMD register diffing and single-notification batching efficiency.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.15 | 0.14 | 0.16 | 0.14 | 0.27 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.17 | 0.15 | 0.18 | 0.15 | 0.26 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.46 | 0.39 | 0.69 | 0.38 | 1.19 | 0.22 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.59 | 0.24 | 0.64 | 0.20 | 4.77 | 1.16 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.69 | 0.65 | 0.88 | 0.58 | 0.88 | 0.10 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.06 | 1.03 | 1.20 | 0.93 | 1.55 | 0.15 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 10.31 | 10.16 | 11.03 | 9.01 | 12.25 | 0.81 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

> Mutates a leaf node nested 8 levels deep in an object hierarchy, measuring ancestor dirty-flag propagation latency and evaluating direct root-pointer notification dispatch.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.01 | 0.01 | 0.01 | 0.16 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.04 | 0.03 | 0.04 | 0.00 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 🥉 | **GetX** | 0.04 | 0.04 | 0.06 | 0.01 | 0.07 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Provider** | 0.08 | 0.01 | 0.21 | 0.01 | 0.59 | 0.15 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 0.30 | 0.26 | 0.39 | 0.23 | 0.57 | 0.09 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Riverpod (Notifier)** | 0.83 | 0.71 | 1.33 | 0.54 | 1.41 | 0.32 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 7 | **Signals** | 1.60 | 1.42 | 2.78 | 0.52 | 3.38 | 0.81 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

> Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0, measuring frame rendering latency and asserting zero rebuilds across all 9 static siblings.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 12.32 | 12.19 | 12.82 | 11.81 | 13.03 | 0.37 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 13.92 | 14.01 | 14.89 | 13.08 | 15.06 | 0.71 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Graft (slots)** | 15.68 | 13.49 | 20.19 | 12.36 | 22.80 | 3.47 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **GetX** | 19.45 | 17.27 | 27.31 | 14.72 | 42.33 | 7.14 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 20.82 | 20.68 | 26.18 | 15.43 | 33.18 | 4.38 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **BLoC (Cubit)** | 20.85 | 18.27 | 29.22 | 15.72 | 30.12 | 4.91 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Riverpod (Notifier)** | 21.12 | 19.31 | 25.33 | 14.06 | 47.44 | 8.04 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Signals** | 21.41 | 20.59 | 25.54 | 15.90 | 28.53 | 3.38 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

> Evaluates high-density rebuild isolation across 120 animation frames in a 50-slot Column, verifying that dirty-mask dispatch scales smoothly without leaking rebuilds to 49 static slots.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 22.69 | 22.36 | 23.72 | 22.04 | 23.78 | 0.64 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft (slots)** | 24.57 | 24.28 | 25.39 | 23.86 | 25.66 | 0.62 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 24.85 | 24.52 | 26.04 | 24.21 | 26.21 | 0.75 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **GetX** | 25.33 | 24.92 | 26.62 | 24.59 | 26.92 | 0.85 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 25.59 | 25.07 | 28.65 | 23.95 | 29.73 | 1.67 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Signals** | 26.37 | 26.17 | 28.71 | 24.27 | 31.03 | 1.89 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Riverpod (Notifier)** | 27.65 | 25.77 | 32.12 | 23.39 | 45.85 | 5.62 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Provider** | 27.74 | 27.08 | 30.65 | 25.92 | 31.34 | 1.83 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

> Performs 300 rapid updates to an item in a virtualized 5,000-item ListView, measuring localized slot rebuild latency and proving zero static rebuilds on the 4,999 unaffected items.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 27.13 | 27.11 | 27.65 | 26.49 | 27.81 | 0.35 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 30.70 | 30.68 | 31.42 | 30.12 | 31.66 | 0.45 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 🥉 | **Signals** | 32.13 | 30.69 | 32.49 | 29.82 | 47.71 | 4.41 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 47.03 | 45.26 | 50.57 | 44.17 | 63.60 | 4.96 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **Provider** | 56.96 | 57.27 | 58.59 | 55.06 | 59.30 | 1.44 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 6 | **GetX** | 64.29 | 64.38 | 66.09 | 61.92 | 66.71 | 1.30 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

> Tests ultra-scale list virtualization by firing 300 updates into a 20,000-item ListView, verifying that receiver indexing maintains O(1) dispatch time regardless of list size.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.20 | 30.41 | 37.42 | 30.07 | 49.02 | 5.03 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 40.65 | 38.36 | 62.69 | 34.23 | 67.83 | 10.26 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 49.05 | 47.17 | 50.35 | 45.95 | 71.19 | 6.26 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 66.47 | 64.43 | 65.68 | 64.00 | 94.42 | 7.74 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 73.70 | 74.10 | 74.53 | 70.48 | 74.73 | 1.20 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 77.20 | 77.71 | 80.02 | 72.84 | 81.53 | 2.44 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

> Executes 100 random insert and remove operations across an indexed collection of 1,000 items, measuring array splice performance, structural diffing, and collection notification overhead.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.28 | 0.27 | 0.30 | 0.26 | 0.31 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX (RxList)** | 0.86 | 0.87 | 0.90 | 0.80 | 0.93 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.97 | 0.47 | 4.14 | 0.45 | 4.29 | 1.32 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 1.64 | 0.82 | 6.30 | 0.52 | 8.59 | 2.42 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **BLoC (Cubit)** | 2.00 | 0.51 | 5.75 | 0.47 | 14.58 | 3.74 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

> Simulates a multi-controller e-commerce workflow with 200 catalog items and reactive cart totals, measuring cross-controller synchronization speed and zero-GC state sharing.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

> Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation recalculations, measuring branchless register diffing and atomic dirty-mask resolution.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.05 | 0.05 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.08 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.06 | 0.06 | 0.07 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

> Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by an underlying page, measuring transient controller borrowing and lifecycle safety.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 3.28 | 3.13 | 4.36 | 2.65 | 4.45 | 0.61 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 3.62 | 2.82 | 5.88 | 2.74 | 8.75 | 1.69 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

> Automates 50 route transitions to stress-test memory cleanup, asserting that route-scoped controllers are automatically disposed without leaks or lingering event listeners.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.02 | 4.91 | 5.59 | 4.69 | 5.67 | 0.32 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

> Simulates 30 consecutive Flutter hot reload cycles calling reassemble(), measuring state reconstruction speed, observer re-registration, and zero state corruption.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 0.85 | 0.84 | 0.94 | 0.78 | 0.95 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.92 | 0.88 | 1.02 | 0.79 | 1.47 | 0.17 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E3_disposed_controller_access_safety

> Fires 1,000 updates to a previously disposed controller, verifying that Graft safely handles stale references with zero exceptions, zero crashes, and zero memory leaks.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: F1_reactive_diamond_glitch_test

> Executes 5,000 rapid updates in a reactive diamond graph ($A \to B, C \to D$), asserting that downstream consumer $D$ evaluates exactly once per update with zero transient glitches.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.07 | 0.06 | 0.08 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.15 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 4.69 | 4.63 | 5.15 | 4.00 | 6.34 | 0.59 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 15.44 | 15.40 | 17.51 | 13.07 | 19.52 | 1.61 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.50 | 0.44 | 0.73 | 0.43 | 1.00 | 0.16 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

> Tests multi-field transaction containment across 2,000 updates mutating 5 fields each, proving that exactly one notification fires per transaction with zero wasted notifications.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.05 | 0.04 | 0.10 | 0.03 | 0.11 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.32 | 0.30 | 0.35 | 0.29 | 0.46 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 0.47 | 0.37 | 0.61 | 0.34 | 0.97 | 0.17 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 2.16 | 2.10 | 2.46 | 1.82 | 2.52 | 0.23 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.27 | 0.26 | 0.38 | 0.18 | 0.48 | 0.08 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

