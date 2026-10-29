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
| 🥇 | **Graft** | 0.10 | 0.09 | 0.11 | 0.09 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.13 | 0.13 | 0.16 | 0.12 | 0.19 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.14 | 0.14 | 0.15 | 0.13 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.18 | 0.13 | 0.15 | 0.12 | 0.86 | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.75 | 0.75 | 0.78 | 0.71 | 0.83 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 0.77 | 0.55 | 1.01 | 0.51 | 3.42 | 0.74 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.47 | 2.46 | 2.53 | 2.40 | 2.60 | 0.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.68 | 0.69 | 0.70 | 0.63 | 0.75 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.30 | 1.29 | 1.35 | 1.25 | 1.36 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.40 | 1.39 | 1.44 | 1.35 | 1.45 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.95 | 3.25 | 9.83 | 1.26 | 10.44 | 3.09 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 4.94 | 4.93 | 5.03 | 4.86 | 5.05 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.30 | 7.29 | 7.40 | 7.19 | 7.41 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 24.01 | 23.95 | 24.78 | 23.47 | 25.19 | 0.47 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.18 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.39 | 0.39 | 0.41 | 0.37 | 0.42 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.49 | 0.21 | 1.71 | 0.19 | 2.98 | 0.79 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.58 | 0.57 | 0.64 | 0.53 | 0.64 | 0.04 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.83 | 0.80 | 0.90 | 0.77 | 1.04 | 0.07 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.92 | 8.93 | 9.02 | 8.76 | 9.03 | 0.08 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.02 | 0.01 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.09 | 0.09 | 0.10 | 0.08 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.18 | 0.17 | 0.22 | 0.15 | 0.27 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.44 | 0.43 | 0.50 | 0.40 | 0.53 | 0.03 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.59 | 0.63 | 0.56 | 1.23 | 0.17 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.83 | 0.77 | 0.80 | 0.67 | 2.04 | 0.34 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.93 | 0.68 | 1.68 | 0.64 | 3.20 | 0.68 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 14.41 | 14.52 | 14.93 | 13.09 | 16.17 | 0.75 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 16.36 | 15.45 | 17.84 | 14.47 | 25.71 | 2.80 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 16.65 | 16.70 | 17.63 | 14.97 | 18.39 | 0.98 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (leaf slot)** | 17.10 | 15.42 | 20.26 | 14.39 | 32.27 | 4.54 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 21.32 | 16.60 | 35.90 | 13.88 | 37.54 | 7.91 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 22.53 | 17.47 | 45.64 | 13.82 | 51.19 | 11.65 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 22.84 | 22.98 | 26.79 | 17.96 | 33.35 | 3.85 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 28.91 | 29.95 | 34.38 | 20.17 | 37.62 | 5.01 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 27.19 | 27.14 | 28.92 | 25.43 | 30.05 | 1.31 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 27.28 | 26.76 | 28.53 | 25.44 | 31.16 | 1.43 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (slots)** | 27.40 | 26.08 | 29.08 | 23.42 | 47.30 | 5.70 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 29.38 | 27.94 | 33.80 | 26.98 | 34.78 | 2.50 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 33.87 | 34.79 | 40.76 | 27.17 | 47.37 | 5.97 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 33.87 | 32.36 | 43.88 | 28.09 | 46.24 | 5.39 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 35.30 | 33.12 | 45.11 | 27.65 | 50.10 | 6.52 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 39.32 | 35.47 | 62.97 | 29.79 | 68.01 | 11.43 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.67 | 27.66 | 39.51 | 26.36 | 61.54 | 9.11 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 31.10 | 29.49 | 31.78 | 29.00 | 47.38 | 4.60 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 33.74 | 30.90 | 43.57 | 29.25 | 58.40 | 7.74 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 67.53 | 58.19 | 105.52 | 46.37 | 112.43 | 20.10 | 300 | 0 | 300 |
| 5 | **GetX** | 71.15 | 71.61 | 89.56 | 60.29 | 91.54 | 9.11 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 82.10 | 76.53 | 108.31 | 66.26 | 115.36 | 17.10 | 300 | 0 | 300 |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 35.56 | 34.00 | 38.79 | 33.29 | 40.13 | 2.51 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 38.60 | 35.27 | 60.08 | 32.03 | 61.84 | 9.73 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 47.77 | 45.55 | 52.01 | 42.55 | 76.25 | 8.27 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.80 | 61.34 | 63.51 | 55.53 | 86.34 | 7.20 | 300 | 0 | 300 |
| 5 | **GetX** | 72.95 | 71.32 | 72.69 | 69.00 | 99.76 | 7.49 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 75.10 | 74.52 | 76.45 | 68.44 | 102.74 | 8.05 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.33 | 0.32 | 0.34 | 0.30 | 0.34 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.85 | 0.86 | 0.88 | 0.80 | 0.91 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.90 | 0.45 | 3.75 | 0.41 | 4.02 | 1.21 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 1.12 | 0.46 | 3.83 | 0.42 | 3.90 | 1.39 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.14 | 0.52 | 4.57 | 0.47 | 5.74 | 1.65 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.05 | 0.05 | 0.05 | 0.04 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.12 | 0.02 | 0.12 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.07 | 0.06 | 0.08 | 0.04 | 0.13 | 0.02 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.08 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.12 | 0.08 | 0.20 | 0.06 | 0.44 | 0.10 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.94 | 2.77 | 4.46 | 2.20 | 4.51 | 0.74 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 4.92 | 4.50 | 7.42 | 2.68 | 12.08 | 2.39 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.02 | 4.97 | 5.73 | 4.38 | 5.83 | 0.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.86 | 0.82 | 0.97 | 0.77 | 1.23 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.98 | 0.91 | 1.40 | 0.80 | 1.51 | 0.21 | 0 | 0 | 0 (Zero-GC) |

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

