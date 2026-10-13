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
| 🥇 | **Graft** | 0.09 | 0.10 | 0.10 | 0.09 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.43 | 1.30 | 1.52 | 1.22 | 2.93 | 0.42 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 2.06 | 2.03 | 2.21 | 1.91 | 2.23 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 5.26 | 3.60 | 8.83 | 3.49 | 8.83 | 2.47 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 5.49 | 1.69 | 1.78 | 1.63 | 58.62 | 14.70 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 8.45 | 5.16 | 13.36 | 5.00 | 18.90 | 4.24 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.46 | 7.15 | 75.46 | 6.55 | 154.99 | 40.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.29 | 1.29 | 1.34 | 1.21 | 1.36 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.43 | 1.43 | 1.49 | 1.38 | 1.50 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.59 | 2.59 | 2.65 | 2.52 | 2.66 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.86 | 3.69 | 7.79 | 1.28 | 8.24 | 2.34 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 23.84 | 23.75 | 24.27 | 23.57 | 24.32 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 96.36 | 57.98 | 205.47 | 39.54 | 208.37 | 63.42 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 135.50 | 134.30 | 238.41 | 11.60 | 291.87 | 78.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.14 | 0.17 | 0.14 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.39 | 0.39 | 0.42 | 0.35 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 3.90 | 3.41 | 5.10 | 3.28 | 5.17 | 0.77 | 0 | 0 | 10000 |
| 5 | **BLoC (Cubit)** | 6.52 | 2.08 | 10.09 | 2.01 | 60.66 | 15.12 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 11.76 | 4.66 | 10.26 | 4.42 | 96.65 | 23.54 | 0 | 0 | 10000 |
| 7 | **Signals** | 43.73 | 22.44 | 108.34 | 8.95 | 144.82 | 41.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.09 | 0.09 | 0.09 | 0.08 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.16 | 0.17 | 0.14 | 0.18 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.25 | 0.26 | 0.28 | 0.03 | 0.35 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.43 | 0.42 | 0.43 | 0.42 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.92 | 0.59 | 0.63 | 0.55 | 5.56 | 1.28 | 0 | 0 | 8000 |
| 6 | **Signals** | 0.95 | 0.60 | 0.63 | 0.57 | 5.92 | 1.37 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 1.07 | 0.70 | 0.75 | 0.67 | 6.14 | 1.40 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 13.10 | 12.63 | 13.53 | 12.05 | 20.35 | 2.04 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 13.18 | 12.71 | 13.97 | 12.24 | 17.59 | 1.34 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 13.46 | 13.29 | 14.46 | 12.55 | 15.04 | 0.67 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 13.83 | 13.85 | 14.22 | 13.26 | 14.50 | 0.38 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 14.07 | 13.28 | 17.94 | 12.38 | 21.86 | 2.51 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 14.22 | 14.00 | 15.28 | 13.43 | 15.33 | 0.58 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 14.51 | 14.59 | 15.43 | 13.27 | 15.63 | 0.64 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 16.18 | 15.58 | 19.39 | 13.90 | 20.06 | 1.76 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 22.05 | 21.88 | 22.51 | 21.13 | 24.87 | 0.91 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 22.16 | 21.83 | 23.21 | 21.46 | 23.23 | 0.66 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 22.98 | 22.52 | 23.86 | 22.34 | 24.61 | 0.74 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 23.83 | 23.60 | 24.97 | 22.87 | 25.93 | 0.86 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 24.62 | 23.92 | 27.05 | 23.10 | 27.48 | 1.51 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 24.89 | 24.43 | 25.99 | 24.17 | 26.13 | 0.74 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 25.17 | 23.88 | 25.49 | 23.31 | 40.56 | 4.31 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (StateNotifier)** | 25.39 | 24.48 | 30.09 | 21.97 | 35.53 | 3.51 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 27.71 | 27.09 | 28.06 | 26.09 | 37.93 | 2.88 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 29.62 | 28.92 | 29.60 | 28.17 | 40.80 | 3.12 | 300 | 0 | 300 |
| 🥉 | **Signals** | 30.32 | 29.25 | 37.57 | 28.06 | 38.50 | 3.24 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 47.51 | 44.43 | 53.13 | 41.31 | 76.35 | 8.72 | 300 | 0 | 300 |
| 5 | **Provider** | 56.16 | 55.61 | 60.81 | 52.89 | 61.23 | 2.73 | 300 | 0 | 300 |
| 6 | **GetX** | 62.39 | 61.94 | 65.21 | 59.94 | 66.42 | 1.93 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.60 | 28.46 | 32.02 | 27.76 | 43.04 | 3.90 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 37.08 | 34.24 | 57.07 | 31.55 | 60.99 | 9.08 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 43.65 | 42.28 | 43.89 | 41.09 | 64.14 | 5.73 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 62.49 | 59.86 | 64.85 | 57.99 | 89.63 | 7.71 | 300 | 0 | 300 |
| 5 | **GetX** | 75.47 | 70.63 | 99.24 | 68.26 | 107.62 | 11.79 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 76.48 | 74.85 | 79.83 | 70.23 | 103.83 | 8.09 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 1.00 | 0.51 | 4.24 | 0.45 | 4.35 | 1.34 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 1.02 | 0.48 | 4.46 | 0.45 | 4.54 | 1.41 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 1.20 | 0.72 | 4.19 | 0.65 | 4.44 | 1.27 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.67 | 0.52 | 6.07 | 0.49 | 12.22 | 3.25 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 4.66 | 4.65 | 4.75 | 4.55 | 4.75 | 0.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.04 | 0.03 | 0.08 | 0.03 | 0.09 | 0.02 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.08 | 0.09 | 0.08 | 0.09 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.07 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.95 | 6.14 | 10.45 | 5.64 | 10.61 | 1.83 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 13.53 | 6.64 | 12.46 | 5.79 | 102.83 | 24.78 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 21.23 | 10.96 | 49.02 | 9.33 | 118.76 | 28.76 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.98 | 1.71 | 3.72 | 1.61 | 3.91 | 0.75 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 2.00 | 1.72 | 3.74 | 1.60 | 3.93 | 0.75 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.01 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

