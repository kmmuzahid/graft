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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.10 | 0.08 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.13 | 0.13 | 0.15 | 0.12 | 0.19 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.18 | 0.18 | 0.20 | 0.16 | 0.21 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.24 | 0.13 | 0.15 | 0.12 | 1.80 | 0.43 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.89 | 0.64 | 1.33 | 0.59 | 3.73 | 0.81 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 0.92 | 0.91 | 0.98 | 0.88 | 1.02 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.46 | 2.46 | 2.56 | 2.39 | 2.56 | 0.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.68 | 0.68 | 0.70 | 0.64 | 0.71 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.30 | 1.29 | 1.37 | 1.23 | 1.40 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.85 | 1.86 | 1.88 | 1.82 | 1.89 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.90 | 3.95 | 6.46 | 1.25 | 9.65 | 2.35 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.84 | 5.84 | 5.91 | 5.74 | 6.06 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 9.35 | 9.35 | 9.72 | 9.04 | 9.79 | 0.25 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.90 | 24.70 | 26.33 | 23.62 | 27.88 | 1.19 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.18 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.18 | 0.14 | 0.26 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.52 | 0.48 | 0.56 | 0.47 | 0.99 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.56 | 0.21 | 2.55 | 0.19 | 3.10 | 0.93 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.68 | 0.67 | 0.70 | 0.64 | 0.82 | 0.04 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.01 | 0.99 | 1.11 | 0.93 | 1.16 | 0.06 | 0 | 0 | 10000 |
| 7 | **Signals** | 10.41 | 10.00 | 12.60 | 9.22 | 14.60 | 1.45 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.02 | 0.01 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.10 | 0.10 | 0.14 | 0.09 | 0.18 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.19 | 0.17 | 0.30 | 0.14 | 0.37 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.42 | 0.44 | 0.40 | 0.46 | 0.02 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.65 | 0.57 | 0.64 | 0.53 | 1.69 | 0.29 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.74 | 0.68 | 0.71 | 0.63 | 1.64 | 0.25 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.80 | 0.66 | 0.69 | 0.64 | 2.80 | 0.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 13.47 | 13.25 | 14.16 | 12.52 | 14.36 | 0.62 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 15.04 | 14.97 | 16.39 | 13.77 | 16.52 | 0.84 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 15.77 | 15.72 | 17.66 | 14.23 | 18.79 | 1.31 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (leaf slot)** | 16.00 | 15.55 | 19.17 | 13.19 | 22.35 | 2.45 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Graft (slots)** | 20.29 | 19.08 | 24.26 | 17.51 | 30.07 | 3.48 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 22.95 | 21.85 | 32.08 | 17.20 | 35.41 | 4.99 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 23.30 | 21.33 | 32.44 | 16.76 | 35.93 | 5.25 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 24.13 | 22.05 | 34.14 | 16.49 | 42.42 | 7.08 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 25.10 | 24.97 | 26.29 | 24.14 | 26.34 | 0.69 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 26.64 | 26.27 | 28.08 | 25.55 | 29.25 | 1.12 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 27.09 | 24.96 | 33.30 | 24.50 | 38.77 | 4.28 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 27.68 | 27.76 | 29.08 | 25.63 | 31.23 | 1.52 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Graft (slots)** | 28.05 | 27.35 | 32.52 | 24.84 | 34.08 | 2.82 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 28.95 | 28.84 | 31.77 | 25.78 | 32.12 | 1.86 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 29.64 | 29.43 | 31.39 | 27.86 | 32.27 | 1.31 | 120 | 0 | 0 (Zero-GC) |
| 8 | **GetX** | 32.84 | 32.51 | 39.42 | 26.31 | 42.30 | 5.28 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.83 | 30.93 | 38.93 | 28.58 | 53.46 | 6.31 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 35.98 | 35.48 | 42.56 | 31.01 | 53.30 | 5.74 | 300 | 0 | 300 |
| 🥉 | **Signals** | 37.85 | 35.83 | 43.65 | 33.82 | 54.25 | 5.08 | 300 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 61.70 | 59.88 | 69.02 | 57.02 | 78.63 | 5.66 | 300 | 0 | 300 |
| 5 | **BLoC (Cubit)** | 76.67 | 79.97 | 93.71 | 54.09 | 100.83 | 12.43 | 300 | 0 | 300 |
| 6 | **GetX** | 83.93 | 80.26 | 109.32 | 68.83 | 119.08 | 14.10 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 41.49 | 35.70 | 52.03 | 31.70 | 111.88 | 20.04 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 45.33 | 38.96 | 66.02 | 34.78 | 76.04 | 12.56 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 48.95 | 47.55 | 51.80 | 44.36 | 69.42 | 6.06 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 66.32 | 65.31 | 67.32 | 61.80 | 86.80 | 5.90 | 300 | 0 | 300 |
| 5 | **GetX** | 82.43 | 81.63 | 92.23 | 71.01 | 110.35 | 10.47 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 87.04 | 85.21 | 87.19 | 81.15 | 119.71 | 9.24 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.30 | 0.30 | 0.32 | 0.28 | 0.34 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 0.88 | 0.43 | 3.68 | 0.40 | 3.93 | 1.19 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.97 | 0.97 | 0.98 | 0.94 | 0.98 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.10 | 0.44 | 3.67 | 0.42 | 3.99 | 1.36 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.57 | 0.49 | 5.48 | 0.46 | 6.97 | 2.28 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.02 | 0.05 | 0.01 | 0 | 0 | 40 |
| 🥉 | **Signals** | 0.03 | 0.02 | 0.03 | 0.02 | 0.21 | 0.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.05 | 0.08 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.08 | 0.06 | 0.09 | 0.05 | 0.36 | 0.08 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.89 | 2.77 | 3.52 | 2.26 | 3.85 | 0.46 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.37 | 2.83 | 5.00 | 2.78 | 5.44 | 0.91 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.33 | 5.16 | 5.79 | 4.72 | 6.83 | 0.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.85 | 0.84 | 0.91 | 0.77 | 1.12 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.95 | 0.92 | 1.16 | 0.84 | 1.17 | 0.11 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.01 | 0.00 | 0.01 | 0.00 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

