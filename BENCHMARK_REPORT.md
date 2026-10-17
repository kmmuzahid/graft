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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.11 | 0.08 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.13 | 0.13 | 0.16 | 0.12 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.13 | 0.15 | 0.13 | 0.20 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.17 | 0.13 | 0.15 | 0.12 | 0.66 | 0.14 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.79 | 0.79 | 0.84 | 0.73 | 0.88 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.61 | 2.44 | 2.99 | 2.39 | 3.94 | 0.41 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.38 | 3.52 | 6.22 | 3.40 | 8.38 | 1.42 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.63 | 0.63 | 0.64 | 0.60 | 0.68 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.29 | 1.29 | 1.34 | 1.19 | 1.35 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.39 | 1.39 | 1.41 | 1.35 | 1.48 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.97 | 3.46 | 7.76 | 1.24 | 10.22 | 2.58 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 4.72 | 4.72 | 4.79 | 4.66 | 4.80 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.24 | 7.23 | 7.34 | 7.12 | 7.39 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.36 | 23.37 | 23.46 | 23.17 | 23.55 | 0.10 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.19 | 0.14 | 0.28 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.39 | 0.39 | 0.41 | 0.35 | 0.41 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.43 | 0.19 | 1.24 | 0.18 | 2.73 | 0.69 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.59 | 0.58 | 0.63 | 0.54 | 0.70 | 0.04 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.84 | 0.84 | 0.89 | 0.78 | 0.90 | 0.04 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.93 | 8.92 | 9.01 | 8.80 | 9.04 | 0.07 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.02 | 0.01 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.09 | 0.09 | 0.13 | 0.08 | 0.14 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.17 | 0.16 | 0.22 | 0.06 | 0.34 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.41 | 0.44 | 0.39 | 0.44 | 0.02 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.62 | 0.55 | 0.59 | 0.50 | 1.68 | 0.29 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.78 | 0.70 | 0.79 | 0.65 | 1.73 | 0.27 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.80 | 0.68 | 0.93 | 0.60 | 1.88 | 0.32 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 15.70 | 14.69 | 18.35 | 13.94 | 21.05 | 1.99 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 15.79 | 15.50 | 18.36 | 13.27 | 20.37 | 1.87 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 19.71 | 19.59 | 20.83 | 16.82 | 24.13 | 1.54 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 24.83 | 17.65 | 37.00 | 14.72 | 75.07 | 15.76 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 26.22 | 22.35 | 37.59 | 18.18 | 56.16 | 10.11 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 26.36 | 23.12 | 37.87 | 18.36 | 46.94 | 8.21 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 28.45 | 28.48 | 35.49 | 20.66 | 47.92 | 6.69 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 31.19 | 31.38 | 38.40 | 23.51 | 45.78 | 5.73 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 25.70 | 25.29 | 26.83 | 24.76 | 27.68 | 0.93 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 26.41 | 25.79 | 27.87 | 24.88 | 29.20 | 1.28 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 26.48 | 25.92 | 28.24 | 24.39 | 30.71 | 1.65 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 27.62 | 27.36 | 29.95 | 25.89 | 30.27 | 1.32 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 27.64 | 26.86 | 29.80 | 26.19 | 30.31 | 1.45 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 29.51 | 28.51 | 31.01 | 26.01 | 48.33 | 5.39 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 30.18 | 27.77 | 42.74 | 22.94 | 43.74 | 6.54 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 32.41 | 31.84 | 35.34 | 28.94 | 48.49 | 4.75 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.77 | 28.22 | 32.45 | 27.09 | 40.20 | 3.33 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 30.21 | 29.02 | 30.26 | 28.41 | 45.26 | 4.20 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 31.11 | 30.24 | 32.23 | 29.32 | 40.49 | 2.72 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 51.47 | 46.70 | 59.21 | 43.47 | 110.87 | 16.81 | 300 | 0 | 300 |
| 5 | **Provider** | 58.54 | 57.02 | 64.18 | 54.94 | 73.54 | 4.82 | 300 | 0 | 300 |
| 6 | **GetX** | 63.03 | 63.30 | 63.80 | 61.24 | 65.99 | 1.17 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.82 | 29.12 | 31.59 | 28.86 | 34.49 | 1.55 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 39.97 | 35.70 | 61.09 | 32.10 | 61.98 | 10.51 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.24 | 43.20 | 46.31 | 42.33 | 66.57 | 6.01 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 59.85 | 60.01 | 60.47 | 56.97 | 62.69 | 1.31 | 300 | 0 | 300 |
| 5 | **GetX** | 72.66 | 71.18 | 72.16 | 67.13 | 99.98 | 7.69 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 76.30 | 74.37 | 78.08 | 70.56 | 103.49 | 7.78 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.29 | 0.29 | 0.32 | 0.26 | 0.33 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.88 | 0.87 | 0.92 | 0.84 | 0.92 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.88 | 0.47 | 3.39 | 0.43 | 3.71 | 1.09 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.10 | 0.49 | 3.64 | 0.43 | 3.65 | 1.31 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.43 | 0.52 | 4.52 | 0.47 | 5.83 | 1.83 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.04 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.06 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.06 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥉 | **Signals** | 0.07 | 0.06 | 0.07 | 0.06 | 0.14 | 0.02 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.43 | 2.40 | 2.66 | 2.19 | 2.80 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.41 | 2.85 | 4.53 | 2.69 | 5.48 | 0.93 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.36 | 5.23 | 6.16 | 4.62 | 6.83 | 0.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.89 | 0.83 | 0.99 | 0.75 | 1.45 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.95 | 0.89 | 1.10 | 0.80 | 1.58 | 0.20 | 0 | 0 | 0 (Zero-GC) |

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

