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
| 🥇 | **Provider** | 0.23 | 0.17 | 0.36 | 0.13 | 0.43 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.24 | 0.15 | 0.44 | 0.13 | 0.46 | 0.14 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.26 | 0.18 | 0.36 | 0.16 | 1.10 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.36 | 0.14 | 0.44 | 0.13 | 2.98 | 0.73 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 1.43 | 1.42 | 2.13 | 0.83 | 2.22 | 0.53 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 3.18 | 2.93 | 4.06 | 2.59 | 5.28 | 0.71 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 6.14 | 5.17 | 12.78 | 0.46 | 15.85 | 5.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.13 | 1.08 | 1.40 | 0.95 | 1.47 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.73 | 1.51 | 2.29 | 1.35 | 3.09 | 0.47 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.84 | 1.78 | 2.22 | 1.44 | 2.57 | 0.32 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 5.68 | 5.34 | 10.45 | 1.37 | 10.68 | 3.13 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 8.03 | 8.45 | 9.21 | 6.30 | 10.66 | 1.33 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 10.94 | 10.39 | 13.35 | 8.63 | 13.58 | 1.72 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 27.90 | 28.55 | 31.52 | 24.55 | 32.58 | 2.56 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.21 | 0.16 | 0.45 | 0.15 | 0.46 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.36 | 0.26 | 0.74 | 0.24 | 0.82 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.50 | 0.48 | 0.71 | 0.38 | 0.73 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.54 | 0.20 | 0.56 | 0.20 | 4.27 | 1.04 | 0 | 0 | 10000 |
| 5 | **Riverpod (StateNotifier)** | 1.19 | 1.03 | 1.77 | 0.89 | 2.18 | 0.40 | 0 | 0 | 10000 |
| 6 | **Riverpod (Notifier)** | 5.73 | 5.09 | 8.20 | 3.97 | 12.98 | 2.24 | 0 | 0 | 10000 |
| 7 | **Signals** | 11.20 | 10.79 | 14.27 | 9.15 | 15.71 | 1.82 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.04 | 0.03 | 0.07 | 0.02 | 0.09 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.27 | 0.25 | 0.35 | 0.24 | 0.44 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.29 | 0.19 | 0.33 | 0.14 | 1.65 | 0.38 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.65 | 0.45 | 0.69 | 0.41 | 3.27 | 0.73 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.66 | 0.58 | 0.94 | 0.49 | 0.94 | 0.18 | 0 | 0 | 8000 |
| 6 | **Graft** | 0.70 | 0.66 | 1.03 | 0.42 | 1.23 | 0.22 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 0.94 | 0.77 | 1.44 | 0.65 | 1.69 | 0.32 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.93 | 1.64 | 2.54 | 1.48 | 3.01 | 0.48 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 22.98 | 21.96 | 29.61 | 14.95 | 37.01 | 6.49 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 26.25 | 28.14 | 32.25 | 16.29 | 40.08 | 7.02 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 29.08 | 24.27 | 50.17 | 15.93 | 57.42 | 12.72 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 29.38 | 27.08 | 34.18 | 24.12 | 52.77 | 7.14 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 39.11 | 37.91 | 53.88 | 24.16 | 57.31 | 8.83 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 56.43 | 44.31 | 88.69 | 26.78 | 155.46 | 32.98 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 137.59 | 84.02 | 291.36 | 35.76 | 304.60 | 100.92 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.51 | 1.37 | 2.33 | 1.32 | 2.34 | 0.34 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 21.12 | 21.23 | 22.00 | 20.32 | 22.73 | 0.71 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 22.43 | 22.37 | 23.85 | 20.99 | 23.98 | 1.05 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 22.73 | 22.51 | 24.67 | 21.42 | 25.50 | 1.15 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 24.06 | 23.49 | 30.92 | 20.20 | 31.69 | 3.58 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 24.11 | 23.43 | 26.61 | 20.42 | 39.28 | 4.45 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 41.23 | 33.28 | 61.36 | 28.08 | 74.16 | 14.40 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 116.78 | 77.24 | 343.25 | 37.38 | 388.48 | 108.24 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.07 | 3.60 | 5.76 | 3.48 | 5.88 | 0.92 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 33.17 | 32.10 | 33.57 | 31.20 | 45.70 | 3.55 | 300 | 0 | 300 |
| 🥉 | **BLoC (Cubit)** | 47.71 | 46.56 | 51.06 | 44.41 | 63.84 | 4.87 | 300 | 0 | 300 |
| 4 | **Graft** | 50.48 | 41.42 | 77.25 | 32.70 | 112.79 | 21.79 | 300 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 57.98 | 57.81 | 61.55 | 54.46 | 63.31 | 2.86 | 300 | 0 | 300 |
| 6 | **GetX** | 64.80 | 65.11 | 67.16 | 61.61 | 68.14 | 2.02 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 5.41 | 3.93 | 7.79 | 3.42 | 12.66 | 2.52 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 44.64 | 42.98 | 45.50 | 41.60 | 64.20 | 5.53 | 300 | 0 | 300 |
| 🥉 | **Graft** | 47.37 | 45.77 | 47.95 | 44.83 | 66.33 | 5.35 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 60.22 | 58.89 | 59.67 | 57.65 | 82.28 | 6.14 | 300 | 0 | 300 |
| 5 | **GetX** | 69.92 | 67.84 | 69.90 | 65.07 | 99.68 | 8.30 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 70.56 | 70.07 | 74.10 | 65.75 | 77.58 | 2.85 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.21 | 0.78 | 4.01 | 0.74 | 4.12 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 1.32 | 0.62 | 4.18 | 0.59 | 4.23 | 1.47 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 1.40 | 0.65 | 4.41 | 0.61 | 4.49 | 1.57 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 2.09 | 0.62 | 8.16 | 0.60 | 8.88 | 3.06 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 5.76 | 5.74 | 5.89 | 5.64 | 6.08 | 0.11 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.04 | 0.04 | 0.04 | 0.03 | 0.07 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.01 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.08 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.11 | 0.10 | 0.12 | 0.10 | 0.13 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.33 | 5.46 | 10.21 | 4.95 | 10.25 | 2.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 6.88 | 5.28 | 11.53 | 5.04 | 17.17 | 3.50 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 16.04 | 9.07 | 23.73 | 7.80 | 71.06 | 15.97 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.93 | 1.74 | 9.80 | 1.66 | 10.35 | 2.91 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.67 | 1.96 | 12.27 | 1.70 | 16.95 | 4.54 | 0 | 0 | 0 (Zero-GC) |

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

