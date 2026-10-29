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

### 🔹 Scenario: A1_10k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.13 | 0.13 | 0.13 | 0.13 | 0.16 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.24 | 0.14 | 0.44 | 0.14 | 0.63 | 0.16 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 0.28 | 0.13 | 0.19 | 0.13 | 2.20 | 0.53 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.92 | 0.84 | 1.50 | 0.49 | 1.69 | 0.34 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.23 | 1.15 | 1.99 | 0.86 | 2.01 | 0.37 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 3.23 | 3.30 | 4.01 | 2.37 | 5.04 | 0.77 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.74 | 0.64 | 0.82 | 0.62 | 1.96 | 0.34 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 1.36 | 1.37 | 1.42 | 1.28 | 1.48 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 1.52 | 1.49 | 1.58 | 1.45 | 1.81 | 0.08 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 3.67 | 4.18 | 5.85 | 1.18 | 7.08 | 1.92 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 7.59 | 7.17 | 9.64 | 6.54 | 9.84 | 1.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 11.74 | 10.99 | 16.38 | 9.40 | 16.97 | 2.63 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 23.81 | 23.36 | 25.78 | 22.16 | 26.50 | 1.24 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.14 | 0.14 | 0.15 | 0.14 | 0.16 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 0.15 | 0.15 | 0.16 | 0.13 | 0.24 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 0.36 | 0.36 | 0.39 | 0.34 | 0.39 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 0.61 | 0.60 | 0.70 | 0.58 | 0.70 | 0.04 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 5 | **BLoC (Cubit)** | 0.73 | 0.20 | 2.97 | 0.20 | 5.27 | 1.44 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.99 | 0.97 | 1.06 | 0.94 | 1.07 | 0.04 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 8.43 | 8.39 | 8.62 | 8.19 | 8.64 | 0.15 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.02 | 0.01 | 0.03 | 0.01 | 0.05 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.03 | 0.01 | 0.09 | 0.01 | 0.11 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Graft** | 0.10 | 0.14 | 0.19 | 0.01 | 0.19 | 0.09 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 0.67 | 0.52 | 0.94 | 0.51 | 2.05 | 0.40 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **BLoC (Cubit)** | 0.74 | 0.43 | 1.50 | 0.42 | 3.97 | 0.94 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 1.04 | 0.79 | 0.95 | 0.71 | 4.25 | 0.89 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 7 | **Riverpod (Notifier)** | 1.65 | 1.27 | 3.20 | 0.63 | 3.35 | 0.91 | 0 | 0 | 100.0% | 8000 | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 12.06 | 12.03 | 12.50 | 11.62 | 12.69 | 0.35 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 13.13 | 12.98 | 13.93 | 12.05 | 15.59 | 0.89 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (StateNotifier)** | 13.84 | 13.33 | 14.17 | 12.80 | 19.32 | 1.58 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 13.86 | 13.79 | 14.65 | 12.84 | 15.71 | 0.79 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Provider** | 14.06 | 14.08 | 14.99 | 12.77 | 15.30 | 0.70 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Graft (leaf slot)** | 14.70 | 14.92 | 16.28 | 12.98 | 17.27 | 1.27 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (slots)** | 32.00 | 25.44 | 50.97 | 20.08 | 94.27 | 18.68 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Riverpod (Notifier)** | 35.13 | 15.25 | 53.20 | 13.03 | 237.15 | 56.99 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 21.33 | 20.64 | 21.89 | 20.49 | 27.38 | 1.74 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 21.45 | 21.32 | 22.08 | 20.71 | 22.27 | 0.53 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 22.20 | 22.04 | 22.89 | 21.63 | 23.11 | 0.46 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Graft (slots)** | 22.77 | 21.96 | 22.65 | 21.61 | 31.97 | 2.57 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **GetX** | 23.03 | 22.42 | 25.66 | 21.19 | 30.37 | 2.34 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 23.31 | 23.05 | 24.61 | 22.33 | 25.31 | 0.83 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **BLoC (Cubit)** | 28.55 | 28.28 | 31.45 | 24.31 | 35.19 | 2.87 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Riverpod (StateNotifier)** | 37.40 | 34.78 | 46.65 | 27.90 | 61.54 | 8.74 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 34.11 | 33.21 | 36.67 | 31.95 | 48.13 | 4.10 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 40.84 | 32.68 | 52.63 | 29.42 | 135.43 | 26.88 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 54.36 | 53.42 | 59.58 | 49.54 | 65.24 | 4.24 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **Provider** | 55.62 | 53.94 | 59.40 | 52.30 | 69.58 | 4.45 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 59.82 | 58.77 | 61.18 | 57.45 | 72.95 | 3.78 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Graft** | 61.74 | 49.31 | 106.25 | 41.87 | 124.69 | 25.87 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.42 | 27.64 | 29.29 | 27.16 | 38.84 | 2.92 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 36.36 | 33.60 | 53.85 | 30.40 | 54.15 | 8.66 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 39.33 | 38.92 | 40.46 | 37.94 | 43.31 | 1.31 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 55.41 | 54.10 | 54.96 | 53.59 | 73.29 | 4.96 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 63.90 | 63.94 | 64.84 | 61.83 | 66.03 | 1.03 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 90.39 | 83.05 | 110.78 | 66.71 | 126.58 | 17.60 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.33 | 0.34 | 0.32 | 0.35 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 0.91 | 0.52 | 3.03 | 0.50 | 3.79 | 1.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.92 | 0.55 | 3.06 | 0.50 | 3.55 | 0.98 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Provider** | 1.20 | 0.51 | 5.47 | 0.47 | 5.87 | 1.82 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **GetX (RxList)** | 5.85 | 5.84 | 5.92 | 5.76 | 5.97 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.01 | 0.01 | 0.02 | 0.01 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.02 | 0.06 | 0.01 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.05 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.05 | 0.11 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Graft** | 0.07 | 0.07 | 0.07 | 0.06 | 0.10 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 3.87 | 3.55 | 4.95 | 3.33 | 5.99 | 0.72 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 7.84 | 4.15 | 17.89 | 3.99 | 36.20 | 8.82 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 10.69 | 8.09 | 16.02 | 7.64 | 18.48 | 4.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 3.14 | 1.72 | 11.60 | 1.66 | 12.26 | 3.58 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 3.16 | 1.79 | 10.53 | 1.70 | 13.24 | 3.58 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.01 | 0.00 | 0.02 | 0.00 | 0.02 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: F1_reactive_diamond_glitch_test

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 1.17 | 1.16 | 1.18 | 1.14 | 1.18 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 11.37 | 11.36 | 12.12 | 10.75 | 12.30 | 0.45 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 24.28 | 20.57 | 32.84 | 13.99 | 85.56 | 17.79 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.44 | 0.44 | 0.47 | 0.41 | 0.48 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.17 | 0.17 | 0.17 | 0.16 | 0.18 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.47 | 0.45 | 0.52 | 0.42 | 0.69 | 0.07 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 1.37 | 1.04 | 2.23 | 0.89 | 4.91 | 1.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 3.24 | 2.07 | 6.53 | 2.03 | 6.63 | 1.98 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.31 | 0.29 | 0.35 | 0.28 | 0.36 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

