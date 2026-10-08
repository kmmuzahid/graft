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
| 🥇 | **Provider** | 0.14 | 0.13 | 0.21 | 0.13 | 0.30 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.30 | 0.11 | 0.71 | 0.11 | 2.32 | 0.58 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.37 | 0.12 | 1.40 | 0.11 | 2.03 | 0.57 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.91 | 0.54 | 1.56 | 0.50 | 5.08 | 1.18 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 1.20 | 0.88 | 2.53 | 0.22 | 5.09 | 1.23 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.21 | 0.75 | 1.87 | 0.73 | 6.51 | 1.49 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 3.18 | 2.32 | 3.29 | 2.17 | 13.94 | 2.99 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 1.19 | 1.19 | 1.22 | 1.15 | 1.25 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.30 | 1.31 | 1.35 | 1.21 | 1.46 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.91 | 2.45 | 2.61 | 2.33 | 9.27 | 1.76 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.05 | 1.75 | 5.89 | 1.08 | 8.53 | 2.26 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.42 | 5.42 | 5.50 | 5.33 | 5.50 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.10 | 7.05 | 7.35 | 6.95 | 7.38 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 22.61 | 21.82 | 24.43 | 21.58 | 31.43 | 2.54 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.17 | 0.13 | 0.26 | 0.13 | 0.48 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.38 | 0.19 | 0.98 | 0.17 | 2.35 | 0.58 | 0 | 0 | 10000 |
| 🥉 | **GetX** | 0.39 | 0.35 | 0.43 | 0.34 | 0.80 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.82 | 0.59 | 0.79 | 0.55 | 3.83 | 0.83 | 0 | 0 | 10000 |
| 5 | **Graft** | 1.00 | 0.63 | 2.40 | 0.41 | 4.61 | 1.12 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.21 | 0.93 | 1.86 | 0.89 | 4.23 | 0.87 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.60 | 8.17 | 8.59 | 8.03 | 14.23 | 1.56 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.02 | 0.02 | 0.04 | 0.01 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.04 | 0.04 | 0.06 | 0.01 | 0.08 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.13 | 0.13 | 0.18 | 0.11 | 0.21 | 0.03 | 0 | 0 | 8000 |
| 4 | **Signals** | 0.30 | 0.23 | 0.36 | 0.20 | 1.14 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.54 | 0.51 | 0.76 | 0.27 | 0.85 | 0.18 | 0 | 0 | 8000 |
| 6 | **Riverpod (Notifier)** | 0.61 | 0.52 | 0.70 | 0.46 | 1.44 | 0.24 | 0 | 0 | 8000 |
| 7 | **Graft** | 0.85 | 0.75 | 1.51 | 0.49 | 1.51 | 0.33 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.40 | 1.35 | 1.50 | 1.29 | 1.89 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 14.61 | 13.67 | 15.01 | 12.39 | 25.52 | 3.09 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 15.05 | 14.94 | 16.00 | 13.78 | 16.86 | 0.82 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 15.10 | 14.98 | 16.66 | 13.55 | 17.33 | 1.12 | 120 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 15.37 | 15.36 | 16.72 | 13.84 | 16.99 | 0.99 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 17.45 | 17.32 | 19.34 | 15.95 | 21.23 | 1.39 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 23.56 | 21.54 | 33.17 | 16.02 | 46.91 | 8.24 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 31.73 | 31.39 | 38.77 | 23.88 | 46.41 | 5.96 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.45 | 1.35 | 1.59 | 1.29 | 2.44 | 0.29 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 22.16 | 22.24 | 22.75 | 21.32 | 23.37 | 0.52 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft (slots)** | 22.31 | 22.35 | 23.59 | 20.80 | 23.93 | 0.90 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 22.71 | 22.71 | 23.53 | 21.73 | 23.58 | 0.63 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 22.82 | 22.70 | 24.11 | 21.95 | 24.19 | 0.68 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 25.10 | 24.23 | 30.66 | 22.58 | 32.62 | 2.91 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 25.89 | 23.87 | 33.89 | 22.38 | 36.56 | 4.34 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (Notifier)** | 27.02 | 22.25 | 35.28 | 21.25 | 79.32 | 14.86 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.03 | 3.47 | 5.51 | 3.35 | 5.68 | 0.92 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 9.78 | 9.76 | 10.74 | 8.37 | 10.93 | 0.79 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 37.56 | 36.30 | 42.91 | 34.00 | 48.18 | 3.78 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 46.15 | 46.25 | 46.96 | 44.36 | 50.41 | 1.46 | 300 | 0 | 300 |
| 5 | **Provider** | 56.04 | 54.77 | 63.34 | 52.61 | 63.84 | 3.48 | 300 | 0 | 300 |
| 6 | **GetX** | 65.94 | 62.90 | 78.73 | 62.32 | 86.27 | 7.06 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 5.21 | 3.52 | 7.64 | 3.26 | 16.73 | 3.51 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 31.43 | 29.92 | 34.20 | 28.14 | 48.16 | 4.89 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.35 | 43.47 | 50.34 | 40.23 | 67.48 | 6.56 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 60.74 | 57.58 | 79.28 | 55.14 | 80.11 | 8.09 | 300 | 0 | 300 |
| 5 | **GetX** | 66.63 | 66.41 | 68.92 | 63.29 | 69.40 | 1.44 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 68.84 | 66.72 | 70.89 | 65.29 | 91.41 | 6.46 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.70 | 0.50 | 0.58 | 0.43 | 3.46 | 0.77 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.77 | 0.47 | 2.56 | 0.45 | 2.69 | 0.75 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.95 | 0.49 | 2.80 | 0.44 | 2.87 | 0.95 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX (RxList)** | 1.01 | 0.89 | 0.94 | 0.80 | 2.81 | 0.50 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 1.41 | 0.76 | 3.06 | 0.67 | 3.40 | 1.06 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.05 | 0.02 | 0.03 | 0.02 | 0.44 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.05 | 0.03 | 0.03 | 0.03 | 0.40 | 0.10 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.11 | 0.06 | 0.10 | 0.05 | 0.68 | 0.16 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.06 | 0.06 | 0.08 | 0.05 | 0.16 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.07 | 0.05 | 0.06 | 0.05 | 0.26 | 0.05 | 0 | 0 | 100 |
| 🥉 | **Graft** | 0.32 | 0.11 | 0.33 | 0.09 | 3.12 | 0.78 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 5.80 | 5.04 | 7.93 | 3.99 | 13.39 | 2.37 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 9.13 | 5.74 | 9.77 | 4.74 | 51.09 | 11.68 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 7.38 | 6.68 | 10.68 | 5.74 | 11.82 | 1.95 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.18 | 1.03 | 1.40 | 0.94 | 2.62 | 0.42 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.34 | 1.00 | 2.81 | 0.91 | 4.04 | 0.88 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.02 | 0.00 | 0.01 | 0.00 | 0.21 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.07 | 0.01 | 0.01 | 0.01 | 1.00 | 0.26 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

