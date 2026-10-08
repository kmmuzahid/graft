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
| 🥇 | **Provider** | 0.19 | 0.14 | 0.37 | 0.14 | 0.44 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.45 | 0.13 | 1.24 | 0.13 | 3.80 | 0.97 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.73 | 0.40 | 2.37 | 0.15 | 2.77 | 0.88 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 1.32 | 0.69 | 3.15 | 0.55 | 7.25 | 1.76 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 1.43 | 0.97 | 2.77 | 0.42 | 4.94 | 1.24 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 2.09 | 1.32 | 4.45 | 0.95 | 10.06 | 2.36 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 4.60 | 2.80 | 6.17 | 2.55 | 24.37 | 5.55 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 1.80 | 1.75 | 2.34 | 1.31 | 3.08 | 0.48 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 2.02 | 1.81 | 3.33 | 1.35 | 3.39 | 0.63 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 4.74 | 3.85 | 9.74 | 1.29 | 9.80 | 3.24 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | 5.20 | 4.46 | 5.98 | 3.48 | 14.68 | 2.73 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 7.97 | 7.64 | 10.88 | 6.18 | 11.68 | 1.50 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 10.10 | 9.83 | 11.52 | 8.89 | 11.68 | 0.88 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 32.20 | 31.20 | 36.14 | 25.28 | 48.48 | 5.19 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.24 | 0.17 | 0.43 | 0.15 | 0.54 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.53 | 0.42 | 0.80 | 0.38 | 1.16 | 0.22 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.60 | 0.30 | 1.67 | 0.20 | 3.34 | 0.84 | 0 | 0 | 10000 |
| 4 | **Riverpod (Notifier)** | 1.53 | 1.04 | 3.06 | 0.59 | 6.17 | 1.44 | 0 | 0 | 10000 |
| 5 | **Graft** | 1.79 | 1.58 | 3.36 | 0.54 | 7.22 | 1.66 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 2.09 | 1.70 | 5.59 | 0.99 | 5.93 | 1.55 | 0 | 0 | 10000 |
| 7 | **Signals** | 10.08 | 9.41 | 11.75 | 8.93 | 15.89 | 1.78 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.04 | 0.02 | 0.08 | 0.02 | 0.09 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.06 | 0.05 | 0.11 | 0.01 | 0.25 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.16 | 0.12 | 0.26 | 0.03 | 0.33 | 0.08 | 0 | 0 | 8000 |
| 4 | **Signals** | 0.45 | 0.35 | 0.66 | 0.23 | 1.40 | 0.31 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.50 | 0.36 | 1.03 | 0.27 | 1.19 | 0.29 | 0 | 0 | 8000 |
| 6 | **Graft** | 0.76 | 0.66 | 1.12 | 0.47 | 1.30 | 0.25 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 0.82 | 0.70 | 1.50 | 0.27 | 1.82 | 0.49 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 3.38 | 3.23 | 5.60 | 1.49 | 7.10 | 1.53 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 24.41 | 24.58 | 27.55 | 18.99 | 29.92 | 3.06 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 27.74 | 27.27 | 33.58 | 21.43 | 36.90 | 4.22 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 27.98 | 27.48 | 43.12 | 19.16 | 43.82 | 7.48 | 120 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 30.88 | 29.17 | 41.35 | 23.03 | 46.06 | 6.77 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 44.20 | 42.58 | 61.55 | 32.19 | 64.36 | 8.90 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 66.04 | 70.03 | 79.82 | 40.74 | 85.61 | 12.02 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 1.36 | 1.35 | 1.45 | 1.32 | 1.53 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 23.23 | 23.04 | 24.09 | 22.11 | 24.65 | 0.69 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 23.67 | 22.68 | 25.09 | 22.23 | 32.30 | 2.52 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 24.82 | 22.66 | 31.62 | 21.18 | 43.99 | 6.05 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 25.43 | 24.21 | 30.65 | 22.52 | 32.47 | 3.18 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 34.35 | 32.28 | 41.36 | 26.40 | 55.10 | 7.40 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Graft (slots)** | 43.61 | 42.57 | 52.35 | 35.45 | 53.08 | 5.39 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 4.12 | 3.63 | 5.94 | 3.51 | 6.80 | 1.06 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 10.51 | 10.11 | 11.63 | 8.53 | 17.35 | 2.13 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 36.78 | 35.75 | 42.10 | 32.54 | 42.27 | 3.19 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 47.85 | 47.26 | 49.80 | 45.67 | 56.92 | 2.74 | 300 | 0 | 300 |
| 5 | **Provider** | 59.04 | 58.42 | 63.92 | 55.47 | 64.68 | 2.43 | 300 | 0 | 300 |
| 6 | **GetX** | 72.25 | 67.69 | 93.61 | 64.61 | 97.50 | 10.56 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 5.47 | 3.67 | 11.22 | 3.46 | 12.44 | 2.92 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 28.56 | 27.31 | 28.54 | 25.83 | 47.82 | 5.40 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 46.34 | 44.98 | 51.22 | 40.88 | 68.07 | 6.59 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 61.04 | 59.37 | 62.14 | 56.66 | 84.09 | 6.49 | 300 | 0 | 300 |
| 5 | **Provider** | 70.07 | 69.99 | 71.93 | 67.00 | 73.61 | 1.78 | 300 | 0 | 300 |
| 6 | **GetX** | 75.69 | 71.56 | 96.26 | 67.06 | 115.41 | 12.95 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.73 | 0.48 | 2.36 | 0.44 | 2.39 | 0.67 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.77 | 0.45 | 2.74 | 0.41 | 3.08 | 0.87 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.89 | 0.51 | 2.50 | 0.45 | 2.56 | 0.82 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX (RxList)** | 0.98 | 0.85 | 0.88 | 0.81 | 2.84 | 0.51 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Graft** | 1.34 | 0.73 | 2.94 | 0.65 | 3.12 | 0.99 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.05 | 0.02 | 0.03 | 0.02 | 0.53 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.06 | 0.03 | 0.03 | 0.03 | 0.45 | 0.11 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.11 | 0.06 | 0.10 | 0.06 | 0.63 | 0.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.07 | 0.06 | 0.09 | 0.05 | 0.16 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.12 | 0.10 | 0.13 | 0.09 | 0.32 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.25 | 0.06 | 0.22 | 0.05 | 2.85 | 0.72 | 0 | 0 | 100 |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 6.62 | 5.60 | 12.10 | 4.38 | 13.42 | 2.75 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 9.24 | 6.04 | 9.04 | 4.76 | 51.41 | 11.72 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 9.09 | 6.91 | 13.80 | 5.87 | 28.39 | 5.75 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 1.14 | 0.98 | 1.46 | 0.90 | 2.49 | 0.41 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.39 | 1.10 | 2.86 | 0.94 | 3.94 | 0.85 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.02 | 0.00 | 0.01 | 0.00 | 0.20 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.07 | 0.01 | 0.01 | 0.01 | 0.92 | 0.23 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

