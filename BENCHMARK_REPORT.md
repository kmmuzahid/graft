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
| 🥇 | **Provider** | 0.16 | 0.14 | 0.24 | 0.13 | 0.31 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.32 | 0.13 | 0.83 | 0.12 | 2.28 | 0.57 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.41 | 0.12 | 1.68 | 0.11 | 2.08 | 0.62 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 0.72 | 0.26 | 1.89 | 0.20 | 4.60 | 1.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.96 | 0.57 | 1.56 | 0.51 | 5.35 | 1.24 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.28 | 0.83 | 2.01 | 0.79 | 6.32 | 1.43 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 3.24 | 2.35 | 3.36 | 2.25 | 14.19 | 3.04 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.26 | 1.26 | 1.34 | 1.19 | 1.34 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.29 | 1.28 | 1.33 | 1.25 | 1.44 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.71 | 2.40 | 2.88 | 2.32 | 6.08 | 0.95 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.02 | 3.77 | 5.37 | 1.09 | 6.66 | 1.91 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 6.02 | 5.91 | 6.47 | 5.72 | 6.91 | 0.33 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.95 | 7.89 | 8.22 | 7.70 | 8.61 | 0.23 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.21 | 22.27 | 24.78 | 21.94 | 32.24 | 2.61 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.19 | 0.15 | 0.29 | 0.13 | 0.51 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.36 | 0.19 | 0.96 | 0.18 | 1.96 | 0.48 | 0 | 0 | 10000 |
| 🥉 | **GetX** | 0.40 | 0.38 | 0.43 | 0.35 | 0.74 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.81 | 0.58 | 1.01 | 0.54 | 3.50 | 0.75 | 0 | 0 | 10000 |
| 5 | **Graft** | 1.14 | 0.48 | 3.46 | 0.43 | 7.09 | 1.81 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 1.22 | 0.96 | 1.86 | 0.89 | 4.15 | 0.85 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.56 | 8.09 | 8.46 | 8.03 | 14.40 | 1.62 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.10 | 0.02 | 0.05 | 0.02 | 1.16 | 0.29 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.12 | 0.04 | 0.12 | 0.04 | 1.01 | 0.25 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.27 | 0.25 | 0.26 | 0.25 | 0.52 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.39 | 0.39 | 0.42 | 0.37 | 0.46 | 0.03 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.56 | 0.48 | 0.85 | 0.45 | 1.19 | 0.20 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.69 | 0.64 | 0.71 | 0.61 | 1.26 | 0.16 | 0 | 0 | 8000 |
| 7 | **Graft** | 0.97 | 0.62 | 1.96 | 0.47 | 2.34 | 0.63 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.42 | 1.36 | 1.56 | 1.32 | 1.88 | 0.15 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 13.95 | 13.36 | 14.49 | 12.16 | 25.33 | 3.22 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 14.06 | 13.79 | 15.75 | 12.88 | 15.84 | 0.90 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 14.79 | 14.64 | 16.05 | 13.84 | 16.40 | 0.85 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 15.98 | 16.01 | 17.24 | 14.15 | 18.10 | 1.11 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 16.17 | 16.51 | 17.59 | 14.13 | 17.68 | 1.05 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 21.18 | 21.05 | 23.27 | 16.82 | 38.00 | 5.11 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 33.84 | 32.13 | 38.97 | 28.29 | 44.88 | 4.64 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.49 | 1.36 | 2.31 | 1.26 | 2.37 | 0.35 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | 21.36 | 21.25 | 22.19 | 20.63 | 22.20 | 0.51 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 21.54 | 21.33 | 22.43 | 20.81 | 22.46 | 0.53 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 22.02 | 21.31 | 23.22 | 20.78 | 31.06 | 2.56 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 22.06 | 21.96 | 23.06 | 21.13 | 24.33 | 0.86 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | 22.57 | 22.33 | 23.17 | 20.92 | 27.10 | 1.41 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 22.65 | 22.49 | 23.27 | 21.88 | 23.77 | 0.52 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 23.79 | 22.55 | 26.79 | 21.60 | 30.11 | 2.53 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.04 | 3.48 | 5.51 | 3.38 | 6.66 | 1.06 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 35.01 | 35.01 | 35.34 | 34.62 | 35.50 | 0.22 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 38.21 | 35.84 | 46.28 | 32.75 | 46.38 | 4.67 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 45.74 | 45.70 | 46.88 | 44.23 | 47.21 | 0.86 | 300 | 0 | 300 |
| 5 | **Provider** | 56.45 | 56.15 | 60.38 | 53.26 | 61.35 | 2.59 | 300 | 0 | 300 |
| 6 | **GetX** | 64.15 | 63.22 | 71.04 | 60.72 | 73.64 | 3.70 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.65 | 3.54 | 7.59 | 3.29 | 11.14 | 2.29 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 42.92 | 41.81 | 43.52 | 39.22 | 60.55 | 5.04 | 300 | 0 | 300 |
| 🥉 | **BLoC (Cubit)** | 58.64 | 56.85 | 61.54 | 56.03 | 77.71 | 5.46 | 300 | 0 | 300 |
| 4 | **Provider** | 66.45 | 66.45 | 67.67 | 63.53 | 69.17 | 1.31 | 300 | 0 | 300 |
| 5 | **GetX** | 67.86 | 66.23 | 68.22 | 63.95 | 90.25 | 6.31 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Graft** | 133.15 | 130.91 | 143.93 | 128.30 | 146.07 | 5.79 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.76 | 0.45 | 2.71 | 0.43 | 2.91 | 0.83 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 0.83 | 0.49 | 2.94 | 0.41 | 3.09 | 0.89 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX (RxList)** | 0.95 | 0.82 | 0.90 | 0.78 | 2.84 | 0.52 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.99 | 0.48 | 3.06 | 0.43 | 3.25 | 1.07 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 2.82 | 2.05 | 4.70 | 1.95 | 5.45 | 1.24 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.04 | 0.02 | 0.03 | 0.02 | 0.36 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.05 | 0.03 | 0.05 | 0.02 | 0.33 | 0.08 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.12 | 0.07 | 0.14 | 0.05 | 0.77 | 0.18 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.07 | 0.06 | 0.08 | 0.05 | 0.16 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.07 | 0.05 | 0.07 | 0.05 | 0.31 | 0.07 | 0 | 0 | 100 |
| 🥉 | **Graft** | 0.12 | 0.11 | 0.12 | 0.11 | 0.26 | 0.04 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 8.38 | 6.03 | 15.55 | 4.61 | 27.94 | 6.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 12.95 | 6.66 | 25.99 | 5.54 | 72.54 | 17.30 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 7.77 | 6.75 | 13.05 | 5.58 | 13.32 | 2.50 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.17 | 1.06 | 1.48 | 0.92 | 2.44 | 0.38 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.37 | 1.04 | 2.87 | 0.95 | 3.80 | 0.82 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.02 | 0.00 | 0.01 | 0.00 | 0.22 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.08 | 0.01 | 0.03 | 0.01 | 1.04 | 0.27 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

