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
| 🥇 | **Graft** | 0.10 | 0.11 | 0.12 | 0.09 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.13 | 0.13 | 0.14 | 0.13 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.14 | 0.15 | 0.12 | 0.21 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 0.14 | 0.14 | 0.16 | 0.13 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.78 | 0.77 | 0.82 | 0.74 | 0.86 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 0.88 | 0.61 | 1.50 | 0.56 | 3.87 | 0.86 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.84 | 2.60 | 3.43 | 2.42 | 4.55 | 0.57 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.69 | 0.69 | 0.72 | 0.67 | 0.73 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.33 | 1.34 | 1.39 | 1.29 | 1.40 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.38 | 1.38 | 1.39 | 1.36 | 1.40 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.22 | 3.42 | 9.56 | 1.29 | 9.88 | 2.97 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.24 | 5.21 | 5.57 | 4.98 | 5.68 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.51 | 7.42 | 7.77 | 7.37 | 7.82 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.16 | 23.99 | 24.82 | 23.54 | 25.34 | 0.51 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.15 | 0.18 | 0.14 | 0.25 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.40 | 0.39 | 0.42 | 0.37 | 0.42 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.44 | 0.21 | 1.05 | 0.19 | 2.81 | 0.69 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.61 | 0.58 | 0.73 | 0.56 | 0.76 | 0.06 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.85 | 0.84 | 0.92 | 0.81 | 0.95 | 0.04 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.20 | 9.20 | 9.46 | 8.96 | 9.49 | 0.18 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.11 | 0.09 | 0.19 | 0.08 | 0.20 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.19 | 0.18 | 0.24 | 0.15 | 0.28 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.41 | 0.43 | 0.40 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.57 | 0.57 | 0.60 | 0.53 | 0.61 | 0.02 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.76 | 0.69 | 0.79 | 0.66 | 1.70 | 0.26 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.83 | 0.69 | 0.79 | 0.66 | 2.71 | 0.52 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 15.14 | 15.16 | 16.81 | 13.48 | 17.23 | 1.01 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 16.23 | 16.16 | 18.47 | 14.26 | 19.92 | 1.53 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 17.65 | 15.24 | 25.40 | 13.97 | 30.15 | 4.73 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (leaf slot)** | 17.68 | 16.89 | 22.15 | 13.67 | 22.45 | 2.85 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 23.54 | 20.56 | 40.22 | 16.20 | 43.65 | 8.34 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 24.41 | 21.91 | 38.54 | 16.27 | 43.52 | 7.69 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 26.60 | 22.04 | 42.06 | 17.00 | 52.20 | 9.67 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 31.83 | 27.94 | 52.08 | 19.36 | 59.50 | 10.75 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 26.35 | 26.11 | 28.38 | 23.72 | 31.11 | 2.13 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 27.82 | 26.72 | 30.50 | 25.27 | 43.61 | 4.57 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 31.64 | 29.05 | 40.02 | 24.16 | 50.80 | 7.39 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 36.20 | 36.42 | 43.95 | 27.91 | 45.95 | 5.53 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 36.51 | 33.98 | 44.36 | 30.56 | 63.84 | 8.62 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 36.94 | 36.13 | 49.82 | 25.57 | 50.35 | 7.94 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 37.00 | 33.50 | 47.23 | 31.73 | 62.81 | 8.56 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 43.14 | 40.45 | 58.61 | 27.65 | 76.58 | 12.02 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.87 | 28.16 | 30.14 | 26.81 | 38.26 | 2.73 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 31.14 | 29.76 | 34.19 | 28.50 | 45.67 | 4.25 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 31.92 | 30.50 | 35.22 | 29.45 | 45.78 | 4.22 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 45.96 | 45.32 | 46.61 | 43.97 | 57.36 | 3.23 | 300 | 0 | 300 |
| 5 | **Provider** | 56.72 | 56.53 | 59.28 | 54.47 | 59.98 | 1.67 | 300 | 0 | 300 |
| 6 | **GetX** | 64.91 | 63.69 | 71.03 | 60.62 | 75.42 | 4.00 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.29 | 30.33 | 31.52 | 28.68 | 33.43 | 1.17 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 39.90 | 36.12 | 58.86 | 32.49 | 61.52 | 10.35 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.89 | 44.67 | 47.53 | 42.07 | 68.77 | 6.53 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.47 | 59.96 | 61.79 | 58.77 | 83.26 | 6.07 | 300 | 0 | 300 |
| 5 | **GetX** | 73.53 | 70.74 | 83.59 | 66.60 | 97.80 | 8.18 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 76.22 | 72.79 | 78.78 | 68.55 | 115.19 | 11.12 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.33 | 0.35 | 0.32 | 0.36 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.86 | 0.87 | 0.90 | 0.82 | 0.91 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.99 | 0.45 | 3.12 | 0.43 | 3.38 | 1.14 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 1.05 | 0.46 | 3.46 | 0.42 | 3.73 | 1.25 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.25 | 0.53 | 4.75 | 0.50 | 6.02 | 1.71 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.04 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.07 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.07 | 0.05 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.66 | 2.63 | 3.02 | 2.43 | 3.12 | 0.21 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.50 | 2.98 | 4.70 | 2.74 | 7.60 | 1.28 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.33 | 5.20 | 6.08 | 4.69 | 6.10 | 0.48 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.64 | 1.27 | 3.31 | 0.94 | 3.37 | 0.81 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 1.88 | 1.68 | 2.94 | 0.94 | 3.06 | 0.80 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC** | 0.01 | 0.01 | 0.03 | 0.00 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

