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
| 🥇 | **Graft** | 0.06 | 0.06 | 0.07 | 0.06 | 0.07 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.14 | 0.14 | 0.14 | 0.14 | 0.15 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.15 | 0.14 | 0.15 | 0.14 | 0.26 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.26 | 0.14 | 0.17 | 0.12 | 1.95 | 0.47 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.58 | 0.58 | 0.62 | 0.54 | 0.62 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.88 | 0.86 | 1.04 | 0.82 | 1.09 | 0.08 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 2.44 | 2.42 | 2.50 | 2.35 | 2.59 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

> Stresses engine register fast-paths under a sustained burst of 100,000 synchronous increments, verifying JIT optimization stability and zero memory bloat under continuous CPU load.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.66 | 0.66 | 0.68 | 0.65 | 0.70 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 1.30 | 1.28 | 1.35 | 1.25 | 1.48 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 1.42 | 1.43 | 1.48 | 1.37 | 1.48 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 3.02 | 3.23 | 4.79 | 1.14 | 6.34 | 1.57 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 6.18 | 6.21 | 6.29 | 5.96 | 6.29 | 0.10 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 7.98 | 7.97 | 8.20 | 7.79 | 8.22 | 0.13 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 22.62 | 22.59 | 23.12 | 22.33 | 23.15 | 0.25 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

> Executes 2,000 multi-property transactions modifying 5 distinct fields simultaneously (10,000 total mutations), measuring SIMD register diffing and single-notification batching efficiency.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.14 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.14 | 0.14 | 0.16 | 0.13 | 0.22 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.41 | 0.40 | 0.45 | 0.38 | 0.45 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 0.58 | 0.57 | 0.70 | 0.54 | 0.71 | 0.05 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 5 | **BLoC (Cubit)** | 0.75 | 0.34 | 2.15 | 0.18 | 3.15 | 0.85 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.93 | 0.94 | 0.97 | 0.88 | 0.99 | 0.04 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 8.68 | 8.64 | 8.99 | 8.44 | 9.00 | 0.19 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

> Mutates a leaf node nested 8 levels deep in an object hierarchy, measuring ancestor dirty-flag propagation latency and evaluating direct root-pointer notification dispatch.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.02 | 0.01 | 0.02 | 0.01 | 0.06 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.02 | 0.01 | 0.05 | 0.01 | 0.06 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.04 | 0.03 | 0.04 | 0.03 | 0.09 | 0.01 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 5 | **Riverpod (StateNotifier)** | 0.26 | 0.24 | 0.31 | 0.14 | 0.60 | 0.11 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Riverpod (Notifier)** | 0.54 | 0.53 | 0.57 | 0.49 | 0.64 | 0.03 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 7 | **Signals** | 0.63 | 0.49 | 0.54 | 0.47 | 2.49 | 0.51 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

> Pumps 120 simulated animation frames into a 10-slot Column layout while mutating slot 0, measuring frame rendering latency and asserting zero rebuilds across all 9 static siblings.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 12.88 | 12.88 | 13.43 | 12.23 | 13.68 | 0.43 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (StateNotifier)** | 13.56 | 13.39 | 13.85 | 12.87 | 16.41 | 0.84 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 14.58 | 14.59 | 15.82 | 13.34 | 15.85 | 0.79 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 14.66 | 14.42 | 15.52 | 13.56 | 16.31 | 0.72 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 14.71 | 14.79 | 15.53 | 13.45 | 15.79 | 0.69 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 15.28 | 15.40 | 16.56 | 13.80 | 17.07 | 1.01 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (slots)** | 15.88 | 15.78 | 17.41 | 14.17 | 17.72 | 1.02 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Graft (leaf slot)** | 16.43 | 16.27 | 18.12 | 14.38 | 18.41 | 1.09 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

> Evaluates high-density rebuild isolation across 120 animation frames in a 50-slot Column, verifying that dirty-mask dispatch scales smoothly without leaking rebuilds to 49 static slots.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 23.17 | 23.07 | 23.87 | 22.33 | 24.03 | 0.52 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft (leaf slot)** | 23.41 | 22.77 | 24.85 | 21.83 | 28.60 | 1.67 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 23.43 | 23.51 | 24.02 | 22.73 | 24.28 | 0.49 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 23.77 | 23.44 | 25.17 | 22.72 | 25.61 | 0.87 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 23.93 | 24.11 | 24.73 | 22.27 | 26.95 | 1.18 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **GetX** | 25.29 | 24.80 | 26.75 | 24.18 | 27.00 | 0.98 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (slots)** | 25.90 | 25.08 | 27.54 | 23.74 | 35.43 | 2.90 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Provider** | 27.07 | 27.05 | 28.12 | 25.74 | 29.02 | 1.00 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

> Performs 300 rapid updates to an item in a virtualized 5,000-item ListView, measuring localized slot rebuild latency and proving zero static rebuilds on the 4,999 unaffected items.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.30 | 29.58 | 31.65 | 28.39 | 39.66 | 2.78 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 32.35 | 32.15 | 33.83 | 30.82 | 35.79 | 1.22 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 🥉 | **Signals** | 33.59 | 32.87 | 35.27 | 31.30 | 42.85 | 2.84 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 46.76 | 45.66 | 47.74 | 44.66 | 59.26 | 3.55 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **Provider** | 57.96 | 58.46 | 58.92 | 56.32 | 59.57 | 1.15 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 6 | **GetX** | 68.46 | 66.77 | 72.01 | 63.63 | 83.24 | 4.96 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

> Tests ultra-scale list virtualization by firing 300 updates into a 20,000-item ListView, verifying that receiver indexing maintains O(1) dispatch time regardless of list size.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 33.30 | 31.78 | 34.55 | 31.04 | 49.83 | 4.69 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 42.74 | 37.95 | 64.16 | 34.26 | 65.30 | 11.59 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 48.92 | 46.09 | 52.36 | 44.37 | 76.11 | 7.85 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 65.72 | 63.84 | 68.77 | 62.24 | 85.00 | 5.63 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 74.67 | 74.33 | 79.72 | 71.00 | 82.82 | 3.16 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 76.13 | 76.31 | 78.49 | 73.48 | 78.88 | 1.74 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

> Executes 100 random insert and remove operations across an indexed collection of 1,000 items, measuring array splice performance, structural diffing, and collection notification overhead.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.60 | 0.31 | 0.79 | 0.26 | 4.16 | 0.99 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX (RxList)** | 0.92 | 0.91 | 0.94 | 0.88 | 0.95 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 1.05 | 0.51 | 4.57 | 0.47 | 4.66 | 1.45 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 1.09 | 0.51 | 4.52 | 0.47 | 5.17 | 1.53 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Provider** | 1.18 | 0.52 | 5.51 | 0.45 | 5.58 | 1.77 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

> Simulates a multi-controller e-commerce workflow with 200 catalog items and reactive cart totals, measuring cross-controller synchronization speed and zero-GC state sharing.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

> Evaluates an interactive 12-field checkout form with interdependent discount, tax, and validation recalculations, measuring branchless register diffing and atomic dirty-mask resolution.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.04 | 0.09 | 0.04 | 0.19 | 0.04 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥈 | **Graft** | 0.06 | 0.03 | 0.07 | 0.02 | 0.41 | 0.10 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.12 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

> Pushes and pops 10 consecutive modal dialogs that borrow and mutate an ambient controller owned by an underlying page, measuring transient controller borrowing and lifecycle safety.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.69 | 2.67 | 2.91 | 2.44 | 2.98 | 0.16 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 3.75 | 3.13 | 5.43 | 2.84 | 8.68 | 1.56 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

> Automates 50 route transitions to stress-test memory cleanup, asserting that route-scoped controllers are automatically disposed without leaks or lingering event listeners.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.38 | 5.32 | 6.03 | 4.80 | 6.12 | 0.35 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

> Simulates 30 consecutive Flutter hot reload cycles calling reassemble(), measuring state reconstruction speed, observer re-registration, and zero state corruption.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 0.93 | 0.91 | 0.96 | 0.86 | 1.19 | 0.08 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.96 | 0.95 | 1.16 | 0.84 | 1.16 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E3_disposed_controller_access_safety

> Fires 1,000 updates to a previously disposed controller, verifying that Graft safely handles stale references with zero exceptions, zero crashes, and zero memory leaks.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: F1_reactive_diamond_glitch_test

> Executes 5,000 rapid updates in a reactive diamond graph ($A \to B, C \to D$), asserting that downstream consumer $D$ evaluates exactly once per update with zero transient glitches.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.04 | 0.04 | 0.04 | 0.04 | 0.04 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.07 | 0.06 | 0.08 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 3.83 | 3.80 | 3.90 | 3.73 | 4.27 | 0.13 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 11.02 | 10.98 | 11.26 | 10.77 | 11.58 | 0.21 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.42 | 0.42 | 0.44 | 0.40 | 0.47 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

> Tests multi-field transaction containment across 2,000 updates mutating 5 fields each, proving that exactly one notification fires per transaction with zero wasted notifications.

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.03 | 0.03 | 0.03 | 0.03 | 0.04 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.35 | 0.33 | 0.41 | 0.10 | 1.06 | 0.21 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 0.38 | 0.34 | 0.44 | 0.33 | 0.75 | 0.11 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 1.79 | 1.79 | 1.87 | 1.71 | 1.88 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.19 | 0.19 | 0.21 | 0.17 | 0.21 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

