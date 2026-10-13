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
| 🥇 | **Graft** | 0.12 | 0.11 | 0.23 | 0.08 | 0.25 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.60 | 0.60 | 0.62 | 0.57 | 0.62 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 2.13 | 1.92 | 2.04 | 1.86 | 4.83 | 0.75 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 4.14 | 4.12 | 4.46 | 3.84 | 4.49 | 0.20 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 5.89 | 5.25 | 6.94 | 5.11 | 7.06 | 0.82 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 8.44 | 1.28 | 1.39 | 1.23 | 108.60 | 27.71 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 8.70 | 7.53 | 10.35 | 7.36 | 13.11 | 1.72 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.30 | 1.30 | 1.34 | 1.25 | 1.34 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.86 | 1.82 | 1.90 | 1.76 | 2.48 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.54 | 2.53 | 2.57 | 2.50 | 2.58 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.86 | 3.56 | 7.85 | 1.19 | 9.36 | 2.49 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 24.02 | 23.52 | 25.73 | 23.32 | 27.18 | 1.08 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 71.27 | 11.48 | 244.61 | 8.55 | 276.22 | 98.65 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 95.31 | 63.07 | 199.12 | 43.66 | 246.51 | 63.81 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.13 | 0.13 | 0.13 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.48 | 0.48 | 0.51 | 0.46 | 0.52 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 2.43 | 2.24 | 2.28 | 2.17 | 5.24 | 0.78 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 3.90 | 3.46 | 4.99 | 3.41 | 5.05 | 0.68 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 12.40 | 4.67 | 10.44 | 4.51 | 103.15 | 25.18 | 0 | 0 | 10000 |
| 7 | **Signals** | 44.03 | 22.16 | 116.28 | 9.21 | 149.16 | 42.28 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.10 | 0.10 | 0.10 | 0.10 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.24 | 0.26 | 0.28 | 0.02 | 0.29 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.43 | 0.41 | 0.45 | 0.41 | 0.58 | 0.04 | 0 | 0 | 8000 |
| 4 | **Provider** | 0.80 | 0.16 | 0.18 | 0.15 | 9.69 | 2.46 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 1.15 | 0.58 | 0.81 | 0.56 | 8.90 | 2.14 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 1.24 | 0.59 | 0.82 | 0.55 | 9.94 | 2.41 | 0 | 0 | 8000 |
| 7 | **Riverpod (StateNotifier)** | 1.27 | 0.70 | 0.78 | 0.65 | 9.11 | 2.17 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (slots)** | 20.38 | 19.96 | 23.99 | 14.75 | 25.61 | 2.98 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 20.47 | 19.17 | 28.20 | 16.19 | 28.23 | 3.64 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 21.37 | 20.25 | 25.46 | 17.23 | 29.84 | 3.35 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 22.84 | 23.90 | 25.89 | 17.20 | 27.11 | 2.87 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 23.28 | 22.94 | 27.31 | 17.70 | 28.48 | 3.06 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 23.53 | 21.73 | 28.28 | 16.30 | 41.05 | 6.03 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.71 | 22.59 | 29.68 | 14.62 | 43.08 | 6.87 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 30.80 | 30.96 | 41.34 | 21.38 | 41.96 | 7.33 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (slots)** | 23.78 | 23.49 | 25.10 | 22.83 | 25.88 | 0.84 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 23.91 | 23.87 | 24.48 | 23.08 | 25.43 | 0.55 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 25.49 | 25.17 | 26.74 | 23.80 | 27.20 | 0.96 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 25.50 | 25.22 | 26.99 | 24.51 | 27.01 | 0.77 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 25.92 | 24.64 | 26.97 | 23.71 | 41.23 | 4.32 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 26.85 | 27.57 | 30.21 | 22.73 | 31.35 | 2.81 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 27.75 | 27.47 | 30.33 | 25.33 | 31.80 | 1.90 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Signals** | 28.26 | 26.06 | 38.20 | 24.06 | 46.03 | 5.95 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.37 | 29.11 | 30.91 | 27.91 | 31.20 | 0.95 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 31.51 | 31.56 | 32.41 | 30.50 | 32.50 | 0.66 | 300 | 0 | 300 |
| 🥉 | **Signals** | 33.36 | 31.07 | 47.01 | 29.91 | 48.95 | 6.00 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 45.99 | 46.12 | 47.24 | 44.50 | 47.28 | 0.96 | 300 | 0 | 300 |
| 5 | **Provider** | 56.90 | 57.10 | 58.32 | 55.06 | 58.92 | 1.32 | 300 | 0 | 300 |
| 6 | **GetX** | 67.31 | 64.99 | 69.84 | 63.13 | 88.47 | 6.22 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 31.77 | 30.39 | 32.72 | 29.55 | 48.62 | 4.75 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 41.40 | 36.51 | 61.15 | 33.18 | 65.25 | 11.13 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 47.90 | 45.66 | 50.14 | 43.52 | 73.88 | 7.48 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 63.32 | 61.93 | 66.18 | 57.33 | 85.82 | 6.77 | 300 | 0 | 300 |
| 5 | **GetX** | 71.75 | 71.83 | 73.36 | 67.74 | 74.90 | 1.92 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 74.76 | 74.41 | 79.29 | 69.94 | 82.10 | 2.88 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.97 | 0.52 | 3.79 | 0.49 | 4.04 | 1.20 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 1.08 | 0.51 | 4.57 | 0.49 | 5.01 | 1.51 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.16 | 0.50 | 3.81 | 0.48 | 3.82 | 1.36 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 1.18 | 0.76 | 3.98 | 0.65 | 4.06 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 6.03 | 6.03 | 6.06 | 5.99 | 6.08 | 0.03 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.03 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.03 | 0.05 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.08 | 0.08 | 0.07 | 0.10 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.06 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.12 | 0.12 | 0.13 | 0.11 | 0.13 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.53 | 5.57 | 9.55 | 5.34 | 12.35 | 2.11 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 17.44 | 7.12 | 62.29 | 5.43 | 103.71 | 27.81 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 8.62 | 8.09 | 10.24 | 7.23 | 11.95 | 1.35 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 2.03 | 1.71 | 1.89 | 1.63 | 6.50 | 1.24 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 5.50 | 1.76 | 2.42 | 1.61 | 56.90 | 14.22 | 0 | 0 | 0 (Zero-GC) |

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

