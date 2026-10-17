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
| 🥇 | **Graft** | 0.10 | 0.10 | 0.11 | 0.09 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.13 | 0.13 | 0.14 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.14 | 0.16 | 0.12 | 0.21 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.18 | 0.14 | 0.16 | 0.12 | 0.77 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.75 | 0.74 | 0.81 | 0.70 | 0.86 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.44 | 2.44 | 2.50 | 2.38 | 2.53 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.17 | 3.50 | 5.26 | 3.39 | 6.36 | 0.98 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.63 | 0.63 | 0.66 | 0.59 | 0.68 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.39 | 1.40 | 1.41 | 1.33 | 1.47 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.49 | 1.48 | 1.53 | 1.42 | 1.62 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.96 | 3.20 | 8.95 | 1.22 | 10.23 | 3.04 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 4.80 | 4.79 | 4.84 | 4.76 | 4.87 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.12 | 7.11 | 7.19 | 7.01 | 7.21 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.07 | 24.18 | 24.81 | 23.22 | 24.81 | 0.60 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.13 | 0.12 | 0.13 | 0.12 | 0.14 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.16 | 0.16 | 0.15 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.39 | 0.39 | 0.40 | 0.38 | 0.41 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.48 | 0.20 | 1.58 | 0.20 | 2.93 | 0.77 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.60 | 0.72 | 0.58 | 0.78 | 0.05 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.88 | 0.87 | 0.92 | 0.84 | 0.98 | 0.04 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.11 | 9.10 | 9.18 | 9.03 | 9.24 | 0.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.03 | 0.01 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.05 | 0.01 | 0.15 | 0.01 | 0.16 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.07 | 0.06 | 0.16 | 0.01 | 0.22 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.45 | 0.45 | 0.47 | 0.42 | 0.47 | 0.02 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.67 | 0.59 | 0.65 | 0.54 | 1.84 | 0.33 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.85 | 0.76 | 0.86 | 0.69 | 1.96 | 0.31 | 0 | 0 | 8000 |
| 7 | **Signals** | 1.18 | 0.73 | 0.92 | 0.61 | 7.44 | 1.73 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 17.90 | 16.10 | 26.80 | 14.49 | 30.25 | 4.52 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 21.56 | 18.42 | 37.08 | 15.69 | 41.91 | 7.82 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 24.17 | 19.16 | 60.24 | 14.50 | 64.98 | 15.76 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 24.66 | 24.34 | 28.29 | 21.50 | 32.10 | 2.99 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Graft (leaf slot)** | 25.85 | 25.01 | 31.20 | 19.27 | 35.40 | 4.30 | 120 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 26.86 | 26.37 | 32.03 | 19.66 | 37.75 | 4.51 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 27.60 | 24.27 | 37.30 | 17.18 | 61.30 | 10.75 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 27.93 | 26.91 | 34.75 | 22.57 | 38.95 | 4.85 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 24.59 | 24.31 | 25.66 | 23.55 | 26.15 | 0.81 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 25.90 | 25.20 | 27.67 | 24.17 | 28.44 | 1.41 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (leaf slot)** | 25.98 | 24.60 | 31.97 | 23.80 | 32.16 | 2.76 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 26.13 | 24.51 | 26.27 | 23.64 | 45.89 | 5.53 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 26.72 | 26.32 | 28.60 | 25.23 | 28.72 | 1.20 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 26.82 | 26.75 | 28.68 | 24.79 | 29.18 | 1.19 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 29.19 | 27.81 | 29.86 | 26.24 | 47.48 | 5.18 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Provider** | 32.23 | 31.47 | 35.71 | 28.64 | 47.03 | 4.51 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.40 | 27.09 | 30.88 | 26.12 | 41.11 | 3.71 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.96 | 29.62 | 34.37 | 28.61 | 39.60 | 3.02 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.70 | 29.71 | 47.29 | 28.77 | 55.42 | 7.79 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 44.82 | 43.72 | 49.25 | 42.12 | 56.78 | 3.72 | 300 | 0 | 300 |
| 5 | **Provider** | 56.22 | 56.07 | 59.19 | 53.18 | 59.29 | 2.08 | 300 | 0 | 300 |
| 6 | **GetX** | 73.18 | 63.59 | 80.08 | 60.90 | 177.91 | 29.43 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 31.38 | 31.10 | 34.56 | 28.76 | 34.73 | 2.15 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 37.80 | 35.52 | 59.95 | 32.02 | 60.35 | 9.20 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 50.90 | 49.04 | 51.68 | 42.58 | 98.28 | 13.57 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.79 | 59.94 | 61.91 | 59.00 | 83.75 | 6.14 | 300 | 0 | 300 |
| 5 | **Provider** | 73.86 | 71.94 | 78.06 | 67.88 | 101.92 | 8.14 | 300 | 0 | 300 |
| 6 | **GetX** | 74.33 | 73.31 | 78.33 | 67.00 | 102.63 | 8.44 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.29 | 0.28 | 0.32 | 0.28 | 0.33 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.84 | 0.85 | 0.88 | 0.79 | 0.89 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.96 | 0.48 | 4.02 | 0.45 | 4.12 | 1.27 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.01 | 0.43 | 3.30 | 0.40 | 3.55 | 1.22 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 1.04 | 0.45 | 3.41 | 0.41 | 3.58 | 1.24 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.04 | 0.02 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.09 | 0.06 | 0.08 | 0.05 | 0.46 | 0.10 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.94 | 2.72 | 4.01 | 2.13 | 4.26 | 0.61 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.42 | 2.81 | 5.29 | 2.62 | 6.15 | 1.09 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.12 | 5.02 | 5.78 | 4.43 | 5.79 | 0.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.83 | 0.82 | 0.85 | 0.76 | 0.93 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.95 | 0.89 | 1.13 | 0.83 | 1.24 | 0.12 | 0 | 0 | 0 (Zero-GC) |

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

