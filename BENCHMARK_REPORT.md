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
| 🥇 | **Graft** | 0.12 | 0.10 | 0.19 | 0.06 | 0.49 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.14 | 0.14 | 0.15 | 0.13 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.15 | 0.14 | 0.16 | 0.14 | 0.28 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.35 | 0.13 | 1.01 | 0.12 | 2.47 | 0.63 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.60 | 0.58 | 0.65 | 0.53 | 0.80 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 0.89 | 0.89 | 0.92 | 0.85 | 0.94 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.52 | 2.52 | 2.60 | 2.42 | 2.66 | 0.07 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.97 | 0.70 | 0.71 | 0.68 | 4.77 | 1.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.42 | 1.42 | 1.48 | 1.33 | 1.51 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.56 | 1.54 | 1.63 | 1.52 | 1.74 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 5.20 | 4.44 | 10.31 | 1.26 | 12.23 | 3.04 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 6.45 | 6.39 | 6.77 | 6.21 | 6.88 | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 8.62 | 8.61 | 8.79 | 8.46 | 8.95 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.73 | 24.67 | 25.16 | 24.30 | 25.57 | 0.34 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.16 | 0.15 | 0.16 | 0.15 | 0.26 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.21 | 0.16 | 0.18 | 0.16 | 0.81 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.41 | 0.41 | 0.42 | 0.40 | 0.43 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.50 | 0.22 | 0.67 | 0.20 | 3.03 | 0.72 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.90 | 0.61 | 1.53 | 0.55 | 1.55 | 0.41 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.09 | 0.90 | 1.62 | 0.87 | 1.90 | 0.33 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.06 | 9.04 | 9.32 | 8.90 | 9.40 | 0.14 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.11 | 0.10 | 0.13 | 0.10 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.16 | 0.17 | 0.15 | 0.17 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.33 | 0.32 | 0.34 | 0.32 | 0.34 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.43 | 0.42 | 0.48 | 0.41 | 0.50 | 0.03 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.59 | 0.51 | 0.55 | 0.50 | 1.59 | 0.28 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.86 | 0.70 | 1.47 | 0.68 | 1.64 | 0.33 | 0 | 0 | 8000 |
| 7 | **Signals** | 1.23 | 0.90 | 1.37 | 0.86 | 4.82 | 1.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 12.87 | 12.65 | 13.62 | 12.35 | 14.12 | 0.53 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 14.00 | 14.04 | 15.24 | 12.83 | 15.52 | 0.82 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 14.33 | 14.38 | 14.88 | 13.25 | 14.89 | 0.46 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 21.32 | 19.64 | 28.67 | 15.43 | 40.78 | 6.63 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 35.28 | 31.97 | 44.16 | 23.42 | 91.19 | 16.97 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 47.63 | 46.72 | 78.34 | 29.89 | 87.11 | 16.75 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 67.99 | 56.27 | 111.33 | 45.01 | 137.01 | 27.18 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 71.63 | 53.18 | 125.83 | 43.24 | 248.61 | 52.87 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 23.23 | 23.16 | 24.48 | 22.12 | 25.22 | 0.80 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 24.59 | 24.34 | 25.66 | 23.02 | 29.70 | 1.59 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 24.85 | 24.57 | 26.42 | 23.61 | 27.21 | 0.97 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 24.97 | 25.03 | 25.82 | 23.80 | 26.53 | 0.71 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 25.04 | 25.01 | 26.22 | 23.98 | 26.40 | 0.80 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 26.02 | 24.78 | 26.28 | 23.42 | 41.31 | 4.32 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 50.11 | 45.28 | 66.07 | 25.94 | 120.96 | 22.21 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 93.95 | 77.89 | 240.74 | 30.57 | 362.67 | 89.99 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 33.83 | 32.72 | 34.41 | 31.87 | 45.57 | 3.34 | 300 | 0 | 300 |
| 🥈 | **Signals** | 37.41 | 33.55 | 50.32 | 31.91 | 71.57 | 10.43 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 62.56 | 47.29 | 118.48 | 34.23 | 141.48 | 33.90 | 300 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 63.71 | 61.61 | 71.61 | 59.25 | 80.29 | 5.73 | 300 | 0 | 300 |
| 5 | **BLoC (Cubit)** | 64.17 | 50.40 | 115.34 | 47.93 | 157.17 | 31.04 | 300 | 0 | 300 |
| 6 | **GetX** | 69.85 | 69.21 | 72.75 | 67.29 | 75.17 | 2.24 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.36 | 31.91 | 34.43 | 31.00 | 34.77 | 1.20 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 47.87 | 42.34 | 76.94 | 35.54 | 78.81 | 14.83 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 48.08 | 46.50 | 48.49 | 44.69 | 69.41 | 6.01 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 64.63 | 64.40 | 69.10 | 60.17 | 69.97 | 2.79 | 300 | 0 | 300 |
| 5 | **Provider** | 80.67 | 78.57 | 83.35 | 76.53 | 108.83 | 8.01 | 300 | 0 | 300 |
| 6 | **GetX** | 81.95 | 80.89 | 87.32 | 76.29 | 106.24 | 7.36 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.38 | 0.77 | 4.73 | 0.70 | 6.12 | 1.66 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 1.40 | 0.49 | 6.80 | 0.47 | 7.79 | 2.40 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.52 | 0.51 | 5.20 | 0.47 | 6.66 | 2.15 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.99 | 0.50 | 7.78 | 0.46 | 9.43 | 3.13 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 4.93 | 4.73 | 4.94 | 4.68 | 7.33 | 0.67 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.04 | 0.03 | 0.05 | 0.01 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.04 | 0.04 | 0.04 | 0.04 | 0.05 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.07 | 0.06 | 0.07 | 0.06 | 0.08 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.07 | 0.06 | 0.10 | 0.06 | 0.17 | 0.03 | 0 | 0 | 100 |
| 🥉 | **Graft** | 0.14 | 0.14 | 0.15 | 0.14 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 9.34 | 7.60 | 15.71 | 6.71 | 16.42 | 3.43 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 9.65 | 8.03 | 18.26 | 6.96 | 21.80 | 4.35 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 34.86 | 12.87 | 142.94 | 10.66 | 173.97 | 50.95 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.59 | 2.83 | 21.29 | 1.76 | 28.38 | 7.95 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 14.91 | 2.76 | 18.52 | 2.10 | 166.06 | 42.02 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.01 | 0.00 | 0.01 | 0.00 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

