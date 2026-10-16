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
| 🥇 | **Graft** | 0.13 | 0.12 | 0.22 | 0.08 | 0.23 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.62 | 0.62 | 0.64 | 0.59 | 0.64 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 1.51 | 1.27 | 1.30 | 1.21 | 4.91 | 0.94 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 4.12 | 3.98 | 4.56 | 3.64 | 6.40 | 0.68 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 5.74 | 5.22 | 6.78 | 5.13 | 6.95 | 0.73 | 0 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 6.28 | 1.92 | 1.97 | 1.86 | 67.48 | 16.93 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 7.60 | 6.75 | 9.09 | 6.59 | 9.11 | 1.16 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.31 | 1.31 | 1.37 | 1.22 | 1.39 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.84 | 1.84 | 1.88 | 1.77 | 1.89 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.63 | 2.64 | 2.67 | 2.55 | 2.69 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.11 | 3.57 | 8.33 | 1.26 | 13.42 | 3.40 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 23.63 | 23.63 | 23.80 | 23.36 | 24.08 | 0.18 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 83.33 | 28.95 | 241.77 | 8.62 | 264.29 | 94.93 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 90.57 | 52.10 | 172.97 | 40.00 | 224.10 | 59.17 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.15 | 0.15 | 0.18 | 0.14 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.22 | 0.20 | 0.22 | 0.19 | 0.39 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.49 | 0.50 | 0.51 | 0.46 | 0.52 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 3.78 | 3.41 | 4.97 | 3.31 | 5.48 | 0.74 | 0 | 0 | 10000 |
| 5 | **BLoC (Cubit)** | 6.65 | 2.28 | 5.05 | 2.22 | 64.42 | 16.00 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 16.25 | 4.71 | 65.17 | 4.57 | 103.31 | 28.58 | 0 | 0 | 10000 |
| 7 | **Signals** | 43.87 | 21.49 | 107.71 | 9.11 | 171.45 | 47.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.11 | 0.10 | 0.14 | 0.09 | 0.15 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.16 | 0.17 | 0.16 | 0.17 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.24 | 0.26 | 0.28 | 0.03 | 0.28 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.43 | 0.42 | 0.43 | 0.42 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Signals** | 1.15 | 0.59 | 0.73 | 0.57 | 8.86 | 2.13 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.23 | 0.72 | 0.88 | 0.67 | 8.28 | 1.95 | 0 | 0 | 8000 |
| 7 | **Riverpod (Notifier)** | 1.33 | 0.58 | 0.75 | 0.55 | 11.59 | 2.84 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 16.54 | 16.49 | 18.36 | 13.98 | 20.74 | 1.65 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 20.13 | 18.09 | 28.64 | 14.52 | 33.41 | 5.66 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 20.38 | 19.73 | 22.22 | 17.47 | 27.96 | 2.52 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 21.81 | 21.41 | 27.29 | 17.24 | 31.75 | 4.06 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 23.35 | 23.35 | 29.94 | 15.44 | 33.25 | 4.65 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 24.24 | 24.01 | 29.15 | 19.21 | 29.92 | 3.30 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 24.33 | 24.13 | 31.88 | 17.02 | 32.03 | 4.90 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 24.79 | 18.67 | 40.45 | 14.67 | 44.60 | 10.55 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 27.02 | 26.79 | 28.77 | 25.60 | 30.52 | 1.29 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 27.26 | 27.28 | 29.02 | 25.61 | 29.71 | 1.30 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 28.17 | 27.83 | 29.64 | 27.00 | 30.96 | 1.09 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 28.31 | 28.20 | 29.97 | 25.86 | 31.31 | 1.44 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 30.39 | 28.67 | 31.15 | 26.28 | 49.45 | 5.44 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 35.20 | 33.56 | 41.04 | 30.50 | 45.16 | 4.05 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 38.00 | 38.70 | 45.16 | 29.48 | 55.84 | 6.80 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 42.82 | 41.35 | 50.34 | 33.76 | 52.04 | 5.81 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.09 | 29.66 | 31.00 | 28.54 | 36.30 | 1.84 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 33.74 | 32.17 | 34.72 | 31.14 | 51.09 | 4.91 | 300 | 0 | 300 |
| 🥉 | **Signals** | 33.89 | 31.64 | 44.41 | 31.10 | 47.60 | 5.03 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 48.71 | 47.84 | 49.04 | 46.02 | 62.46 | 3.92 | 300 | 0 | 300 |
| 5 | **Provider** | 59.87 | 60.04 | 63.22 | 56.51 | 63.80 | 2.09 | 300 | 0 | 300 |
| 6 | **GetX** | 68.43 | 68.66 | 71.23 | 65.37 | 71.65 | 1.74 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 33.23 | 31.69 | 34.34 | 31.21 | 50.80 | 4.94 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 41.85 | 38.88 | 63.20 | 35.39 | 71.17 | 10.62 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 49.07 | 47.58 | 49.90 | 44.63 | 73.62 | 6.94 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 66.09 | 64.79 | 68.59 | 60.69 | 84.50 | 5.52 | 300 | 0 | 300 |
| 5 | **GetX** | 77.86 | 75.68 | 78.35 | 72.76 | 106.27 | 7.97 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 80.05 | 77.80 | 83.23 | 72.93 | 104.67 | 7.39 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 1.08 | 0.47 | 4.91 | 0.45 | 5.12 | 1.60 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.26 | 0.75 | 4.59 | 0.65 | 4.61 | 1.36 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 1.27 | 0.48 | 4.38 | 0.44 | 4.65 | 1.65 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 1.29 | 0.49 | 4.53 | 0.44 | 4.65 | 1.69 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 5.97 | 5.98 | 6.01 | 5.90 | 6.03 | 0.04 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.04 | 0.03 | 0.06 | 0.03 | 0.08 | 0.02 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.08 | 0.08 | 0.07 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.07 | 0.06 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.55 | 6.14 | 9.04 | 5.69 | 9.59 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 16.14 | 6.38 | 48.52 | 5.51 | 104.86 | 26.87 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 8.94 | 8.29 | 10.54 | 7.47 | 13.19 | 1.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 2.41 | 1.74 | 6.27 | 1.63 | 7.08 | 1.74 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 10.84 | 1.83 | 59.02 | 1.65 | 79.86 | 24.11 | 0 | 0 | 0 (Zero-GC) |

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

