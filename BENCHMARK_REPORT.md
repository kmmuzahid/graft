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
| 🥇 | **Graft** | 0.09 | 0.08 | 0.10 | 0.08 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.14 | 0.14 | 0.15 | 0.13 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.14 | 0.16 | 0.12 | 0.23 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.15 | 0.14 | 0.22 | 0.13 | 0.24 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.84 | 0.82 | 0.95 | 0.78 | 0.99 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.53 | 2.53 | 2.60 | 2.44 | 2.63 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.61 | 3.59 | 7.87 | 3.50 | 7.95 | 1.67 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.66 | 0.66 | 0.68 | 0.63 | 0.69 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.42 | 1.38 | 1.51 | 1.32 | 1.69 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.54 | 1.53 | 1.66 | 1.48 | 1.66 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.04 | 3.39 | 7.75 | 1.24 | 12.03 | 2.97 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.16 | 5.16 | 5.23 | 5.07 | 5.24 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.78 | 7.74 | 7.91 | 7.65 | 7.92 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 27.83 | 27.64 | 30.53 | 24.08 | 34.04 | 2.59 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.12 | 0.12 | 0.14 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.17 | 0.16 | 0.18 | 0.15 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.38 | 0.20 | 0.21 | 0.20 | 2.92 | 0.70 | 0 | 0 | 10000 |
| 4 | **GetX** | 0.41 | 0.41 | 0.42 | 0.39 | 0.42 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.68 | 0.64 | 0.89 | 0.57 | 0.92 | 0.11 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.30 | 1.19 | 1.64 | 0.93 | 1.95 | 0.28 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.23 | 9.20 | 9.31 | 9.13 | 9.45 | 0.08 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.03 | 0.01 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.05 | 0.07 | 0.08 | 0.01 | 0.10 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.07 | 0.02 | 0.17 | 0.01 | 0.17 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.43 | 0.43 | 0.44 | 0.42 | 0.47 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.63 | 0.67 | 0.57 | 0.75 | 0.04 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.74 | 0.73 | 0.92 | 0.52 | 0.97 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.80 | 0.71 | 0.81 | 0.68 | 1.88 | 0.30 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 16.89 | 15.90 | 19.47 | 14.51 | 20.24 | 1.83 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 21.78 | 19.07 | 30.18 | 16.50 | 33.28 | 5.13 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 22.07 | 21.61 | 27.09 | 17.52 | 27.11 | 3.21 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 24.01 | 23.60 | 26.88 | 19.07 | 29.55 | 2.78 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 25.04 | 24.85 | 28.97 | 20.43 | 32.23 | 2.86 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 26.48 | 24.78 | 34.74 | 20.37 | 40.19 | 5.69 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 26.69 | 26.44 | 38.24 | 19.19 | 41.12 | 6.32 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Signals** | 27.11 | 25.82 | 31.14 | 20.28 | 54.19 | 8.13 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 24.15 | 23.81 | 25.16 | 23.50 | 25.72 | 0.72 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 25.91 | 25.36 | 27.19 | 24.66 | 27.65 | 1.00 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 26.79 | 26.45 | 28.39 | 25.77 | 28.90 | 1.03 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 26.98 | 26.40 | 28.52 | 26.01 | 28.59 | 1.03 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 27.13 | 26.93 | 30.79 | 24.82 | 32.36 | 2.17 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 28.00 | 27.45 | 29.41 | 26.70 | 31.04 | 1.33 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 28.09 | 26.12 | 29.53 | 25.80 | 45.15 | 4.88 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 28.78 | 27.20 | 29.17 | 25.37 | 48.67 | 5.62 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.06 | 28.20 | 31.09 | 27.36 | 36.44 | 2.28 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 31.28 | 30.32 | 31.45 | 29.63 | 43.55 | 3.43 | 300 | 0 | 300 |
| 🥉 | **Signals** | 33.50 | 31.00 | 48.19 | 29.91 | 50.37 | 6.49 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 51.29 | 50.19 | 62.98 | 44.53 | 68.03 | 6.74 | 300 | 0 | 300 |
| 5 | **Provider** | 57.19 | 57.25 | 58.65 | 54.98 | 59.20 | 1.14 | 300 | 0 | 300 |
| 6 | **GetX** | 66.92 | 66.04 | 73.86 | 63.20 | 76.78 | 3.64 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 31.29 | 30.93 | 32.31 | 29.75 | 34.49 | 1.20 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 41.79 | 39.01 | 64.48 | 34.67 | 70.23 | 10.65 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 51.41 | 48.59 | 61.90 | 44.56 | 73.47 | 7.65 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 69.54 | 63.56 | 88.23 | 59.51 | 93.87 | 11.35 | 300 | 0 | 300 |
| 5 | **GetX** | 73.91 | 72.06 | 74.98 | 67.88 | 98.53 | 7.12 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 77.50 | 76.52 | 77.49 | 72.19 | 104.01 | 7.52 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.30 | 0.29 | 0.31 | 0.28 | 0.32 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.86 | 0.86 | 0.89 | 0.82 | 0.89 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.89 | 0.48 | 3.60 | 0.43 | 3.67 | 1.11 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.95 | 0.48 | 4.03 | 0.43 | 4.07 | 1.26 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.44 | 0.54 | 4.62 | 0.48 | 5.73 | 1.83 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.04 | 0.03 | 0.04 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.07 | 0.06 | 0.08 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.07 | 0.06 | 0.07 | 0.06 | 0.17 | 0.03 | 0 | 0 | 100 |
| 🥉 | **Signals** | 0.11 | 0.06 | 0.15 | 0.06 | 0.62 | 0.14 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 3.11 | 3.09 | 3.86 | 2.31 | 4.17 | 0.52 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 4.09 | 3.38 | 5.94 | 3.05 | 8.80 | 1.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.98 | 6.55 | 9.04 | 5.26 | 11.35 | 1.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.89 | 0.87 | 0.96 | 0.77 | 1.30 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.99 | 0.94 | 1.18 | 0.83 | 1.61 | 0.20 | 0 | 0 | 0 (Zero-GC) |

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

