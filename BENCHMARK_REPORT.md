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
| 🥇 | **Graft** | 0.07 | 0.06 | 0.07 | 0.06 | 0.08 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.19 | 0.14 | 0.36 | 0.13 | 0.45 | 0.10 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.21 | 0.15 | 0.42 | 0.14 | 0.42 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.43 | 0.17 | 1.79 | 0.13 | 2.36 | 0.68 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.93 | 0.76 | 1.51 | 0.51 | 1.76 | 0.39 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.54 | 1.33 | 2.63 | 0.85 | 3.08 | 0.67 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 3.22 | 3.12 | 4.19 | 2.54 | 4.82 | 0.57 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

> Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments, verifying JIT optimization stability and zero memory bloat under continuous CPU load.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.94 | 0.85 | 1.22 | 0.66 | 1.87 | 0.33 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 1.59 | 1.53 | 1.89 | 1.31 | 2.57 | 0.32 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 1.86 | 1.60 | 2.66 | 1.42 | 2.84 | 0.50 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 5.58 | 5.95 | 8.04 | 1.27 | 14.11 | 3.47 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 7.73 | 7.70 | 8.71 | 6.95 | 9.23 | 0.60 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 10.52 | 10.51 | 11.52 | 8.89 | 12.55 | 1.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 25.82 | 25.90 | 27.88 | 23.17 | 28.27 | 1.40 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

> Executes 2,000 multi-property transactions modifying 5 distinct fields simultaneously (10,000 total mutations), measuring SIMD register diffing and single-notification batching efficiency.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.16 | 0.15 | 0.16 | 0.14 | 0.24 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.19 | 0.17 | 0.28 | 0.15 | 0.30 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.43 | 0.42 | 0.48 | 0.39 | 0.49 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 0.61 | 0.60 | 0.69 | 0.55 | 0.76 | 0.05 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 5 | **BLoC (Cubit)** | 0.79 | 0.22 | 3.44 | 0.20 | 5.10 | 1.45 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.30 | 1.27 | 1.65 | 0.97 | 1.97 | 0.26 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 10.51 | 10.35 | 11.59 | 9.33 | 12.67 | 0.90 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

> Mutates a leaf node nested 8 levels deep in an object hierarchy, measuring ancestor dirty-flag propagation latency and evaluating direct root-pointer notification dispatch.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.02 | 0.01 | 0.03 | 0.01 | 0.07 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.03 | 0.01 | 0.08 | 0.01 | 0.13 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Graft** | 0.04 | 0.04 | 0.06 | 0.01 | 0.07 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.08 | 0.05 | 0.16 | 0.03 | 0.30 | 0.07 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 0.29 | 0.26 | 0.58 | 0.10 | 0.74 | 0.19 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Signals** | 0.65 | 0.54 | 0.56 | 0.51 | 2.31 | 0.46 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Riverpod (Notifier)** | 0.90 | 0.85 | 1.45 | 0.26 | 1.51 | 0.36 | 0 | 0 | 100.0% | 8000 | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

> Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0, measuring frame rendering latency and asserting zero rebuilds across all 9 static siblings.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 15.84 | 15.37 | 19.28 | 14.09 | 19.90 | 1.78 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 17.56 | 15.16 | 22.25 | 13.58 | 29.28 | 4.38 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 18.74 | 16.34 | 23.56 | 14.37 | 38.13 | 6.10 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Provider** | 19.21 | 18.57 | 23.70 | 15.53 | 24.50 | 2.75 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 19.67 | 16.56 | 23.85 | 14.21 | 46.83 | 8.19 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (Notifier)** | 24.91 | 22.47 | 34.25 | 18.92 | 46.51 | 7.37 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (leaf slot)** | 25.12 | 25.20 | 29.60 | 18.99 | 32.24 | 3.41 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Graft (slots)** | 27.15 | 26.24 | 33.79 | 21.12 | 36.49 | 5.02 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

> Evaluates high-density rebuild isolation across 120 animation frames in a 50-slot Column, verifying that dirty-mask dispatch scales smoothly without leaking rebuilds to 49 static slots.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 24.34 | 24.47 | 25.10 | 23.38 | 25.27 | 0.64 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 24.98 | 23.64 | 27.31 | 22.63 | 38.70 | 4.05 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 25.10 | 24.38 | 27.96 | 22.93 | 33.82 | 2.73 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 35.12 | 34.56 | 41.44 | 30.20 | 45.94 | 4.74 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Graft (leaf slot)** | 38.75 | 36.74 | 48.34 | 29.39 | 52.57 | 6.22 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (Notifier)** | 39.17 | 40.94 | 50.08 | 29.26 | 50.48 | 6.83 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (slots)** | 40.30 | 37.02 | 52.13 | 29.34 | 65.71 | 10.31 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Riverpod (StateNotifier)** | 41.40 | 40.74 | 46.74 | 35.06 | 51.49 | 4.69 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

> Performs 300 rapid updates to an item in a virtualized 5,000-item ListView, measuring localized slot rebuild latency and proving zero static rebuilds on the 4,999 unaffected items.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 32.08 | 29.87 | 44.47 | 29.47 | 45.41 | 5.27 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 33.34 | 31.55 | 42.90 | 28.44 | 45.64 | 5.24 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 35.16 | 35.11 | 38.91 | 31.55 | 39.80 | 2.78 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 46.34 | 45.24 | 47.78 | 44.66 | 58.69 | 3.51 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **Provider** | 55.73 | 56.01 | 56.94 | 54.24 | 57.59 | 1.02 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 6 | **GetX** | 65.58 | 62.99 | 73.72 | 61.46 | 78.47 | 4.96 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

> Tests ultra-scale list virtualization by firing 300 updates into a 20,000-item ListView, verifying that receiver indexing maintains O(1) dispatch time regardless of list size.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 31.08 | 29.76 | 37.12 | 28.62 | 37.52 | 2.88 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 39.74 | 35.18 | 55.40 | 31.95 | 62.01 | 9.79 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 41.73 | 41.45 | 43.56 | 40.70 | 43.59 | 0.82 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 62.78 | 61.08 | 68.61 | 57.32 | 79.85 | 6.03 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 70.92 | 69.70 | 75.96 | 65.92 | 79.17 | 3.75 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 72.95 | 71.02 | 79.92 | 69.57 | 83.25 | 4.14 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

> Executes 100 random insert and remove operations across an indexed collection of 1,000 items, measuring array splice performance, structural diffing, and collection notification overhead.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.32 | 0.32 | 0.36 | 0.28 | 0.38 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.76 | 0.47 | 2.63 | 0.43 | 2.75 | 0.78 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX (RxList)** | 0.85 | 0.85 | 0.87 | 0.83 | 0.87 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.88 | 0.51 | 3.26 | 0.48 | 3.38 | 0.99 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.92 | 0.52 | 2.92 | 0.48 | 3.11 | 0.88 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

> Simulates a multi-controller e-commerce workflow with 200 catalog items and reactive cart totals, measuring cross-controller synchronization speed and zero-GC state sharing.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.01 | 0.02 | 0.01 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 0.02 | 0.01 | 0.02 | 0.01 | 0.04 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

> Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation recalculations, measuring branchless register diffing and atomic dirty-mask resolution.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.03 | 0.04 | 0.04 | 0.03 | 0.04 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.05 | 0.05 | 0.05 | 0.04 | 0.05 | 0.00 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.07 | 0.05 | 0.08 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

> Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by an underlying page, measuring transient controller borrowing and lifecycle safety.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.60 | 2.55 | 2.78 | 2.38 | 2.97 | 0.16 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 4.39 | 3.30 | 6.77 | 2.99 | 11.00 | 2.17 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

> Automates 50 route transitions to stress-test memory cleanup, asserting that route-scoped controllers are automatically disposed without leaks or lingering event listeners.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.34 | 5.27 | 5.91 | 4.77 | 6.90 | 0.54 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

> Simulates 30 consecutive Flutter hot reload cycles calling reassemble(), measuring state reconstruction speed, observer re-registration, and zero state corruption.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.93 | 0.90 | 1.02 | 0.82 | 1.31 | 0.12 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.96 | 0.92 | 1.08 | 0.83 | 1.40 | 0.14 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

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
| 🥇 | **BLoC (Cubit)** | 0.07 | 0.07 | 0.08 | 0.06 | 0.08 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.46 | 0.32 | 0.55 | 0.29 | 1.60 | 0.33 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 4.82 | 4.32 | 6.35 | 3.94 | 7.18 | 1.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 15.32 | 15.13 | 18.90 | 11.38 | 19.28 | 2.77 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.50 | 0.48 | 0.60 | 0.42 | 0.68 | 0.07 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

> Tests multi-field transaction containment across 2,000 updates mutating 5 fields each, proving that exactly one notification fires per transaction with zero wasted notifications.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.04 | 0.03 | 0.05 | 0.03 | 0.05 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.50 | 0.45 | 0.96 | 0.13 | 1.66 | 0.39 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 0.51 | 0.43 | 0.72 | 0.32 | 1.08 | 0.21 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 2.72 | 2.69 | 3.40 | 2.00 | 3.63 | 0.46 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.27 | 0.24 | 0.46 | 0.17 | 0.49 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

