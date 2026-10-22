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
| 🥇 | **Graft** | 0.10 | 0.10 | 0.11 | 0.09 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.13 | 0.13 | 0.13 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.14 | 0.14 | 0.15 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 0.14 | 0.13 | 0.16 | 0.12 | 0.19 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.80 | 0.79 | 0.85 | 0.75 | 0.88 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 0.82 | 0.57 | 1.19 | 0.53 | 3.71 | 0.82 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.43 | 2.42 | 2.49 | 2.36 | 2.52 | 0.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.68 | 0.69 | 0.72 | 0.63 | 0.72 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.33 | 1.32 | 1.39 | 1.26 | 1.46 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.44 | 1.43 | 1.48 | 1.39 | 1.50 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.96 | 3.27 | 8.06 | 1.23 | 8.79 | 2.53 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 6.76 | 5.70 | 10.56 | 5.07 | 11.37 | 2.00 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.63 | 7.55 | 7.87 | 7.43 | 7.88 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.79 | 23.66 | 24.60 | 23.45 | 24.77 | 0.38 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.15 | 0.17 | 0.14 | 0.20 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.37 | 0.38 | 0.39 | 0.35 | 0.40 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.60 | 0.58 | 0.68 | 0.55 | 0.74 | 0.05 | 0 | 0 | 10000 |
| 5 | **BLoC (Cubit)** | 0.66 | 0.20 | 2.70 | 0.18 | 4.68 | 1.28 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.85 | 0.83 | 0.90 | 0.79 | 0.94 | 0.04 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.90 | 8.88 | 9.00 | 8.79 | 9.01 | 0.07 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.11 | 0.09 | 0.19 | 0.08 | 0.20 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.17 | 0.17 | 0.20 | 0.14 | 0.25 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.41 | 0.40 | 0.43 | 0.37 | 0.43 | 0.02 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.55 | 0.55 | 0.59 | 0.50 | 0.60 | 0.03 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.69 | 0.68 | 0.76 | 0.64 | 0.78 | 0.04 | 0 | 0 | 8000 |
| 7 | **Signals** | 1.12 | 0.68 | 1.76 | 0.64 | 6.18 | 1.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 12.70 | 12.63 | 13.22 | 11.90 | 13.80 | 0.43 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 13.15 | 13.23 | 13.46 | 12.19 | 13.51 | 0.35 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (slots)** | 13.31 | 13.13 | 13.86 | 12.78 | 14.20 | 0.44 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 13.59 | 12.96 | 13.90 | 12.27 | 23.04 | 2.65 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 14.58 | 14.49 | 15.28 | 13.44 | 15.94 | 0.54 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 15.08 | 14.87 | 16.61 | 13.79 | 17.39 | 0.98 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 15.16 | 12.95 | 18.75 | 12.11 | 29.45 | 4.62 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Signals** | 16.65 | 15.74 | 20.66 | 13.35 | 23.91 | 3.11 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 23.08 | 22.73 | 24.20 | 21.70 | 26.16 | 1.06 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 23.87 | 23.17 | 25.79 | 22.88 | 25.90 | 1.13 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 23.95 | 23.18 | 25.91 | 22.76 | 26.40 | 1.34 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 24.97 | 24.77 | 26.21 | 23.87 | 26.24 | 0.88 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 25.57 | 25.21 | 27.12 | 24.53 | 27.24 | 0.96 | 120 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 25.66 | 25.71 | 27.82 | 23.90 | 28.25 | 1.41 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 25.67 | 24.41 | 27.07 | 22.94 | 40.26 | 4.24 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 25.79 | 25.06 | 29.13 | 23.63 | 36.44 | 3.30 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.74 | 27.81 | 28.96 | 26.88 | 41.54 | 3.60 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.71 | 29.47 | 31.98 | 28.66 | 42.02 | 3.32 | 300 | 0 | 300 |
| 🥉 | **Signals** | 31.39 | 30.75 | 34.96 | 28.76 | 44.25 | 3.91 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 45.78 | 43.91 | 51.05 | 42.28 | 56.04 | 4.09 | 300 | 0 | 300 |
| 5 | **Provider** | 55.02 | 55.23 | 56.14 | 53.57 | 56.77 | 0.98 | 300 | 0 | 300 |
| 6 | **GetX** | 62.17 | 61.65 | 65.23 | 59.85 | 66.17 | 1.60 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.66 | 29.22 | 31.87 | 28.31 | 33.56 | 1.44 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 40.20 | 36.54 | 60.33 | 32.67 | 65.03 | 9.81 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 44.25 | 42.38 | 49.18 | 40.97 | 67.14 | 6.67 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 67.41 | 60.53 | 84.47 | 59.41 | 126.86 | 17.75 | 300 | 0 | 300 |
| 5 | **Provider** | 72.96 | 70.83 | 73.06 | 67.97 | 101.98 | 8.12 | 300 | 0 | 300 |
| 6 | **GetX** | 92.72 | 75.96 | 133.21 | 69.83 | 251.77 | 47.22 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.33 | 0.35 | 0.31 | 0.36 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.85 | 0.86 | 0.88 | 0.80 | 0.90 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.88 | 0.48 | 3.45 | 0.43 | 3.67 | 1.09 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 0.96 | 0.45 | 3.04 | 0.40 | 3.20 | 1.08 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.37 | 0.54 | 3.87 | 0.46 | 5.92 | 1.69 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.02 | 0.02 | 0.03 | 0.02 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.04 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.05 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.09 | 0.06 | 0.06 | 0.05 | 0.56 | 0.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.45 | 2.43 | 2.76 | 2.18 | 2.83 | 0.21 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.24 | 2.77 | 5.08 | 2.61 | 5.42 | 0.94 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.04 | 4.90 | 5.65 | 4.46 | 6.22 | 0.44 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.83 | 0.82 | 0.87 | 0.76 | 1.08 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.91 | 0.88 | 1.10 | 0.79 | 1.15 | 0.10 | 0 | 0 | 0 (Zero-GC) |

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

