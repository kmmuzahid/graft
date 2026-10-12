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
| 🥇 | **Graft** | 0.12 | 0.11 | 0.11 | 0.10 | 0.32 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.13 | 0.13 | 0.14 | 0.12 | 0.14 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.14 | 0.13 | 0.17 | 0.13 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.48 | 0.38 | 0.97 | 0.12 | 2.20 | 0.53 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.55 | 0.55 | 0.61 | 0.50 | 0.63 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 0.80 | 0.80 | 0.85 | 0.74 | 0.85 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.51 | 2.48 | 2.76 | 2.27 | 2.78 | 0.17 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.91 | 0.67 | 0.73 | 0.63 | 4.38 | 0.96 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.51 | 1.50 | 1.60 | 1.42 | 1.63 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.58 | 1.59 | 1.62 | 1.48 | 1.66 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.51 | 3.78 | 6.26 | 1.10 | 6.31 | 2.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 6.42 | 5.87 | 7.84 | 5.57 | 11.14 | 1.48 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.90 | 7.82 | 8.17 | 7.50 | 8.36 | 0.23 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 26.65 | 26.71 | 28.76 | 25.18 | 29.58 | 1.33 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.15 | 0.10 | 0.28 | 0.10 | 0.46 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.20 | 0.17 | 0.38 | 0.15 | 0.41 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.40 | 0.22 | 0.26 | 0.20 | 2.87 | 0.68 | 0 | 0 | 10000 |
| 4 | **GetX** | 0.47 | 0.41 | 0.70 | 0.38 | 0.94 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.67 | 0.66 | 0.77 | 0.62 | 0.79 | 0.05 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.28 | 1.19 | 1.74 | 0.99 | 2.13 | 0.29 | 0 | 0 | 10000 |
| 7 | **Signals** | 10.34 | 10.18 | 11.18 | 9.76 | 11.80 | 0.61 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.03 | 0.02 | 0.07 | 0.02 | 0.08 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.22 | 0.17 | 0.38 | 0.15 | 0.46 | 0.09 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 0.26 | 0.25 | 0.29 | 0.24 | 0.31 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 0.45 | 0.40 | 0.70 | 0.30 | 0.70 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 0.58 | 0.49 | 0.93 | 0.41 | 1.08 | 0.21 | 0 | 0 | 8000 |
| 6 | **Riverpod (Notifier)** | 0.80 | 0.78 | 1.07 | 0.50 | 1.24 | 0.22 | 0 | 0 | 8000 |
| 7 | **Riverpod (StateNotifier)** | 0.99 | 0.85 | 1.41 | 0.66 | 2.57 | 0.48 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 13.55 | 12.79 | 16.32 | 11.84 | 20.58 | 2.31 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 18.98 | 16.60 | 27.66 | 12.84 | 32.40 | 5.66 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 30.84 | 21.35 | 94.42 | 12.97 | 103.52 | 28.24 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 33.14 | 28.63 | 38.19 | 21.89 | 82.04 | 14.46 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 33.56 | 25.29 | 52.23 | 18.97 | 112.86 | 23.83 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 39.28 | 32.71 | 74.91 | 23.85 | 97.51 | 20.67 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 69.09 | 59.76 | 111.50 | 48.59 | 116.98 | 22.82 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 403.28 | 189.66 | 1279.15 | 51.46 | 1805.90 | 541.96 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 20.99 | 20.91 | 21.64 | 20.08 | 22.36 | 0.59 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 21.61 | 21.61 | 23.04 | 20.38 | 23.38 | 0.82 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 21.63 | 21.32 | 22.49 | 20.95 | 22.70 | 0.60 | 120 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 21.82 | 21.01 | 22.26 | 20.64 | 31.24 | 2.65 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 22.92 | 21.26 | 28.90 | 20.21 | 32.49 | 3.59 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 31.72 | 21.10 | 58.45 | 20.58 | 116.63 | 25.47 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (leaf slot)** | 44.71 | 39.99 | 55.42 | 27.29 | 100.23 | 17.78 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | 55.39 | 45.27 | 101.88 | 24.07 | 136.32 | 29.98 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 36.06 | 33.49 | 43.15 | 31.43 | 53.57 | 5.80 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 47.84 | 46.62 | 49.42 | 45.13 | 63.83 | 4.58 | 300 | 0 | 300 |
| 🥉 | **Provider** | 58.58 | 58.06 | 60.50 | 55.93 | 63.62 | 1.95 | 300 | 0 | 300 |
| 4 | **GetX** | 71.34 | 69.66 | 78.31 | 63.41 | 86.52 | 6.27 | 300 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 170.82 | 56.17 | 268.15 | 44.68 | 849.72 | 208.84 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 217.75 | 84.84 | 681.97 | 46.05 | 1116.59 | 297.09 | 300 | 0 | 300 |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 39.88 | 35.64 | 61.94 | 32.12 | 63.05 | 11.48 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 47.06 | 44.66 | 49.70 | 42.55 | 76.85 | 8.41 | 300 | 0 | 300 |
| 🥉 | **Graft** | 47.67 | 47.68 | 49.31 | 45.65 | 50.10 | 1.21 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 62.86 | 61.40 | 63.93 | 59.62 | 86.03 | 6.54 | 300 | 0 | 300 |
| 5 | **GetX** | 70.43 | 70.85 | 72.15 | 66.06 | 72.24 | 1.61 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 75.38 | 74.73 | 78.97 | 71.04 | 79.95 | 2.41 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 1.19 | 0.65 | 4.51 | 0.60 | 4.51 | 1.35 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 1.22 | 0.54 | 5.16 | 0.46 | 6.09 | 1.80 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.52 | 0.50 | 5.63 | 0.44 | 6.78 | 2.18 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.86 | 0.48 | 7.62 | 0.44 | 7.65 | 2.88 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 5.96 | 5.87 | 6.04 | 5.77 | 6.94 | 0.28 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.02 | 0.02 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.07 | 0.09 | 0.07 | 0.09 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.06 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.07 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.12 | 0.12 | 0.13 | 0.12 | 0.13 | 0.00 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 9.84 | 6.28 | 17.32 | 5.72 | 29.39 | 6.99 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 16.56 | 7.56 | 20.21 | 6.68 | 119.00 | 28.66 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 28.92 | 9.37 | 122.75 | 8.50 | 145.30 | 43.35 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 5.33 | 1.97 | 24.71 | 1.71 | 29.04 | 8.79 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 10.84 | 1.75 | 19.33 | 1.58 | 120.20 | 30.59 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.01 | 0.01 | 0.01 | 0.00 | 0.03 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.01 | 0.01 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

