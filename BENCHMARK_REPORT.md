# 🚀 Late 2026 Flutter State Management Benchmark Report

**A Comprehensive, Empirical Comparison of Graft vs. Leading State Management Solutions**

---

## 📋 Executive Summary

This benchmark suite evaluates **Graft** against the primary Flutter state management paradigms:
1. **Graft** (`1.0.0-alpha.6`) — Self-optimizing bitmask diff engine with zero-wrapper ambient lifecycle
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
| 🥇 | **Graft** | 0.07 | 0.07 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.13 | 0.14 | 0.15 | 0.12 | 0.15 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.14 | 0.13 | 0.15 | 0.13 | 0.18 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **GetX** | 0.16 | 0.16 | 0.18 | 0.15 | 0.18 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.54 | 0.53 | 0.57 | 0.50 | 0.62 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.78 | 0.78 | 0.84 | 0.73 | 0.85 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 2.41 | 2.40 | 2.49 | 2.29 | 2.55 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.80 | 0.80 | 0.83 | 0.75 | 0.83 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Provider** | 1.29 | 1.29 | 1.34 | 1.21 | 1.36 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **GetX** | 1.47 | 1.46 | 1.49 | 1.44 | 1.51 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 4.05 | 3.73 | 7.53 | 1.23 | 7.84 | 2.42 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 4.88 | 4.88 | 4.94 | 4.80 | 4.95 | 0.05 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 7.60 | 7.57 | 7.79 | 7.46 | 7.92 | 0.12 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Signals** | 22.89 | 22.87 | 23.15 | 22.76 | 23.18 | 0.13 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.16 | 0.14 | 0.17 | 0.14 | 0.28 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.38 | 0.22 | 0.25 | 0.21 | 2.65 | 0.63 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 🥉 | **GetX** | 0.41 | 0.41 | 0.43 | 0.39 | 0.43 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Graft** | 0.55 | 0.49 | 0.51 | 0.30 | 1.74 | 0.34 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.59 | 0.58 | 0.63 | 0.54 | 0.74 | 0.05 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.90 | 0.90 | 0.96 | 0.85 | 0.97 | 0.03 | 0 | 0 | 100.0% | 10000 | ✅ Pass |
| 7 | **Signals** | 8.84 | 8.84 | 8.99 | 8.68 | 9.21 | 0.14 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX** | 0.09 | 0.09 | 0.09 | 0.08 | 0.11 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.41 | 0.41 | 0.43 | 0.38 | 0.44 | 0.02 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 4 | **Provider** | 0.42 | 0.16 | 1.18 | 0.14 | 3.08 | 0.78 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 0.54 | 0.54 | 0.59 | 0.50 | 0.60 | 0.03 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 6 | **Riverpod (StateNotifier)** | 0.72 | 0.66 | 0.75 | 0.63 | 1.42 | 0.19 | 0 | 0 | 100.0% | 8000 | ✅ Pass |
| 7 | **Signals** | 0.82 | 0.67 | 1.35 | 0.65 | 1.59 | 0.31 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 13.36 | 13.34 | 14.03 | 12.27 | 14.08 | 0.50 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft (leaf slot)** | 13.59 | 13.20 | 14.10 | 12.41 | 18.78 | 1.50 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Graft (slots)** | 13.60 | 13.39 | 14.39 | 12.93 | 14.70 | 0.59 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 14.32 | 13.67 | 14.05 | 13.10 | 23.79 | 2.63 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **BLoC (Cubit)** | 14.34 | 14.05 | 15.72 | 13.31 | 17.47 | 1.05 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Signals** | 14.57 | 13.91 | 14.76 | 12.98 | 23.72 | 2.57 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Riverpod (StateNotifier)** | 14.57 | 12.80 | 21.87 | 12.47 | 28.38 | 4.48 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Provider** | 14.75 | 14.68 | 15.22 | 14.37 | 15.94 | 0.39 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 23.18 | 22.93 | 25.37 | 21.87 | 25.42 | 1.26 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 23.70 | 23.27 | 24.72 | 22.80 | 25.47 | 0.80 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (StateNotifier)** | 24.20 | 24.00 | 25.95 | 23.10 | 26.14 | 1.01 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **GetX** | 24.87 | 24.18 | 26.14 | 23.90 | 26.14 | 0.95 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Signals** | 25.53 | 25.31 | 26.72 | 24.12 | 26.87 | 1.04 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **BLoC (Cubit)** | 25.86 | 24.16 | 26.19 | 23.71 | 43.83 | 5.05 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 7 | **Graft (slots)** | 26.04 | 24.87 | 27.76 | 23.63 | 41.36 | 4.41 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 8 | **Provider** | 27.14 | 26.73 | 31.31 | 24.68 | 32.46 | 2.46 | 120 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.14 | 28.20 | 29.40 | 27.52 | 42.65 | 3.77 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Riverpod (Notifier)** | 31.15 | 29.60 | 33.46 | 28.92 | 43.69 | 3.81 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 🥉 | **Signals** | 36.38 | 33.38 | 47.48 | 31.81 | 61.16 | 7.93 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **BLoC (Cubit)** | 48.98 | 47.92 | 49.61 | 46.71 | 62.09 | 3.73 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **Provider** | 55.09 | 55.39 | 57.04 | 53.38 | 57.27 | 1.29 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 6 | **GetX** | 62.07 | 62.08 | 63.54 | 59.98 | 65.47 | 1.40 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.78 | 29.28 | 31.63 | 28.85 | 32.16 | 1.07 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 39.50 | 36.54 | 59.73 | 32.91 | 61.51 | 9.59 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 45.46 | 44.34 | 46.10 | 41.99 | 65.83 | 5.79 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 4 | **BLoC (Cubit)** | 60.09 | 59.94 | 60.90 | 58.79 | 63.12 | 1.05 | 300 | 0 | 100.0% | 300 | ✅ Pass |
| 5 | **GetX** | 71.44 | 69.82 | 71.19 | 66.63 | 97.35 | 7.29 | 300 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 6 | **Provider** | 74.28 | 72.07 | 77.57 | 68.26 | 101.39 | 7.90 | 300 | 0 | 100.0% | 300 | ✅ Pass |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.33 | 0.34 | 0.31 | 0.35 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **GetX (RxList)** | 0.83 | 0.83 | 0.86 | 0.79 | 0.87 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.97 | 0.49 | 3.89 | 0.43 | 3.89 | 1.19 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Provider** | 0.99 | 0.43 | 3.24 | 0.40 | 3.38 | 1.18 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 5 | **Riverpod (Notifier)** | 1.01 | 0.43 | 3.35 | 0.40 | 3.46 | 1.20 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **BLoC (Cubit)** | 0.04 | 0.03 | 0.07 | 0.03 | 0.09 | 0.02 | 0 | 0 | 100.0% | 40 | ✅ Pass |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.08 | 0.01 | 0 | 0 | 100.0% | 100 | ✅ Pass |
| 🥈 | **Graft** | 0.07 | 0.07 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 0.07 | 0.06 | 0.12 | 0.06 | 0.15 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.64 | 2.45 | 3.36 | 2.17 | 4.13 | 0.51 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 3.70 | 3.08 | 6.55 | 2.70 | 7.34 | 1.43 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.02 | 4.89 | 5.69 | 4.53 | 5.90 | 0.41 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.81 | 0.81 | 0.85 | 0.77 | 0.86 | 0.03 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.89 | 0.85 | 0.97 | 0.77 | 1.37 | 0.14 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.02 | 0.01 | 0.03 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |

### 🔹 Scenario: F1_reactive_diamond_glitch_test

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.04 | 0.04 | 0.04 | 0.04 | 0.07 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **BLoC (Cubit)** | 0.09 | 0.09 | 0.10 | 0.09 | 0.12 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Signals** | 3.74 | 3.74 | 3.82 | 3.66 | 3.89 | 0.06 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Riverpod (Notifier)** | 12.01 | 11.92 | 12.48 | 11.73 | 12.75 | 0.28 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.43 | 0.43 | 0.45 | 0.40 | 0.45 | 0.02 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

### 🔹 Scenario: G1_transactional_multi_field_batching

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | Rebuild Eff. | State Churn | Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.04 | 0.04 | 0.06 | 0.03 | 0.07 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥈 | **Graft** | 0.76 | 0.75 | 0.80 | 0.71 | 0.87 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 🥉 | **Riverpod (Notifier)** | 1.15 | 0.96 | 2.01 | 0.89 | 2.10 | 0.42 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| 4 | **Signals** | 1.78 | 1.77 | 1.83 | 1.72 | 1.84 | 0.04 | 0 | 0 | 100.0% | 0 (Zero-GC) | ✅ Pass |
| ❌ DISQ | **GetX** | 0.19 | 0.18 | 0.20 | 0.18 | 0.24 | 0.01 | 0 | 0 | 100.0% | 0 (Zero-GC) | ❌ Fail |

---

## 💡 Section F: Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.
5. **Glitch-Free Concurrency**: Synchronous domain getters and register-level bitmask diffs guarantee zero intermediate state corruption without requiring complex topological graph sorters.

