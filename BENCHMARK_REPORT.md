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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.10 | 0.08 | 0.10 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.13 | 0.12 | 0.14 | 0.12 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.13 | 0.13 | 0.15 | 0.12 | 0.19 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.13 | 0.13 | 0.14 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.77 | 0.76 | 0.83 | 0.71 | 0.85 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.55 | 2.45 | 3.21 | 2.33 | 3.33 | 0.30 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.33 | 3.67 | 5.77 | 3.32 | 6.62 | 1.05 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.62 | 0.62 | 0.65 | 0.58 | 0.65 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.26 | 1.27 | 1.31 | 1.18 | 1.31 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.40 | 1.40 | 1.44 | 1.36 | 1.47 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.02 | 3.89 | 8.48 | 1.30 | 9.26 | 2.63 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.00 | 4.97 | 5.18 | 4.84 | 5.18 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.29 | 7.22 | 7.64 | 7.17 | 7.88 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 22.99 | 22.90 | 23.25 | 22.67 | 23.88 | 0.29 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.11 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.15 | 0.14 | 0.17 | 0.14 | 0.25 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.37 | 0.36 | 0.40 | 0.34 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.61 | 0.58 | 0.66 | 0.55 | 0.76 | 0.06 | 0 | 0 | 10000 |
| 5 | **BLoC (Cubit)** | 0.67 | 0.20 | 2.60 | 0.18 | 4.90 | 1.32 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.81 | 0.81 | 0.86 | 0.74 | 0.93 | 0.05 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.74 | 8.74 | 8.87 | 8.56 | 8.92 | 0.11 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.02 | 0.01 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.10 | 0.09 | 0.14 | 0.07 | 0.15 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.18 | 0.15 | 0.25 | 0.14 | 0.36 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.48 | 0.40 | 0.46 | 0.37 | 1.63 | 0.32 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.53 | 0.52 | 0.56 | 0.48 | 0.57 | 0.03 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.69 | 0.69 | 0.77 | 0.63 | 0.80 | 0.05 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.87 | 0.70 | 1.79 | 0.61 | 1.96 | 0.42 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 16.28 | 15.92 | 18.70 | 13.96 | 22.34 | 2.15 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 17.81 | 16.69 | 23.57 | 13.19 | 24.31 | 3.57 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 18.99 | 18.47 | 21.95 | 15.14 | 30.28 | 3.47 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 19.71 | 16.63 | 31.70 | 13.61 | 36.26 | 6.67 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 21.27 | 21.09 | 25.65 | 17.11 | 28.31 | 3.20 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 21.65 | 20.92 | 24.54 | 17.10 | 28.46 | 2.83 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.00 | 22.02 | 26.43 | 16.35 | 37.01 | 4.71 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 26.95 | 27.84 | 33.02 | 18.86 | 35.02 | 5.33 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 24.88 | 24.78 | 26.94 | 23.35 | 27.33 | 1.26 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 24.99 | 24.91 | 26.90 | 22.95 | 27.09 | 1.33 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 25.08 | 24.67 | 26.46 | 24.16 | 26.94 | 0.91 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 26.02 | 25.47 | 28.18 | 24.87 | 28.64 | 1.20 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 26.14 | 25.89 | 27.60 | 24.39 | 29.39 | 1.36 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 26.66 | 26.55 | 31.30 | 22.50 | 31.52 | 2.99 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 26.97 | 25.65 | 27.61 | 24.28 | 43.20 | 4.60 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 27.89 | 26.33 | 29.48 | 23.58 | 50.30 | 6.41 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.62 | 27.99 | 30.53 | 26.42 | 35.47 | 2.32 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.10 | 29.13 | 30.98 | 28.20 | 42.89 | 3.59 | 300 | 0 | 300 |
| 🥉 | **Signals** | 34.92 | 32.57 | 48.14 | 30.43 | 54.02 | 6.78 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 45.94 | 44.70 | 48.94 | 43.42 | 57.98 | 3.63 | 300 | 0 | 300 |
| 5 | **Provider** | 54.27 | 54.73 | 55.06 | 52.90 | 55.59 | 0.91 | 300 | 0 | 300 |
| 6 | **GetX** | 63.69 | 62.50 | 70.36 | 61.48 | 71.79 | 3.08 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.46 | 29.32 | 31.12 | 28.43 | 32.16 | 1.00 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 39.59 | 35.27 | 61.06 | 31.69 | 62.25 | 11.33 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 43.46 | 41.96 | 44.31 | 40.86 | 63.89 | 5.77 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 65.17 | 66.33 | 70.96 | 56.91 | 71.28 | 4.47 | 300 | 0 | 300 |
| 5 | **GetX** | 74.10 | 69.52 | 75.74 | 66.14 | 116.63 | 12.12 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 77.40 | 72.56 | 99.90 | 67.74 | 121.39 | 14.27 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.28 | 0.28 | 0.29 | 0.26 | 0.32 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.80 | 0.43 | 3.16 | 0.40 | 3.23 | 0.98 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.83 | 0.84 | 0.85 | 0.78 | 0.86 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.88 | 0.42 | 3.66 | 0.40 | 4.00 | 1.20 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.25 | 0.47 | 4.36 | 0.42 | 4.81 | 1.63 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.06 | 0.01 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.05 | 0.05 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.08 | 0.05 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.38 | 2.36 | 2.49 | 2.21 | 2.64 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.85 | 3.11 | 7.22 | 2.65 | 7.62 | 1.57 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.60 | 5.63 | 6.24 | 4.72 | 6.93 | 0.58 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.87 | 0.84 | 1.06 | 0.78 | 1.21 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 1.01 | 0.92 | 1.52 | 0.81 | 1.63 | 0.25 | 0 | 0 | 0 (Zero-GC) |

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

