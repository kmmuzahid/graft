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
| 🥇 | **Graft** | 0.09 | 0.09 | 0.09 | 0.09 | 0.10 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.13 | 0.12 | 0.14 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.13 | 0.13 | 0.14 | 0.12 | 0.20 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.24 | 0.14 | 0.18 | 0.13 | 1.66 | 0.39 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.57 | 0.57 | 0.61 | 0.53 | 0.61 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 0.84 | 0.84 | 0.91 | 0.79 | 0.91 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 2.29 | 2.27 | 2.37 | 2.21 | 2.49 | 0.07 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.88 | 0.63 | 0.66 | 0.60 | 4.38 | 0.97 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.37 | 1.37 | 1.41 | 1.33 | 1.49 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.57 | 1.53 | 1.72 | 1.49 | 1.80 | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 3.15 | 3.38 | 4.92 | 1.10 | 5.45 | 1.50 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.58 | 5.56 | 5.80 | 5.39 | 5.80 | 0.13 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.35 | 7.35 | 7.42 | 7.21 | 7.45 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 22.01 | 21.77 | 22.29 | 21.60 | 24.36 | 0.68 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.12 | 0.10 | 0.14 | 0.10 | 0.28 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.14 | 0.13 | 0.20 | 0.13 | 0.21 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.33 | 0.19 | 0.22 | 0.17 | 2.21 | 0.52 | 0 | 0 | 10000 |
| 4 | **GetX** | 0.38 | 0.38 | 0.40 | 0.36 | 0.40 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.62 | 0.60 | 0.75 | 0.55 | 0.80 | 0.07 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 1.02 | 0.96 | 1.21 | 0.93 | 1.25 | 0.10 | 0 | 0 | 10000 |
| 7 | **Signals** | 8.27 | 8.26 | 8.39 | 8.15 | 8.47 | 0.09 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.10 | 0.10 | 0.11 | 0.09 | 0.12 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.19 | 0.17 | 0.22 | 0.17 | 0.25 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 0.39 | 0.39 | 0.41 | 0.36 | 0.42 | 0.02 | 0 | 0 | 8000 |
| 4 | **Provider** | 0.39 | 0.14 | 0.17 | 0.14 | 3.83 | 0.95 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 0.51 | 0.51 | 0.57 | 0.45 | 0.58 | 0.04 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.65 | 0.64 | 0.67 | 0.60 | 0.88 | 0.07 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.85 | 0.85 | 0.88 | 0.80 | 0.88 | 0.02 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 12.20 | 12.00 | 12.79 | 11.42 | 12.96 | 0.45 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (StateNotifier)** | 12.56 | 11.59 | 12.49 | 11.11 | 26.00 | 3.74 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 13.17 | 13.16 | 13.92 | 12.29 | 14.32 | 0.62 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 13.21 | 12.87 | 14.17 | 11.97 | 17.72 | 1.42 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Provider** | 16.25 | 14.32 | 23.25 | 12.04 | 39.09 | 6.94 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | 30.98 | 25.13 | 50.67 | 18.10 | 93.56 | 19.08 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 37.13 | 33.82 | 45.22 | 21.77 | 104.96 | 20.05 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 51.31 | 42.64 | 71.88 | 34.19 | 122.59 | 22.63 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (slots)** | 21.14 | 20.81 | 23.01 | 20.46 | 23.10 | 0.84 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 21.56 | 21.32 | 22.63 | 20.84 | 23.13 | 0.67 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 22.85 | 22.65 | 24.49 | 21.08 | 24.64 | 1.20 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Signals** | 25.33 | 24.70 | 28.07 | 22.66 | 29.45 | 2.00 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 26.17 | 25.99 | 28.43 | 24.08 | 28.45 | 1.50 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 26.89 | 26.10 | 29.31 | 23.85 | 32.52 | 2.28 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 30.87 | 29.61 | 32.69 | 26.32 | 52.17 | 6.25 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 53.19 | 45.14 | 77.95 | 31.86 | 103.16 | 18.77 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 32.89 | 31.11 | 36.12 | 29.37 | 46.43 | 4.21 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 33.18 | 32.19 | 33.80 | 30.75 | 47.20 | 3.97 | 300 | 0 | 300 |
| 🥉 | **BLoC (Cubit)** | 47.44 | 45.76 | 51.60 | 43.50 | 58.91 | 4.20 | 300 | 0 | 300 |
| 4 | **Provider** | 60.12 | 59.57 | 65.00 | 56.20 | 66.98 | 3.30 | 300 | 0 | 300 |
| 5 | **Graft** | 61.59 | 50.49 | 111.35 | 31.89 | 160.02 | 33.60 | 300 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 66.67 | 66.45 | 68.87 | 64.69 | 69.03 | 1.41 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 32.03 | 30.23 | 33.44 | 29.72 | 51.52 | 5.52 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 39.40 | 36.38 | 56.50 | 32.81 | 63.92 | 9.68 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.66 | 44.07 | 47.50 | 42.85 | 67.25 | 6.10 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 62.44 | 60.64 | 63.12 | 57.93 | 83.26 | 5.98 | 300 | 0 | 300 |
| 5 | **GetX** | 73.97 | 72.72 | 74.11 | 68.86 | 101.92 | 7.90 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 78.19 | 75.13 | 82.83 | 71.52 | 106.30 | 8.29 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 1.48 | 0.50 | 7.29 | 0.46 | 8.54 | 2.62 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.50 | 0.90 | 5.18 | 0.83 | 5.58 | 1.58 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **BLoC (Cubit)** | 1.63 | 0.66 | 5.58 | 0.60 | 5.68 | 2.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 2.45 | 0.64 | 8.36 | 0.60 | 20.00 | 5.24 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 4.63 | 4.64 | 4.69 | 4.51 | 4.77 | 0.07 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.03 | 0.02 | 0.05 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.02 | 0.04 | 0.02 | 0.04 | 0.01 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.07 | 0.09 | 0.07 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.05 | 0.05 | 0.06 | 0.05 | 0.07 | 0.01 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.06 | 0.06 | 0.08 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.13 | 0.13 | 0.13 | 0.12 | 0.15 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 10.22 | 8.17 | 20.42 | 6.39 | 21.56 | 5.48 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 13.66 | 7.37 | 42.96 | 6.78 | 50.86 | 14.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 26.96 | 9.77 | 25.35 | 8.77 | 220.30 | 53.84 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 17.37 | 2.03 | 17.14 | 1.69 | 217.43 | 55.48 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 62.23 | 1.87 | 12.79 | 1.60 | 895.99 | 230.67 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E3_disposed_controller_access_safety

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 0.00 | 0.00 | 0.01 | 0.00 | 0.01 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.01 | 0.01 | 0.03 | 0.01 | 0.07 | 0.02 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights & Philosophy Verification

1. **Zero-Allocation In-Place Mutation**: Graft mutates domain state in-place without generating thousands of ephemeral `copyWith` garbage objects, eliminating GC stutter during high-frequency animations.
2. **Hardware Bitmask Diffing**: While fine-grained libraries require subscribing to N individual signal instances or running N selector closures, Graft evaluates up to 64 state properties in a single CPU clock cycle bitwise AND.
3. **Rebuild Firewall with 0 Static Leakage**: Graft’s `ignoredMask` and `GraftEquivalent` slots guarantee 0 wasted builds on sibling widgets in complex layouts without requiring developers to manually write boilerplate `BlocSelector` or `Selector` wrappers.
4. **Route Lifecycle Safety**: Seamlessly borrows controllers across screens with automatic cleanup on route pop, and protected host ownership during transient dialogs.

