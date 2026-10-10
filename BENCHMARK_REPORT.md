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
| 🥇 | **Provider** | 0.20 | 0.14 | 0.43 | 0.14 | 0.56 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.42 | 0.13 | 1.55 | 0.13 | 3.07 | 0.82 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.08 | 0.84 | 2.41 | 0.13 | 5.29 | 1.30 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 1.29 | 0.55 | 5.62 | 0.32 | 5.78 | 1.82 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 1.55 | 1.05 | 1.76 | 0.53 | 8.00 | 1.82 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 2.24 | 1.39 | 5.59 | 0.89 | 11.13 | 2.71 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 4.65 | 3.02 | 4.22 | 2.42 | 26.75 | 6.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 1.38 | 1.37 | 1.44 | 1.31 | 1.68 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.40 | 1.40 | 1.46 | 1.32 | 1.50 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 3.71 | 3.17 | 3.88 | 2.81 | 11.00 | 2.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.81 | 3.67 | 9.28 | 1.25 | 9.42 | 3.09 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 7.70 | 7.56 | 9.11 | 6.58 | 9.71 | 0.89 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 13.00 | 13.31 | 15.23 | 9.51 | 16.11 | 1.81 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 28.28 | 27.14 | 31.68 | 25.29 | 40.93 | 3.88 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.36 | 0.36 | 0.71 | 0.15 | 0.77 | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.39 | 0.21 | 1.03 | 0.19 | 2.13 | 0.53 | 0 | 0 | 10000 |
| 🥉 | **GetX** | 0.47 | 0.41 | 0.74 | 0.38 | 0.78 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.88 | 0.62 | 1.04 | 0.60 | 3.97 | 0.86 | 0 | 0 | 10000 |
| 5 | **Graft** | 1.08 | 0.50 | 3.26 | 0.48 | 6.24 | 1.59 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.36 | 1.05 | 2.02 | 0.99 | 4.80 | 0.98 | 0 | 0 | 10000 |
| 7 | **Signals** | 10.91 | 10.51 | 14.60 | 8.46 | 14.64 | 1.85 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.03 | 0.02 | 0.04 | 0.02 | 0.09 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.09 | 0.05 | 0.10 | 0.04 | 0.49 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.41 | 0.31 | 0.53 | 0.24 | 1.71 | 0.37 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.46 | 0.43 | 0.52 | 0.41 | 0.55 | 0.04 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.69 | 0.62 | 1.04 | 0.50 | 1.53 | 0.27 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.83 | 0.73 | 1.25 | 0.66 | 1.36 | 0.22 | 0 | 0 | 8000 |
| 7 | **Graft** | 1.09 | 0.80 | 2.43 | 0.49 | 2.48 | 0.70 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 2.11 | 1.96 | 2.81 | 1.46 | 3.38 | 0.57 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 18.10 | 16.33 | 24.79 | 13.64 | 33.74 | 5.16 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 26.77 | 26.32 | 33.80 | 19.43 | 33.94 | 4.91 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 27.83 | 28.51 | 32.27 | 17.40 | 34.18 | 4.41 | 120 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 28.25 | 25.96 | 31.72 | 20.00 | 65.38 | 11.03 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 32.90 | 31.63 | 41.47 | 24.95 | 41.56 | 5.25 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 53.96 | 37.99 | 62.34 | 26.04 | 226.35 | 48.67 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 66.54 | 68.75 | 83.25 | 47.19 | 86.71 | 12.30 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.50 | 1.35 | 2.34 | 1.31 | 2.38 | 0.35 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 22.29 | 22.13 | 23.18 | 21.12 | 24.59 | 0.86 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 22.86 | 22.61 | 23.83 | 22.06 | 24.16 | 0.60 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 23.91 | 23.44 | 26.04 | 22.22 | 29.51 | 1.86 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 24.89 | 24.32 | 30.34 | 21.43 | 31.04 | 3.11 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 25.91 | 24.53 | 32.01 | 21.70 | 32.11 | 3.64 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 35.56 | 32.24 | 48.04 | 26.94 | 49.50 | 7.50 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 40.66 | 36.85 | 53.05 | 27.34 | 57.65 | 9.52 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.14 | 3.56 | 5.64 | 3.39 | 5.67 | 0.94 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 12.92 | 11.45 | 15.63 | 10.82 | 25.76 | 3.83 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 39.29 | 38.36 | 44.34 | 34.56 | 54.59 | 5.07 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 47.45 | 46.47 | 47.88 | 44.77 | 63.26 | 4.47 | 300 | 0 | 300 |
| 5 | **Provider** | 56.35 | 56.12 | 60.06 | 53.87 | 60.09 | 2.03 | 300 | 0 | 300 |
| 6 | **GetX** | 63.54 | 63.52 | 64.98 | 61.73 | 65.20 | 1.04 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 6.98 | 3.75 | 12.25 | 3.39 | 26.96 | 6.12 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 31.71 | 30.14 | 37.56 | 28.45 | 44.47 | 4.34 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.13 | 43.39 | 46.14 | 41.41 | 66.24 | 6.04 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.14 | 59.37 | 65.87 | 57.35 | 79.25 | 5.47 | 300 | 0 | 300 |
| 5 | **GetX** | 71.21 | 70.20 | 76.39 | 64.61 | 91.57 | 6.62 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 74.00 | 71.40 | 86.13 | 66.91 | 94.02 | 7.33 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.79 | 0.46 | 2.88 | 0.41 | 2.94 | 0.86 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 0.85 | 0.52 | 2.91 | 0.46 | 3.16 | 0.89 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.98 | 0.84 | 0.88 | 0.79 | 2.91 | 0.54 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.99 | 0.50 | 3.01 | 0.46 | 3.11 | 1.02 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 1.28 | 0.71 | 3.44 | 0.65 | 3.44 | 1.10 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.05 | 0.02 | 0.03 | 0.02 | 0.43 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.05 | 0.03 | 0.03 | 0.03 | 0.43 | 0.10 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.10 | 0.06 | 0.10 | 0.06 | 0.62 | 0.14 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.07 | 0.06 | 0.07 | 0.06 | 0.17 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.07 | 0.06 | 0.06 | 0.06 | 0.29 | 0.06 | 0 | 0 | 100 |
| 🥉 | **Graft** | 0.12 | 0.10 | 0.13 | 0.10 | 0.34 | 0.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 9.28 | 6.76 | 15.90 | 5.72 | 30.66 | 6.49 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 12.19 | 7.73 | 14.63 | 6.38 | 60.93 | 13.73 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 9.23 | 7.60 | 14.98 | 6.54 | 15.24 | 2.99 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.14 | 1.02 | 1.40 | 0.91 | 2.61 | 0.42 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.58 | 1.15 | 3.14 | 0.97 | 3.94 | 0.88 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.02 | 0.00 | 0.01 | 0.00 | 0.23 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.08 | 0.01 | 0.02 | 0.01 | 1.06 | 0.27 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

