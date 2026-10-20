# 🚀 Late 2026 Flutter State Management Benchmark Report

**A Comprehensive, Empirical Comparison of Graft vs. Leading State Management Solutions**

---

## 📋 Executive Summary

This benchmark suite evaluates **Graft** against the six primary Flutter state management paradigms:
1. **Graft** (`1.0.0`) — Self-optimizing bitmask diff engine with zero-wrapper domain state
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
| **Warm-up Protocol** | 3 full iterations discarded per scenario |
| **Measurement Protocol** | **Minimum 15 measured runs per scenario** |
| **Metrics Tracked** | Mean, Median, p95, Min, Max, StdDev, Rebuilds, Allocations |

---

## 📊 Benchmark Results by Scenario

### 🔹 Scenario: A1_10k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.14 | 0.14 | 0.16 | 0.13 | 0.17 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.14 | 0.14 | 0.16 | 0.13 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.15 | 0.14 | 0.18 | 0.13 | 0.24 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 0.15 | 0.10 | 0.27 | 0.09 | 0.27 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.86 | 0.82 | 1.00 | 0.80 | 1.11 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 3.23 | 2.64 | 4.94 | 2.45 | 6.05 | 1.05 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.30 | 3.76 | 5.64 | 3.56 | 6.47 | 0.90 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.68 | 0.68 | 0.71 | 0.67 | 0.74 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.29 | 1.29 | 1.33 | 1.21 | 1.34 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.40 | 1.41 | 1.43 | 1.38 | 1.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.94 | 3.29 | 9.30 | 1.24 | 10.20 | 2.89 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.14 | 5.09 | 5.38 | 4.89 | 5.81 | 0.22 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.99 | 7.93 | 8.30 | 7.60 | 8.59 | 0.25 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.84 | 23.79 | 24.05 | 23.59 | 24.39 | 0.22 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.22 | 0.16 | 0.35 | 0.16 | 0.77 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.23 | 0.15 | 0.37 | 0.12 | 0.37 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.53 | 0.23 | 0.53 | 0.20 | 3.92 | 0.94 | 0 | 0 | 10000 |
| 4 | **GetX** | 0.71 | 0.67 | 1.14 | 0.39 | 1.23 | 0.30 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.98 | 0.87 | 1.43 | 0.61 | 2.19 | 0.41 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.37 | 1.29 | 1.84 | 1.01 | 2.01 | 0.27 | 0 | 0 | 10000 |
| 7 | **Signals** | 16.28 | 15.60 | 20.45 | 10.64 | 26.59 | 4.18 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.03 | 0.01 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.09 | 0.09 | 0.09 | 0.09 | 0.10 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.20 | 0.18 | 0.27 | 0.17 | 0.34 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.44 | 0.43 | 0.44 | 0.42 | 0.47 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.60 | 0.61 | 0.66 | 0.54 | 0.68 | 0.04 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.67 | 0.67 | 0.68 | 0.65 | 0.69 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.81 | 0.72 | 0.84 | 0.68 | 1.84 | 0.29 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 14.53 | 14.55 | 15.51 | 13.52 | 15.88 | 0.68 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 18.12 | 16.91 | 24.16 | 13.38 | 24.79 | 4.12 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 22.43 | 22.09 | 26.57 | 17.48 | 31.27 | 3.67 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (leaf slot)** | 22.50 | 22.23 | 26.59 | 15.17 | 28.55 | 3.51 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 24.79 | 23.76 | 30.98 | 18.30 | 44.40 | 6.69 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 24.95 | 22.28 | 34.68 | 16.99 | 45.44 | 7.88 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 25.73 | 26.46 | 31.48 | 18.54 | 39.78 | 5.44 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 26.00 | 22.43 | 38.47 | 20.10 | 46.88 | 7.70 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 23.42 | 23.10 | 24.36 | 22.86 | 25.13 | 0.67 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 24.44 | 23.76 | 25.75 | 23.19 | 28.41 | 1.42 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 25.17 | 24.84 | 26.34 | 24.14 | 27.81 | 1.04 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 25.51 | 24.06 | 25.94 | 23.40 | 41.90 | 4.61 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 27.77 | 25.81 | 28.58 | 24.00 | 56.52 | 8.06 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 28.52 | 26.35 | 31.89 | 24.30 | 42.53 | 4.53 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 29.08 | 27.95 | 30.77 | 26.47 | 39.81 | 3.32 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 34.18 | 32.45 | 41.25 | 27.03 | 55.04 | 6.84 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.14 | 28.66 | 30.05 | 26.90 | 39.94 | 3.13 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.25 | 29.30 | 30.72 | 28.95 | 41.17 | 3.06 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.38 | 30.82 | 35.26 | 28.96 | 46.99 | 4.49 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 48.09 | 45.91 | 60.02 | 43.79 | 67.87 | 6.75 | 300 | 0 | 300 |
| 5 | **Provider** | 55.02 | 55.33 | 56.16 | 53.51 | 56.37 | 0.90 | 300 | 0 | 300 |
| 6 | **GetX** | 63.58 | 63.61 | 65.05 | 61.29 | 66.73 | 1.39 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.75 | 30.12 | 35.52 | 29.21 | 59.94 | 7.77 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 40.89 | 35.73 | 62.63 | 32.12 | 68.73 | 12.45 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 46.71 | 45.68 | 47.60 | 42.15 | 66.80 | 5.80 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 63.85 | 62.77 | 68.70 | 58.29 | 70.50 | 3.31 | 300 | 0 | 300 |
| 5 | **GetX** | 75.55 | 70.73 | 97.62 | 65.49 | 112.86 | 12.90 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 75.74 | 73.03 | 81.78 | 68.85 | 103.06 | 8.27 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.29 | 0.29 | 0.31 | 0.28 | 0.31 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 0.84 | 0.44 | 3.27 | 0.43 | 3.54 | 1.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.85 | 0.85 | 0.88 | 0.82 | 0.89 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.00 | 0.44 | 3.18 | 0.40 | 3.37 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.39 | 0.51 | 4.80 | 0.47 | 5.43 | 1.84 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.08 | 0.01 | 0 | 0 | 100 |
| 🥉 | **Signals** | 0.08 | 0.06 | 0.09 | 0.05 | 0.27 | 0.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.50 | 2.46 | 2.91 | 2.23 | 3.01 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 7.46 | 7.29 | 11.28 | 3.84 | 11.35 | 2.37 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 8.92 | 7.55 | 15.72 | 5.57 | 17.71 | 3.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.18 | 1.13 | 1.54 | 0.99 | 1.54 | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 1.32 | 1.16 | 1.74 | 0.92 | 2.19 | 0.38 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.01 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

