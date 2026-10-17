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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.10 | 0.09 | 0.10 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.14 | 0.13 | 0.16 | 0.12 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.14 | 0.16 | 0.12 | 0.21 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 0.18 | 0.17 | 0.20 | 0.16 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.93 | 0.93 | 0.98 | 0.87 | 1.06 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.54 | 2.53 | 2.63 | 2.47 | 2.64 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.42 | 3.56 | 5.98 | 3.50 | 10.55 | 1.85 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.65 | 0.65 | 0.67 | 0.61 | 0.67 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.32 | 1.33 | 1.35 | 1.23 | 1.35 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.85 | 1.87 | 1.89 | 1.79 | 1.90 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.09 | 3.78 | 8.76 | 1.25 | 8.83 | 2.62 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.75 | 5.74 | 5.83 | 5.64 | 5.90 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 8.98 | 8.95 | 9.17 | 8.78 | 9.19 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.90 | 23.85 | 24.12 | 23.68 | 24.23 | 0.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.12 | 0.14 | 0.11 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.49 | 0.49 | 0.51 | 0.46 | 0.51 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.69 | 0.20 | 2.61 | 0.19 | 5.06 | 1.36 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.71 | 0.69 | 0.80 | 0.63 | 0.88 | 0.06 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.00 | 1.00 | 1.03 | 0.94 | 1.04 | 0.03 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.13 | 9.11 | 9.31 | 8.94 | 9.48 | 0.14 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.01 | 0.01 | 0.01 | 0.01 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.12 | 0.12 | 0.17 | 0.10 | 0.18 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.19 | 0.17 | 0.29 | 0.15 | 0.33 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.50 | 0.42 | 0.44 | 0.40 | 1.66 | 0.32 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.58 | 0.58 | 0.64 | 0.54 | 0.64 | 0.03 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.66 | 0.67 | 0.68 | 0.61 | 0.68 | 0.02 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.90 | 0.69 | 1.79 | 0.67 | 2.04 | 0.43 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 20.97 | 20.45 | 25.13 | 17.94 | 26.86 | 2.59 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 22.08 | 21.95 | 24.26 | 18.56 | 26.92 | 2.23 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 22.12 | 22.80 | 27.27 | 15.02 | 27.65 | 4.25 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 24.26 | 23.93 | 27.65 | 19.73 | 33.30 | 3.57 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Graft (leaf slot)** | 24.38 | 24.42 | 28.98 | 19.15 | 31.63 | 3.77 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 27.59 | 27.38 | 35.52 | 18.94 | 42.11 | 6.40 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 28.45 | 29.01 | 45.49 | 14.86 | 49.70 | 11.92 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (StateNotifier)** | 29.02 | 26.82 | 36.06 | 19.55 | 45.59 | 7.04 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | 25.33 | 25.07 | 26.23 | 24.56 | 27.80 | 0.84 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 27.39 | 27.34 | 28.41 | 26.26 | 29.02 | 0.95 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 27.64 | 27.41 | 31.80 | 25.70 | 31.93 | 2.05 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 28.30 | 28.11 | 29.45 | 26.92 | 30.45 | 1.04 | 120 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 28.44 | 28.34 | 30.11 | 27.09 | 30.32 | 1.14 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 29.59 | 29.11 | 31.27 | 27.90 | 31.97 | 1.27 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 29.76 | 29.08 | 31.50 | 27.65 | 34.66 | 1.80 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Riverpod (StateNotifier)** | 32.61 | 30.62 | 34.90 | 28.42 | 57.91 | 7.21 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 30.18 | 29.46 | 31.30 | 28.67 | 37.66 | 2.21 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 35.47 | 34.68 | 37.94 | 32.03 | 48.89 | 4.06 | 300 | 0 | 300 |
| 🥉 | **Signals** | 35.70 | 34.49 | 38.16 | 32.05 | 52.20 | 4.91 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 49.68 | 48.76 | 50.41 | 46.66 | 65.47 | 4.45 | 300 | 0 | 300 |
| 5 | **Provider** | 60.28 | 60.33 | 61.79 | 57.83 | 61.88 | 1.35 | 300 | 0 | 300 |
| 6 | **GetX** | 72.29 | 70.04 | 78.67 | 66.32 | 88.03 | 5.81 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 33.37 | 32.71 | 35.38 | 32.06 | 36.26 | 1.40 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 42.33 | 40.31 | 62.80 | 35.84 | 64.64 | 8.88 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 49.53 | 48.06 | 51.63 | 45.76 | 70.03 | 5.91 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 66.93 | 65.43 | 66.54 | 62.21 | 95.06 | 7.90 | 300 | 0 | 300 |
| 5 | **GetX** | 78.06 | 76.10 | 78.35 | 73.02 | 107.28 | 8.23 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 81.76 | 79.82 | 88.34 | 73.07 | 109.30 | 8.46 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.30 | 0.29 | 0.32 | 0.27 | 0.42 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.80 | 0.48 | 0.63 | 0.45 | 5.15 | 1.20 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.91 | 0.45 | 3.88 | 0.43 | 3.93 | 1.22 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX (RxList)** | 0.94 | 0.94 | 0.97 | 0.91 | 0.98 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 1.19 | 0.46 | 4.24 | 0.41 | 4.28 | 1.53 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.02 | 0.02 | 0.02 | 0.01 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.04 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 40 |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Graft** | 0.06 | 0.06 | 0.06 | 0.06 | 0.08 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.06 | 0.06 | 0.06 | 0.05 | 0.12 | 0.02 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 2.67 | 2.63 | 3.05 | 2.38 | 3.12 | 0.24 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 3.91 | 2.99 | 7.22 | 2.88 | 7.71 | 1.62 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.39 | 5.36 | 5.76 | 4.91 | 6.29 | 0.36 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.88 | 0.85 | 1.03 | 0.76 | 1.13 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 1.01 | 0.98 | 1.22 | 0.80 | 1.33 | 0.14 | 0 | 0 | 0 (Zero-GC) |

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

