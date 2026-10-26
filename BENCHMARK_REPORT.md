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
| 🥇 | **GetX** | 0.13 | 0.13 | 0.15 | 0.13 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.14 | 0.09 | 0.10 | 0.09 | 0.96 | 0.23 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.15 | 0.14 | 0.17 | 0.13 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.17 | 0.14 | 0.16 | 0.13 | 0.57 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.77 | 0.56 | 0.99 | 0.54 | 3.13 | 0.66 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 0.83 | 0.81 | 0.89 | 0.78 | 0.91 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.67 | 2.54 | 3.42 | 2.46 | 3.43 | 0.32 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.70 | 0.70 | 0.72 | 0.68 | 0.72 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.42 | 1.41 | 1.52 | 1.34 | 1.54 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.45 | 1.44 | 1.51 | 1.41 | 1.55 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.30 | 3.47 | 9.71 | 1.24 | 12.46 | 3.38 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.13 | 5.13 | 5.22 | 5.02 | 5.25 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.72 | 7.63 | 8.16 | 7.37 | 8.20 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 25.28 | 24.91 | 27.75 | 23.22 | 29.36 | 1.81 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.15 | 0.15 | 0.16 | 0.14 | 0.18 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.18 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.39 | 0.39 | 0.42 | 0.35 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.46 | 0.21 | 1.32 | 0.19 | 2.83 | 0.71 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.60 | 0.58 | 0.67 | 0.55 | 0.70 | 0.04 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.85 | 0.83 | 0.92 | 0.78 | 0.99 | 0.06 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.90 | 8.89 | 8.95 | 8.78 | 9.27 | 0.12 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.09 | 0.09 | 0.12 | 0.08 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.18 | 0.18 | 0.20 | 0.15 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.42 | 0.44 | 0.41 | 0.45 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.55 | 0.55 | 0.60 | 0.51 | 0.61 | 0.03 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.67 | 0.66 | 0.69 | 0.65 | 0.72 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.78 | 0.69 | 0.75 | 0.68 | 1.96 | 0.33 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 13.65 | 13.43 | 14.36 | 12.98 | 14.46 | 0.52 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 13.72 | 13.28 | 13.68 | 12.37 | 23.04 | 2.61 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (slots)** | 13.81 | 13.48 | 14.41 | 13.12 | 15.49 | 0.64 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (leaf slot)** | 13.98 | 13.32 | 18.82 | 12.20 | 20.14 | 2.33 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 15.34 | 14.92 | 15.19 | 13.51 | 25.31 | 2.81 | 120 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 15.69 | 15.45 | 16.66 | 14.51 | 18.41 | 1.03 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 16.45 | 16.50 | 17.36 | 15.13 | 17.80 | 0.77 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 16.88 | 16.27 | 19.19 | 14.91 | 21.25 | 1.77 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 23.59 | 23.22 | 24.95 | 22.45 | 25.50 | 0.91 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 24.22 | 24.02 | 26.58 | 23.02 | 26.82 | 1.22 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (leaf slot)** | 25.03 | 24.31 | 26.97 | 21.99 | 34.98 | 3.00 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 26.09 | 25.59 | 29.54 | 23.86 | 31.91 | 2.21 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 26.31 | 25.64 | 28.13 | 24.76 | 30.24 | 1.62 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 27.23 | 25.89 | 30.49 | 23.24 | 44.99 | 5.39 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 27.65 | 25.82 | 31.82 | 24.11 | 44.55 | 5.26 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Signals** | 28.89 | 28.23 | 33.03 | 24.46 | 36.26 | 3.03 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.09 | 27.20 | 29.61 | 26.19 | 37.66 | 2.84 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.83 | 29.56 | 31.83 | 28.23 | 42.81 | 3.49 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.52 | 30.40 | 46.60 | 28.53 | 46.79 | 5.86 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 49.56 | 46.50 | 59.65 | 44.10 | 78.92 | 9.04 | 300 | 0 | 300 |
| 5 | **Provider** | 57.32 | 56.78 | 62.09 | 53.00 | 63.06 | 3.05 | 300 | 0 | 300 |
| 6 | **GetX** | 65.78 | 65.12 | 68.16 | 62.87 | 73.27 | 2.55 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 36.98 | 30.80 | 39.26 | 28.67 | 112.43 | 21.08 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 43.81 | 38.77 | 61.03 | 32.23 | 78.35 | 12.87 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 46.15 | 43.84 | 47.92 | 41.90 | 66.31 | 5.89 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.63 | 60.06 | 69.37 | 58.45 | 73.23 | 4.35 | 300 | 0 | 300 |
| 5 | **Provider** | 77.88 | 76.98 | 80.85 | 71.13 | 100.48 | 7.06 | 300 | 0 | 300 |
| 6 | **GetX** | 83.65 | 80.20 | 101.46 | 73.31 | 131.30 | 14.76 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.33 | 0.35 | 0.31 | 0.36 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.85 | 0.85 | 0.89 | 0.79 | 0.90 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.88 | 0.46 | 3.55 | 0.43 | 3.60 | 1.09 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.00 | 0.46 | 3.25 | 0.40 | 3.37 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.17 | 0.54 | 4.49 | 0.48 | 4.86 | 1.44 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.03 | 0.02 | 0.04 | 0.02 | 0.09 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.04 | 0.03 | 0.06 | 0.01 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.05 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.09 | 0.06 | 0.07 | 0.05 | 0.53 | 0.12 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.61 | 2.41 | 3.13 | 2.14 | 3.38 | 0.37 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 4.00 | 3.24 | 8.78 | 2.69 | 8.85 | 2.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.36 | 5.13 | 5.99 | 4.72 | 6.89 | 0.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.83 | 0.82 | 0.90 | 0.75 | 0.96 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.94 | 0.89 | 1.21 | 0.77 | 1.64 | 0.22 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

