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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.10 | 0.08 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.14 | 0.13 | 0.17 | 0.12 | 0.19 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.14 | 0.14 | 0.16 | 0.13 | 0.17 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.17 | 0.13 | 0.15 | 0.13 | 0.68 | 0.14 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.77 | 0.77 | 0.81 | 0.72 | 0.85 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.82 | 2.42 | 3.27 | 2.33 | 6.50 | 1.05 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 3.95 | 3.40 | 5.23 | 3.29 | 5.55 | 0.80 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.63 | 0.63 | 0.65 | 0.60 | 0.66 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.28 | 1.28 | 1.31 | 1.22 | 1.32 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.49 | 1.45 | 1.49 | 1.42 | 2.15 | 0.18 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.70 | 3.09 | 8.59 | 1.21 | 9.25 | 2.87 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.04 | 5.02 | 5.28 | 4.87 | 5.36 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.39 | 7.34 | 7.71 | 7.20 | 7.83 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.46 | 23.22 | 24.25 | 22.91 | 24.28 | 0.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.12 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.14 | 0.18 | 0.14 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.41 | 0.41 | 0.44 | 0.38 | 0.45 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.46 | 0.19 | 1.40 | 0.17 | 2.95 | 0.76 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.59 | 0.57 | 0.67 | 0.55 | 0.73 | 0.05 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.79 | 0.79 | 0.83 | 0.73 | 0.85 | 0.03 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.88 | 8.89 | 8.95 | 8.79 | 9.12 | 0.09 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.03 | 0.01 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.10 | 0.09 | 0.13 | 0.09 | 0.15 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.20 | 0.19 | 0.25 | 0.14 | 0.37 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.42 | 0.43 | 0.41 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.59 | 0.55 | 0.58 | 0.54 | 1.08 | 0.14 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.79 | 0.70 | 0.81 | 0.69 | 1.69 | 0.25 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.90 | 0.68 | 1.87 | 0.63 | 2.22 | 0.49 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 12.13 | 12.15 | 12.29 | 11.56 | 13.33 | 0.42 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 12.33 | 12.30 | 12.86 | 11.73 | 13.35 | 0.43 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 12.77 | 12.87 | 13.15 | 12.08 | 13.20 | 0.39 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 13.11 | 12.83 | 13.77 | 12.58 | 16.14 | 0.90 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 13.46 | 13.04 | 13.64 | 12.04 | 21.06 | 2.14 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 14.02 | 13.59 | 15.56 | 12.93 | 17.61 | 1.17 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 14.26 | 13.69 | 14.29 | 12.58 | 22.88 | 2.43 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Provider** | 14.33 | 14.30 | 14.58 | 12.98 | 15.82 | 0.55 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 21.81 | 21.59 | 23.02 | 21.22 | 23.26 | 0.63 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 23.15 | 22.76 | 23.93 | 22.37 | 25.74 | 0.91 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 23.35 | 23.46 | 24.43 | 22.10 | 24.54 | 0.84 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 24.17 | 23.55 | 25.43 | 23.11 | 26.48 | 1.06 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 25.04 | 24.55 | 26.27 | 24.07 | 28.09 | 1.16 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 25.19 | 23.89 | 25.49 | 22.97 | 42.17 | 4.78 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 25.31 | 24.62 | 27.94 | 23.55 | 28.80 | 1.73 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 26.15 | 24.26 | 28.92 | 23.18 | 39.28 | 4.09 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.15 | 27.11 | 29.53 | 26.25 | 40.14 | 3.43 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 30.05 | 29.12 | 31.31 | 27.72 | 45.12 | 4.30 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 30.68 | 30.46 | 31.64 | 29.01 | 36.39 | 1.78 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 43.55 | 42.77 | 44.37 | 41.89 | 55.00 | 3.23 | 300 | 0 | 300 |
| 5 | **Provider** | 54.76 | 54.25 | 54.83 | 52.20 | 69.90 | 4.30 | 300 | 0 | 300 |
| 6 | **GetX** | 61.54 | 60.95 | 63.63 | 59.28 | 67.53 | 1.98 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.71 | 28.06 | 30.38 | 27.70 | 30.54 | 1.01 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 38.41 | 34.24 | 60.45 | 31.09 | 62.23 | 11.44 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 47.62 | 44.41 | 63.63 | 40.39 | 84.83 | 11.76 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 59.00 | 58.19 | 61.32 | 57.60 | 61.51 | 1.50 | 300 | 0 | 300 |
| 5 | **GetX** | 71.70 | 69.26 | 77.02 | 65.28 | 96.50 | 7.50 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 72.22 | 70.61 | 71.48 | 67.37 | 98.84 | 7.47 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.29 | 0.29 | 0.31 | 0.28 | 0.31 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 0.82 | 0.46 | 3.07 | 0.43 | 3.35 | 0.97 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.83 | 0.83 | 0.86 | 0.79 | 0.86 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 0.98 | 0.47 | 3.10 | 0.43 | 3.15 | 1.08 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.20 | 0.51 | 3.96 | 0.48 | 4.07 | 1.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.04 | 0.03 | 0.04 | 0.01 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥉 | **Signals** | 0.07 | 0.06 | 0.08 | 0.06 | 0.13 | 0.02 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.35 | 2.31 | 2.62 | 2.12 | 2.63 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.18 | 2.69 | 5.38 | 2.59 | 5.76 | 1.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.15 | 4.96 | 5.94 | 4.32 | 6.56 | 0.61 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.81 | 0.80 | 0.85 | 0.78 | 0.89 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.92 | 0.90 | 1.00 | 0.81 | 1.28 | 0.12 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

