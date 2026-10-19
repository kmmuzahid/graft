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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.10 | 0.08 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.14 | 0.16 | 0.14 | 0.32 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.18 | 0.15 | 0.19 | 0.14 | 0.45 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.21 | 0.14 | 0.16 | 0.14 | 1.15 | 0.26 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.95 | 0.87 | 1.20 | 0.81 | 1.35 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.77 | 2.75 | 2.97 | 2.57 | 3.08 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.03 | 3.57 | 5.18 | 3.51 | 5.42 | 0.72 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.70 | 0.69 | 0.71 | 0.68 | 0.87 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.32 | 1.31 | 1.35 | 1.26 | 1.39 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.48 | 1.48 | 1.51 | 1.44 | 1.52 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.97 | 3.43 | 7.85 | 1.24 | 8.23 | 2.39 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.26 | 5.24 | 5.41 | 5.20 | 5.45 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 8.17 | 8.18 | 8.26 | 7.97 | 8.30 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.53 | 24.15 | 24.54 | 23.54 | 30.58 | 1.70 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.24 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.40 | 0.40 | 0.43 | 0.38 | 0.45 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.49 | 0.20 | 1.69 | 0.19 | 2.97 | 0.79 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.62 | 0.73 | 0.59 | 0.74 | 0.05 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.84 | 0.83 | 0.91 | 0.77 | 0.91 | 0.04 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.04 | 9.03 | 9.09 | 8.94 | 9.11 | 0.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.03 | 0.01 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.08 | 0.08 | 0.09 | 0.07 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.17 | 0.17 | 0.20 | 0.15 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.42 | 0.44 | 0.41 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.65 | 0.56 | 0.64 | 0.53 | 1.76 | 0.31 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.78 | 0.71 | 0.78 | 0.66 | 1.72 | 0.26 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.85 | 0.66 | 0.67 | 0.63 | 3.63 | 0.77 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 17.70 | 14.77 | 25.71 | 13.51 | 26.71 | 4.63 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 19.25 | 18.39 | 22.78 | 15.98 | 29.53 | 3.52 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 21.07 | 19.86 | 28.86 | 14.00 | 29.35 | 5.18 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 24.83 | 23.43 | 31.57 | 18.33 | 35.61 | 4.45 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 25.25 | 23.51 | 33.12 | 16.66 | 44.60 | 6.71 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 27.26 | 25.31 | 35.74 | 19.29 | 37.97 | 6.10 | 120 | 0 | 0 (Zero-GC) |
| 7 | **GetX** | 29.17 | 29.65 | 39.98 | 17.12 | 45.23 | 9.71 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 40.50 | 27.27 | 80.56 | 21.20 | 147.57 | 33.30 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 25.18 | 24.74 | 26.51 | 23.57 | 27.85 | 1.15 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 26.17 | 26.05 | 28.14 | 24.55 | 28.72 | 1.29 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 27.59 | 26.37 | 30.49 | 24.91 | 34.51 | 2.48 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 28.38 | 27.91 | 31.45 | 26.44 | 32.39 | 1.92 | 120 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 28.55 | 26.78 | 30.37 | 24.92 | 47.87 | 5.51 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 28.69 | 28.25 | 30.52 | 26.29 | 30.98 | 1.37 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 31.94 | 27.36 | 52.61 | 24.17 | 53.08 | 10.05 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 48.81 | 45.22 | 60.67 | 35.35 | 90.02 | 13.25 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.95 | 28.75 | 30.83 | 27.31 | 31.19 | 1.20 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 31.38 | 30.64 | 32.40 | 29.29 | 42.57 | 3.20 | 300 | 0 | 300 |
| 🥉 | **Signals** | 34.91 | 33.13 | 48.87 | 28.84 | 55.35 | 7.49 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 47.65 | 45.36 | 51.38 | 43.98 | 70.67 | 6.72 | 300 | 0 | 300 |
| 5 | **Provider** | 58.10 | 57.73 | 60.22 | 55.73 | 61.85 | 1.73 | 300 | 0 | 300 |
| 6 | **GetX** | 77.39 | 70.41 | 106.41 | 65.36 | 116.98 | 15.42 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.60 | 29.99 | 32.07 | 29.52 | 33.80 | 1.18 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 38.95 | 36.55 | 59.55 | 32.89 | 60.45 | 8.84 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 47.72 | 45.91 | 49.22 | 44.38 | 68.33 | 5.85 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.85 | 59.97 | 64.38 | 57.19 | 87.17 | 7.19 | 300 | 0 | 300 |
| 5 | **GetX** | 78.68 | 74.24 | 94.07 | 70.64 | 114.10 | 11.63 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 79.00 | 77.04 | 81.76 | 71.70 | 104.80 | 7.56 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.29 | 0.29 | 0.31 | 0.28 | 0.31 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.86 | 0.85 | 0.89 | 0.83 | 1.00 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.92 | 0.46 | 3.86 | 0.41 | 4.12 | 1.25 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 1.08 | 0.48 | 4.82 | 0.45 | 5.21 | 1.60 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 1.16 | 0.46 | 3.89 | 0.41 | 4.23 | 1.46 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.07 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.05 | 0.03 | 0.03 | 0.03 | 0.29 | 0.07 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.07 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.07 | 0.06 | 0.08 | 0.05 | 0.21 | 0.04 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.58 | 2.47 | 3.10 | 2.27 | 3.35 | 0.31 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 4.04 | 3.31 | 6.03 | 2.72 | 12.48 | 2.46 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.30 | 5.40 | 5.82 | 4.67 | 5.84 | 0.37 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.87 | 0.82 | 0.95 | 0.80 | 1.17 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 1.02 | 0.94 | 1.52 | 0.78 | 1.56 | 0.24 | 0 | 0 | 0 (Zero-GC) |

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

