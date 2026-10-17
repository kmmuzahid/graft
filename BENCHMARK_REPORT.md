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
| 🥇 | **Graft** | 0.10 | 0.10 | 0.10 | 0.09 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.14 | 0.14 | 0.15 | 0.13 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.15 | 0.14 | 0.16 | 0.14 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.17 | 0.13 | 0.15 | 0.12 | 0.67 | 0.14 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.83 | 0.82 | 0.88 | 0.79 | 0.90 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.45 | 2.46 | 2.49 | 2.38 | 2.50 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.42 | 3.62 | 5.43 | 3.54 | 8.17 | 1.29 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.66 | 0.67 | 0.68 | 0.63 | 0.69 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.28 | 1.28 | 1.31 | 1.24 | 1.33 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.45 | 1.44 | 1.48 | 1.41 | 1.49 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.33 | 3.66 | 7.48 | 1.25 | 12.10 | 2.84 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.08 | 5.08 | 5.12 | 5.01 | 5.14 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.59 | 7.57 | 7.71 | 7.48 | 7.76 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.72 | 23.72 | 23.90 | 23.51 | 24.02 | 0.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.13 | 0.12 | 0.13 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.40 | 0.39 | 0.43 | 0.38 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.45 | 0.20 | 1.28 | 0.20 | 2.83 | 0.71 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.67 | 0.66 | 0.75 | 0.59 | 0.81 | 0.06 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.88 | 0.87 | 0.93 | 0.84 | 0.96 | 0.03 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.14 | 9.07 | 9.33 | 8.94 | 9.46 | 0.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.10 | 0.09 | 0.12 | 0.09 | 0.18 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.18 | 0.16 | 0.25 | 0.14 | 0.32 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.41 | 0.44 | 0.40 | 0.45 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.56 | 0.62 | 0.53 | 1.63 | 0.28 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.79 | 0.70 | 0.81 | 0.68 | 1.74 | 0.26 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.79 | 0.68 | 1.00 | 0.65 | 1.88 | 0.32 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 16.06 | 15.91 | 17.14 | 14.97 | 17.88 | 0.81 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 23.36 | 21.64 | 30.25 | 18.81 | 32.30 | 3.97 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 25.03 | 20.61 | 34.66 | 18.10 | 45.56 | 8.00 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 26.57 | 26.55 | 32.17 | 21.05 | 33.42 | 3.34 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 27.64 | 25.75 | 37.23 | 22.23 | 43.53 | 5.91 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 27.91 | 28.59 | 31.37 | 21.73 | 38.26 | 4.28 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 28.37 | 28.15 | 34.85 | 23.08 | 37.43 | 4.29 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 31.06 | 31.13 | 38.10 | 21.68 | 52.59 | 7.70 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 24.74 | 24.47 | 26.02 | 23.62 | 26.78 | 0.89 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (leaf slot)** | 24.83 | 24.12 | 27.03 | 23.01 | 27.25 | 1.50 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 25.14 | 24.62 | 26.57 | 24.07 | 26.62 | 0.98 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 26.08 | 25.58 | 27.73 | 24.93 | 28.13 | 1.00 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 26.34 | 25.83 | 28.02 | 24.86 | 28.09 | 1.24 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 26.56 | 25.53 | 27.09 | 24.71 | 40.52 | 3.93 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 27.10 | 26.75 | 29.37 | 25.29 | 30.51 | 1.64 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 27.65 | 26.68 | 28.04 | 25.25 | 44.34 | 4.71 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.99 | 28.18 | 29.50 | 27.28 | 40.11 | 3.14 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.91 | 29.98 | 31.40 | 29.48 | 41.74 | 3.05 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.15 | 29.35 | 45.40 | 28.95 | 47.57 | 6.00 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 45.43 | 44.72 | 46.84 | 43.43 | 55.94 | 3.04 | 300 | 0 | 300 |
| 5 | **Provider** | 56.06 | 56.35 | 56.94 | 54.81 | 57.42 | 0.85 | 300 | 0 | 300 |
| 6 | **GetX** | 63.64 | 62.83 | 66.65 | 61.54 | 67.21 | 1.86 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 31.02 | 30.51 | 32.95 | 29.36 | 35.08 | 1.57 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 40.91 | 37.49 | 62.00 | 33.38 | 62.67 | 9.68 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.30 | 44.18 | 46.72 | 42.15 | 64.21 | 5.44 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 65.40 | 61.20 | 87.11 | 59.93 | 87.36 | 9.20 | 300 | 0 | 300 |
| 5 | **GetX** | 74.77 | 72.93 | 76.13 | 69.18 | 98.33 | 6.71 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 76.56 | 74.29 | 80.49 | 70.74 | 102.34 | 7.56 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.30 | 0.30 | 0.32 | 0.29 | 0.33 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.85 | 0.85 | 0.89 | 0.83 | 0.89 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.87 | 0.47 | 3.42 | 0.40 | 3.63 | 1.08 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.02 | 0.46 | 3.31 | 0.41 | 3.37 | 1.18 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.43 | 0.50 | 4.75 | 0.46 | 5.89 | 1.87 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.03 | 0.02 | 0.04 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.08 | 0.06 | 0.07 | 0.06 | 0.29 | 0.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.54 | 2.48 | 3.01 | 2.23 | 3.27 | 0.28 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.49 | 3.21 | 4.70 | 2.80 | 5.16 | 0.67 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.05 | 5.81 | 7.09 | 5.24 | 8.04 | 0.75 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.92 | 0.87 | 1.12 | 0.78 | 1.18 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.93 | 0.91 | 1.10 | 0.78 | 1.36 | 0.15 | 0 | 0 | 0 (Zero-GC) |

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

