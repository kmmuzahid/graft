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
| 🥇 | **Graft** | 0.11 | 0.11 | 0.17 | 0.09 | 0.19 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.63 | 0.63 | 0.65 | 0.60 | 0.66 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 1.66 | 1.41 | 1.46 | 1.34 | 5.34 | 1.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 2.08 | 1.89 | 1.91 | 1.84 | 4.91 | 0.78 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 3.93 | 3.96 | 4.33 | 3.61 | 4.51 | 0.27 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 5.80 | 5.28 | 6.93 | 5.19 | 6.96 | 0.73 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 7.67 | 6.78 | 8.97 | 6.70 | 10.00 | 1.19 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 1.37 | 1.38 | 1.41 | 1.32 | 1.43 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.89 | 1.88 | 1.91 | 1.86 | 1.98 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 2.58 | 2.58 | 2.61 | 2.52 | 2.63 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.14 | 3.76 | 8.39 | 1.26 | 11.04 | 2.78 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 25.25 | 25.27 | 25.49 | 25.01 | 25.54 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 90.95 | 65.27 | 249.38 | 9.08 | 271.17 | 97.54 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 98.08 | 54.95 | 222.10 | 40.93 | 228.31 | 69.67 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 0.22 | 0.20 | 0.22 | 0.19 | 0.41 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.49 | 0.48 | 0.50 | 0.48 | 0.51 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 3.97 | 3.44 | 5.15 | 3.33 | 5.71 | 0.85 | 0 | 0 | 10000 |
| 5 | **BLoC (Cubit)** | 6.26 | 2.26 | 6.10 | 2.21 | 58.59 | 14.51 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 12.25 | 4.72 | 10.12 | 4.63 | 102.17 | 24.92 | 0 | 0 | 10000 |
| 7 | **Signals** | 44.94 | 22.21 | 141.25 | 9.04 | 185.49 | 51.98 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **GetX** | 0.10 | 0.10 | 0.11 | 0.10 | 0.12 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.16 | 0.17 | 0.14 | 0.18 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.25 | 0.26 | 0.28 | 0.03 | 0.29 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.41 | 0.43 | 0.41 | 0.44 | 0.01 | 0 | 0 | 8000 |
| 5 | **Signals** | 0.60 | 0.60 | 0.61 | 0.58 | 0.61 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (Notifier)** | 1.10 | 0.56 | 0.69 | 0.52 | 8.60 | 2.08 | 0 | 0 | 8000 |
| 7 | **Riverpod (StateNotifier)** | 1.23 | 0.68 | 0.76 | 0.66 | 8.79 | 2.09 | 0 | 0 | 8000 |

### 🔹 Scenario: B1_10_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 21.73 | 22.63 | 24.11 | 18.01 | 24.30 | 2.06 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 21.86 | 21.12 | 27.14 | 15.87 | 27.54 | 3.53 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 22.05 | 20.62 | 27.28 | 17.90 | 30.18 | 3.71 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | 22.25 | 21.17 | 31.44 | 16.85 | 32.69 | 4.45 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 22.45 | 23.42 | 25.52 | 15.99 | 32.45 | 4.47 | 120 | 0 | 0 (Zero-GC) |
| 6 | **GetX** | 23.53 | 22.40 | 32.99 | 15.62 | 37.19 | 6.48 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 24.25 | 22.80 | 31.73 | 18.61 | 32.63 | 4.37 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 27.78 | 29.40 | 32.25 | 19.50 | 38.64 | 5.19 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (slots)** | 24.33 | 24.53 | 25.05 | 23.27 | 25.26 | 0.66 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 25.61 | 25.26 | 26.73 | 24.87 | 26.98 | 0.69 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Signals** | 25.66 | 25.46 | 26.45 | 24.77 | 27.80 | 0.81 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 25.82 | 25.73 | 27.20 | 24.35 | 27.45 | 0.96 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 25.96 | 25.36 | 27.70 | 24.83 | 28.45 | 1.16 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 26.66 | 26.43 | 27.67 | 25.57 | 28.31 | 0.74 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 27.25 | 26.14 | 29.13 | 24.43 | 40.32 | 3.84 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (leaf slot)** | 27.82 | 27.49 | 31.41 | 24.36 | 32.80 | 2.73 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 29.33 | 29.21 | 30.45 | 28.49 | 30.95 | 0.68 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 31.96 | 31.74 | 33.24 | 31.16 | 33.37 | 0.67 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.68 | 31.46 | 35.13 | 30.89 | 43.35 | 3.21 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 46.51 | 46.45 | 47.30 | 45.60 | 47.60 | 0.66 | 300 | 0 | 300 |
| 5 | **Provider** | 58.43 | 58.59 | 61.11 | 56.34 | 62.06 | 1.74 | 300 | 0 | 300 |
| 6 | **GetX** | 69.02 | 66.32 | 80.96 | 63.85 | 85.51 | 6.21 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 35.22 | 33.49 | 37.77 | 32.16 | 49.75 | 4.29 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 46.66 | 45.90 | 49.61 | 44.72 | 52.20 | 2.01 | 300 | 0 | 300 |
| 🥉 | **Signals** | 48.47 | 43.56 | 74.35 | 39.59 | 77.23 | 13.61 | 300 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 75.55 | 75.81 | 76.60 | 72.08 | 77.46 | 1.45 | 300 | 0 | 300 |
| 5 | **BLoC (Cubit)** | 76.41 | 75.39 | 79.81 | 70.42 | 104.05 | 8.26 | 300 | 0 | 300 |
| 6 | **GetX** | 77.92 | 75.11 | 80.14 | 73.83 | 106.98 | 8.27 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C3_random_insert_remove_100x

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 1.16 | 0.50 | 5.29 | 0.46 | 5.66 | 1.75 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 1.17 | 0.73 | 4.03 | 0.64 | 4.07 | 1.17 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 1.24 | 0.50 | 4.29 | 0.47 | 4.30 | 1.56 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 1.28 | 0.48 | 4.42 | 0.46 | 4.68 | 1.66 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 7.66 | 6.35 | 8.07 | 6.30 | 22.54 | 4.16 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D1_product_catalog_and_cart

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Signals** | 0.02 | 0.02 | 0.02 | 0.02 | 0.02 | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.03 | 0.03 | 0.03 | 0.02 | 0.03 | 0.00 | 0 | 0 | 40 |
| 🥉 | **Graft** | 0.08 | 0.08 | 0.08 | 0.07 | 0.11 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D2_form_12_interdependent_fields

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC (Cubit)** | 0.06 | 0.06 | 0.06 | 0.05 | 0.07 | 0.00 | 0 | 0 | 100 |
| 🥈 | **Signals** | 0.06 | 0.06 | 0.07 | 0.06 | 0.09 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | 0.13 | 0.13 | 0.14 | 0.12 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: D3_navigation_and_dialog_sharing

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 6.08 | 5.70 | 8.65 | 5.43 | 8.82 | 1.10 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC** | 17.90 | 6.54 | 56.87 | 5.52 | 128.12 | 33.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E1_route_push_pop_and_dialog_lifecycle

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | 8.93 | 7.95 | 10.58 | 7.58 | 13.79 | 1.71 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: E2_hot_reload_reassemble_simulation

| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **BLoC** | 2.52 | 1.79 | 7.00 | 1.63 | 7.32 | 1.89 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | 10.92 | 1.85 | 56.73 | 1.65 | 82.60 | 24.35 | 0 | 0 | 0 (Zero-GC) |

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

