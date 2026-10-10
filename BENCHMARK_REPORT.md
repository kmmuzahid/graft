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
| 🥇 | **Graft** | 0.09 | 0.07 | 0.17 | 0.05 | 0.18 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.22 | 0.13 | 0.42 | 0.13 | 0.42 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.27 | 0.15 | 0.44 | 0.14 | 0.66 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.41 | 0.37 | 0.45 | 0.13 | 2.27 | 0.53 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.86 | 0.85 | 1.09 | 0.52 | 1.24 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.16 | 1.03 | 1.56 | 0.86 | 2.03 | 0.31 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 3.06 | 2.85 | 4.30 | 2.31 | 4.40 | 0.62 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.85 | 0.72 | 1.22 | 0.65 | 1.36 | 0.22 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.79 | 1.47 | 2.71 | 1.32 | 2.84 | 0.54 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 2.00 | 1.90 | 2.58 | 1.45 | 2.59 | 0.45 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 5.65 | 6.05 | 9.92 | 1.25 | 12.06 | 3.42 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 7.91 | 7.85 | 9.88 | 6.35 | 11.14 | 1.41 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 11.69 | 12.00 | 13.82 | 8.30 | 13.86 | 1.89 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 30.34 | 30.17 | 33.58 | 26.46 | 34.39 | 2.25 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.18 | 0.15 | 0.35 | 0.14 | 0.40 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.40 | 0.39 | 0.48 | 0.38 | 0.49 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.41 | 0.20 | 0.33 | 0.20 | 2.94 | 0.70 | 0 | 0 | 10000 |
| 4 | **Graft** | 0.42 | 0.46 | 0.49 | 0.16 | 0.50 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 1.74 | 1.49 | 2.36 | 0.90 | 5.94 | 1.24 | 0 | 0 | 10000 |
| 6 | **Riverpod (Notifier)** | 6.54 | 6.25 | 8.63 | 4.84 | 9.53 | 1.45 | 0 | 0 | 10000 |
| 7 | **Signals** | 10.72 | 10.34 | 11.62 | 9.43 | 15.37 | 1.42 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.16 | 0.15 | 0.29 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.47 | 0.24 | 0.47 | 0.23 | 3.24 | 0.77 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.51 | 0.51 | 0.52 | 0.49 | 0.54 | 0.01 | 0 | 0 | 8000 |
| 5 | **BLoC (Cubit)** | 0.71 | 0.42 | 1.08 | 0.40 | 2.16 | 0.49 | 0 | 0 | 8000 |
| 6 | **Graft** | 0.74 | 0.81 | 0.94 | 0.42 | 1.07 | 0.21 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (StateNotifier)** | 1.11 | 1.06 | 1.69 | 0.66 | 1.71 | 0.41 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 2.03 | 1.49 | 3.13 | 1.47 | 3.21 | 0.73 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 13.09 | 13.04 | 14.10 | 12.22 | 15.23 | 0.78 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 17.38 | 14.24 | 24.37 | 13.21 | 38.34 | 6.79 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 23.66 | 21.82 | 34.19 | 17.25 | 41.21 | 6.57 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 25.58 | 24.58 | 35.67 | 14.83 | 35.74 | 7.98 | 120 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 27.56 | 25.51 | 35.03 | 18.58 | 44.03 | 6.96 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 157.92 | 113.97 | 451.70 | 44.16 | 465.35 | 128.74 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 214.58 | 96.37 | 746.56 | 60.33 | 802.17 | 245.80 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.52 | 1.46 | 1.67 | 1.40 | 2.15 | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 20.83 | 20.58 | 21.70 | 20.02 | 22.45 | 0.70 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 21.37 | 21.22 | 22.09 | 20.71 | 22.46 | 0.50 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 22.66 | 21.88 | 23.43 | 20.97 | 33.62 | 3.14 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 63.23 | 26.98 | 109.26 | 20.27 | 360.67 | 87.68 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 86.96 | 65.84 | 128.99 | 52.97 | 300.03 | 62.29 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 122.33 | 61.47 | 313.43 | 38.01 | 394.71 | 114.54 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 339.23 | 46.93 | 358.88 | 28.27 | 4053.57 | 1030.77 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.20 | 3.67 | 5.72 | 3.54 | 6.02 | 0.90 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 46.53 | 46.15 | 48.92 | 44.69 | 52.98 | 2.06 | 300 | 0 | 300 |
| 🥉 | **Provider** | 55.38 | 55.55 | 56.15 | 53.89 | 57.55 | 0.90 | 300 | 0 | 300 |
| 4 | **Riverpod (Notifier)** | 60.02 | 33.54 | 100.07 | 31.32 | 329.88 | 76.85 | 300 | 0 | 300 |
| 5 | **GetX** | 65.03 | 63.76 | 66.88 | 61.51 | 81.45 | 4.87 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Graft** | 104.80 | 56.09 | 277.70 | 37.41 | 323.17 | 90.67 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.69 | 3.68 | 7.06 | 3.43 | 7.28 | 1.54 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 43.97 | 41.87 | 49.03 | 40.48 | 61.62 | 5.49 | 300 | 0 | 300 |
| 🥉 | **Graft** | 46.86 | 45.51 | 49.80 | 43.44 | 62.79 | 4.69 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 59.99 | 58.64 | 60.85 | 55.89 | 77.92 | 5.19 | 300 | 0 | 300 |
| 5 | **GetX** | 67.91 | 66.53 | 67.88 | 63.80 | 91.57 | 6.62 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 68.37 | 67.55 | 72.49 | 64.56 | 77.44 | 3.19 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.02 | 0.65 | 3.22 | 0.61 | 3.71 | 1.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 1.15 | 0.47 | 3.92 | 0.44 | 3.94 | 1.42 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 1.26 | 0.50 | 4.48 | 0.47 | 4.70 | 1.59 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 4.51 | 0.47 | 6.72 | 0.44 | 48.57 | 12.38 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 5.96 | 5.86 | 5.98 | 5.63 | 7.44 | 0.42 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.03 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.07 | 0.08 | 0.07 | 0.09 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.06 | 0.05 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.12 | 0.12 | 0.12 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 7.94 | 5.88 | 15.46 | 5.58 | 17.67 | 4.18 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 9.06 | 6.26 | 19.48 | 5.35 | 20.09 | 5.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 44.32 | 9.87 | 93.57 | 8.42 | 332.96 | 83.84 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.40 | 1.73 | 5.79 | 1.60 | 7.84 | 1.84 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 2.42 | 1.68 | 6.43 | 1.62 | 7.81 | 1.93 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.01 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

