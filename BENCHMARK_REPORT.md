# 🚀 Late 2026 Flutter State Management Benchmark Report

**A Comprehensive, Empirical Comparison of Graft vs. Leading State Management Solutions**

---

## 📋 Executive Summary

This benchmark suite evaluates **Graft** against the six primary Flutter state management paradigms:
1. **Graft** (`0.1.2-alpha.4`) — Self-optimizing bitmask diff engine with zero-wrapper domain state
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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.09 | 0.08 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.41 | 1.28 | 1.36 | 1.27 | 3.08 | 0.46 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.62 | 1.61 | 1.66 | 1.58 | 1.68 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 1.98 | 1.98 | 1.99 | 1.97 | 2.00 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 4.82 | 3.52 | 6.94 | 3.44 | 7.02 | 1.69 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 7.28 | 7.05 | 8.18 | 6.49 | 9.32 | 0.75 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 12.63 | 5.07 | 45.04 | 4.84 | 51.13 | 14.77 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.29 | 1.29 | 1.34 | 1.21 | 1.36 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.33 | 1.33 | 1.36 | 1.29 | 1.39 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.68 | 2.67 | 2.73 | 2.63 | 2.74 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.82 | 3.36 | 8.35 | 1.21 | 10.92 | 3.04 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 23.20 | 23.13 | 23.51 | 23.00 | 23.63 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 51.76 | 10.44 | 149.41 | 6.98 | 214.23 | 65.76 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 73.58 | 49.02 | 125.79 | 39.04 | 194.46 | 45.44 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.26 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.20 | 0.19 | 0.23 | 0.18 | 0.23 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.38 | 0.38 | 0.40 | 0.36 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 2.22 | 2.01 | 2.06 | 1.95 | 5.14 | 0.81 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 3.65 | 3.32 | 4.41 | 3.21 | 4.42 | 0.52 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 11.67 | 4.53 | 34.36 | 4.39 | 41.19 | 12.78 | 0 | 0 | 10000 |
| 7 | **Signals** | 25.05 | 9.14 | 52.90 | 8.98 | 85.90 | 23.63 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.08 | 0.09 | 0.09 | 0.08 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.14 | 0.14 | 0.15 | 0.14 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.34 | 0.34 | 0.37 | 0.32 | 0.37 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.41 | 0.40 | 0.43 | 0.37 | 0.44 | 0.02 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.54 | 0.48 | 0.51 | 0.45 | 1.33 | 0.22 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.66 | 0.57 | 0.60 | 0.53 | 2.00 | 0.37 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.71 | 0.64 | 0.66 | 0.60 | 1.81 | 0.30 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 13.01 | 12.88 | 13.65 | 12.41 | 13.91 | 0.43 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 13.17 | 12.70 | 16.20 | 12.35 | 16.27 | 1.28 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (slots)** | 13.70 | 13.53 | 15.86 | 12.69 | 16.25 | 1.07 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 14.34 | 14.22 | 15.60 | 13.07 | 16.19 | 0.87 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 14.53 | 14.22 | 17.79 | 13.12 | 18.14 | 1.53 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 14.66 | 14.33 | 16.84 | 13.14 | 17.74 | 1.29 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 14.80 | 14.59 | 15.95 | 13.38 | 16.58 | 0.83 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 19.75 | 19.25 | 23.66 | 16.31 | 24.39 | 2.71 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 21.64 | 21.47 | 22.28 | 20.95 | 22.51 | 0.49 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 21.93 | 21.96 | 22.74 | 21.04 | 23.14 | 0.59 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 23.07 | 23.43 | 23.91 | 21.95 | 24.40 | 0.80 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 23.09 | 22.46 | 24.47 | 22.02 | 26.07 | 1.19 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 23.73 | 23.64 | 24.95 | 22.33 | 26.44 | 1.07 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 24.23 | 24.68 | 25.24 | 22.89 | 25.83 | 0.98 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 24.70 | 24.09 | 26.79 | 23.30 | 28.32 | 1.45 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 24.97 | 24.22 | 27.54 | 23.10 | 28.26 | 1.70 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 27.09 | 27.00 | 28.31 | 25.71 | 28.36 | 0.82 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 28.86 | 28.66 | 29.56 | 28.31 | 29.99 | 0.49 | 300 | 0 | 300 |
| 🥉 | **Signals** | 30.66 | 30.07 | 32.54 | 28.08 | 44.05 | 3.94 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 43.29 | 42.77 | 46.80 | 41.52 | 47.91 | 1.82 | 300 | 0 | 300 |
| 5 | **Provider** | 57.11 | 55.86 | 59.09 | 52.27 | 80.78 | 6.80 | 300 | 0 | 300 |
| 6 | **GetX** | 62.71 | 61.68 | 63.60 | 59.91 | 77.65 | 4.24 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 35.97 | 32.01 | 42.80 | 27.76 | 76.94 | 12.49 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 38.41 | 34.32 | 60.16 | 31.09 | 61.61 | 11.19 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 43.82 | 43.91 | 46.27 | 40.99 | 47.10 | 1.58 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 59.40 | 57.71 | 59.54 | 57.00 | 81.48 | 6.15 | 300 | 0 | 300 |
| 5 | **GetX** | 67.02 | 67.22 | 67.87 | 64.58 | 68.96 | 1.03 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 71.80 | 69.77 | 75.38 | 66.38 | 95.38 | 6.82 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.69 | 0.68 | 0.74 | 0.60 | 0.86 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.93 | 0.49 | 3.73 | 0.46 | 3.85 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 1.22 | 0.50 | 4.50 | 0.45 | 7.41 | 2.00 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 1.33 | 0.49 | 4.59 | 0.47 | 4.88 | 1.73 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 5.76 | 5.77 | 5.85 | 5.58 | 5.88 | 0.09 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.04 | 0.04 | 0.04 | 0.04 | 0.04 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.12 | 0.06 | 0.06 | 0.06 | 1.00 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.18 | 0.12 | 0.40 | 0.12 | 0.63 | 0.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 9.34 | 6.25 | 9.09 | 4.96 | 52.36 | 11.98 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 11.24 | 6.67 | 7.72 | 5.25 | 75.98 | 17.93 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 12.05 | 8.29 | 24.22 | 7.25 | 30.09 | 7.50 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.81 | 1.59 | 1.71 | 1.55 | 4.79 | 0.82 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.87 | 1.64 | 1.94 | 1.57 | 4.52 | 0.74 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.01 | 0.00 | 0.01 | 0.00 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.02 | 0.01 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

