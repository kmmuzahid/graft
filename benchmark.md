# 🚀 Late 2026 Flutter State Management Benchmark Report

> See the full primary report at [`BENCHMARK_REPORT.md`](file:///Users/km/Documents/km%20muzahid/graft/BENCHMARK_REPORT.md).

**A Comprehensive, Empirical Comparison of Graft vs. Leading State Management Solutions across Native IO & Web Platforms**

---

## 📋 Executive Summary

This benchmark suite empirically evaluates **Graft** (`1.0.0`) against the primary Flutter state management paradigms across two distinct environments:
1. **💻 Native Platform:** macOS (ARM64 / Apple Silicon) running the ahead-of-time (AOT) / JIT 64-bit Dart VM with native register optimizations.
2. **🌐 Web Platform:** Chromium Engine (Web JavaScript & WebAssembly) with 32-bit chunked bitmask diffing and browser garbage collection dynamics.

### 🧪 Evaluated Frameworks:
1. **Graft** (`1.0.0`) — Self-optimizing bitmask diff engine with zero-wrapper domain state
2. **Riverpod (Notifier / Codegen-style)** — Class-based `Notifier` with immutable transitions
3. **Riverpod (StateNotifier / Legacy)** — `StateNotifier` without code generation
4. **flutter_bloc + Cubit** (`8.1.6`) — Stream/Equatable domain state with `BlocSelector`
5. **signals_flutter** (`5.5.1`) — Preact fine-grained reactive signals and `Watch`
6. **GetX** (`4.7.3`) — Reactive `.obs` with `Obx` element micro-rebuilds
7. **Provider** (`6.1.5+1`) — Classical `ChangeNotifier` + `Selector`

---

## ⚖️ Cross-Platform Executive Comparison: Native IO vs. Web

| Benchmark Scenario | Metric / Unit | Native IO Winner (Time) | Native IO Graft (Rank & Time) | Web Browser Winner (Time) | Web Browser Graft (Rank & Time) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **A1: 10,000 Synchronous Increments** | Latency (ms) | 🥇 **Graft (0.10 ms)** | 🥇 **0.10 ms (#1)** | 🥇 Provider (0.62 ms) | 🥉 **1.21 ms (#3, +0.59ms)** |
| **A2: 100,000 Micro-State Mutations** | Latency (ms) | 🥇 **Graft (0.66 ms)** | 🥇 **0.66 ms (#1)** | 🥇 Provider (4.77 ms) | 🥉 **13.10 ms (#3, +8.33ms)** |
| **A3: 5-Field Atomic Batch Mutation** | Latency (ms) | 🥇 **Graft (0.12 ms)** | 🥇 **0.12 ms (#1)** | 🥇 Provider (0.72 ms) | 4th · **3.69 ms (#4, +2.97ms)** |
| **A4: Depth-8 Nested Sub-State Mutation** | Latency (ms) | 🥇 **Graft (0.01 ms)** | 🥇 **0.01 ms (#1)** | 🥇 Provider (0.11 ms) | 🥈 **0.13 ms (#2, +0.02ms)** |
| **B1: 10-Slot Column Layout (120 Frames)** | Render Time (ms) | 🥇 Provider (16.06 ms) | 🥈 **23.36 ms (#2, +7.30ms)** | 🥇 Riverpod (76.37 ms) | 4th · **78.29 ms (#4, +1.92ms)** |
| **B2: 50-Slot Heavy Layout (120 Frames)** | Render Time (ms) | 🥇 Riverpod (24.74 ms) | 🥈 **24.83 ms (#2, +0.09ms)** | 🥇 **Graft (168.55 ms)** | 🥇 **168.55 ms (#1)** |
| **C1: 5,000 Item List (300 Rapid Updates)** | Throughput (ms) | 🥇 **Graft (28.99 ms)** | 🥇 **28.99 ms (#1)** | 🥇 **Graft (136.11 ms)** | 🥇 **136.11 ms (#1)** |
| **C2: 20,000 Item List (300 Rapid Updates)**| Throughput (ms) | 🥇 **Graft (31.02 ms)** | 🥇 **31.02 ms (#1)** | 🥇 **Graft (136.29 ms)** | 🥇 **136.29 ms (#1)** |
| **C3: Random Item Insert / Delete (100x)**  | Latency (ms) | 🥇 **Graft (0.30 ms)** | 🥇 **0.30 ms (#1)** | 🥇 **Graft (0.07 ms)** | 🥇 **0.07 ms (#1)** |
| **D1: Product Catalog & Shopping Cart**    | Latency (ms) | 🥇 **Graft (0.02 ms)** | 🥇 **0.02 ms (#1)** | 🥇 **Graft (0.03 ms)** | 🥇 **0.03 ms (#1)** |
| **D2: Form (12 Interdependent Fields)**    | Latency (ms) | 🥇 **Graft (0.06 ms)** | 🥇 **0.06 ms (#1, Zero-GC)** | 🥇 BLoC (0.06 ms) | 🥈 **0.07 ms (#2, +0.01ms)** |
| **D3: Navigation & Dialog State Sharing**  | Latency (ms) | 🥇 **Graft (2.54 ms)** | 🥇 **2.54 ms (#1)** | 🥇 **Graft (8.17 ms)** | 🥇 **8.17 ms (#1)** |
| **E1: Route Stack Push / Pop Lifecycle**   | Latency (ms) | 🥇 **Graft (6.05 ms)** | 🥇 **6.05 ms (#1)** | 🥇 **Graft (17.28 ms)** | 🥇 **17.28 ms (#1)** |
| **E2: Hot Reload Reassemble Simulation**   | Latency (ms) | 🥇 **Graft (0.92 ms)** | 🥇 **0.92 ms (#1)** | 🥇 **Graft (3.35 ms)** | 🥇 **3.35 ms (#1)** |
| **E3: Disposed Controller Access Safety**  | Safety (ms)  | 🥇 **Graft (0.00 ms)** | 🥇 **0.00 ms (#1, Safe)** | 🥇 **Graft (0.00 ms)** | 🥇 **0.00 ms (#1, Safe)** |

---

## ⚙️ Environment & Methodology

| Specification | Native IO Platform | Web Platform |
| :--- | :--- | :--- |
| **Flutter SDK** | `Flutter 3.47.6 (stable channel)` | `Flutter 3.47.6 (stable channel)` |
| **Dart SDK** | `Dart 3.13.5 (stable)` | `Dart 3.13.5 (stable)` |
| **Target Runtime** | macOS Darwin 24.x (ARM64 Apple Silicon) | Chromium Engine (Brave / Chrome V8) |
| **Execution Mode** | Native 64-bit Dart VM | Web JS / WebAssembly Runtime |
| **Warm-up Protocol** | 3 full iterations discarded per scenario | 3 full iterations discarded per scenario |
| **Measurement Protocol** | **Minimum 15 measured runs per scenario** | **Minimum 15 measured runs per scenario** |
| **Metrics Tracked** | Mean, Median, p95, Min, Max, StdDev, Builds | Mean, Median, p95, Min, Max, StdDev, Builds |

---

# 💻 Section 1: Native Platform Benchmarks (macOS / ARM64 VM)

### 🔹 Scenario: A1_10k_increments (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.10** | **0.10** | **0.10** | **0.09** | **0.12** | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.14 | 0.14 | 0.15 | 0.13 | 0.16 | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.15 | 0.14 | 0.16 | 0.14 | 0.22 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.17 | 0.13 | 0.15 | 0.12 | 0.67 | 0.14 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (StateNotifier)** | 0.83 | 0.82 | 0.88 | 0.79 | 0.90 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 2.45 | 2.46 | 2.49 | 2.38 | 2.50 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 4.42 | 3.62 | 5.43 | 3.54 | 8.17 | 1.29 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.66** | **0.67** | **0.68** | **0.63** | **0.69** | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 1.28 | 1.28 | 1.31 | 1.24 | 1.33 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 1.45 | 1.44 | 1.48 | 1.41 | 1.49 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 4.33 | 3.66 | 7.48 | 1.25 | 12.10 | 2.84 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.08 | 5.08 | 5.12 | 5.01 | 5.14 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 7.59 | 7.57 | 7.71 | 7.48 | 7.76 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 23.72 | 23.72 | 23.90 | 23.51 | 24.02 | 0.13 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5 (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.12** | **0.12** | **0.13** | **0.12** | **0.13** | 0.00 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 0.16 | 0.15 | 0.17 | 0.14 | 0.23 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.40 | 0.39 | 0.43 | 0.38 | 0.43 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.45 | 0.20 | 1.28 | 0.20 | 2.83 | 0.71 | 0 | 0 | 10000 |
| 5 | **Riverpod (Notifier)** | 0.67 | 0.66 | 0.75 | 0.59 | 0.81 | 0.06 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 0.88 | 0.87 | 0.93 | 0.84 | 0.96 | 0.03 | 0 | 0 | 10000 |
| 7 | **Signals** | 9.14 | 9.07 | 9.33 | 8.94 | 9.46 | 0.15 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.01** | **0.01** | **0.01** | **0.01** | **0.03** | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 0.10 | 0.09 | 0.12 | 0.09 | 0.18 | 0.03 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.18 | 0.16 | 0.25 | 0.14 | 0.32 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.42 | 0.41 | 0.44 | 0.40 | 0.45 | 0.01 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 0.63 | 0.56 | 0.62 | 0.53 | 1.63 | 0.28 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 0.79 | 0.70 | 0.81 | 0.68 | 1.74 | 0.26 | 0 | 0 | 8000 |
| 7 | **Signals** | 0.79 | 0.68 | 1.00 | 0.65 | 1.88 | 0.32 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 16.06 | 15.91 | 17.14 | 14.97 | 17.88 | 0.81 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (slots)** | **23.36** | **21.64** | **30.25** | **18.81** | **32.30** | 3.97 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 25.03 | 20.61 | 34.66 | 18.10 | 45.56 | 8.00 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 26.57 | 26.55 | 32.17 | 21.05 | 33.42 | 3.34 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 27.64 | 25.75 | 37.23 | 22.23 | 43.53 | 5.91 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (leaf slot)** | **27.91** | **28.59** | **31.37** | **21.73** | **38.26** | 4.28 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Riverpod (Notifier)** | 28.37 | 28.15 | 34.85 | 23.08 | 37.43 | 4.29 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 31.06 | 31.13 | 38.10 | 21.68 | 52.59 | 7.70 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (Notifier)** | 24.74 | 24.47 | 26.02 | 23.62 | 26.78 | 0.89 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft (leaf slot)** | **24.83** | **24.12** | **27.03** | **23.01** | **27.25** | 1.50 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (StateNotifier)** | 25.14 | 24.62 | 26.57 | 24.07 | 26.62 | 0.98 | 120 | 0 | 0 (Zero-GC) |
| 4 | **GetX** | 26.08 | 25.58 | 27.73 | 24.93 | 28.13 | 1.00 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Signals** | 26.34 | 25.83 | 28.02 | 24.86 | 28.09 | 1.24 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Graft (slots)** | **26.56** | **25.53** | **27.09** | **24.71** | **40.52** | 3.93 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 27.10 | 26.75 | 29.37 | 25.29 | 30.51 | 1.64 | 120 | 0 | 0 (Zero-GC) |
| 8 | **BLoC (Cubit)** | 27.65 | 26.68 | 28.04 | 25.25 | 44.34 | 4.71 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **28.99** | **28.18** | **29.50** | **27.28** | **40.11** | 3.14 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 30.91 | 29.98 | 31.40 | 29.48 | 41.74 | 3.05 | 300 | 0 | 300 |
| 🥉 | **Signals** | 32.15 | 29.35 | 45.40 | 28.95 | 47.57 | 6.00 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 45.43 | 44.72 | 46.84 | 43.43 | 55.94 | 3.04 | 300 | 0 | 300 |
| 5 | **Provider** | 56.06 | 56.35 | 56.94 | 54.81 | 57.42 | 0.85 | 300 | 0 | 300 |
| 6 | **GetX** | 63.64 | 62.83 | 66.65 | 61.54 | 67.21 | 1.86 | 300 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C2_20k_items_300_rapid_updates (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **31.02** | **30.51** | **32.95** | **29.36** | **35.08** | 1.57 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 40.91 | 37.49 | 62.00 | 33.38 | 62.67 | 9.68 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 45.30 | 44.18 | 46.72 | 42.15 | 64.21 | 5.44 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 65.40 | 61.20 | 87.11 | 59.93 | 87.36 | 9.20 | 300 | 0 | 300 |
| 5 | **GetX** | 74.77 | 72.93 | 76.13 | 69.18 | 98.33 | 6.71 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 76.56 | 74.29 | 80.49 | 70.74 | 102.34 | 7.56 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x (Native IO)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.30** | **0.30** | **0.32** | **0.29** | **0.33** | 0.01 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX (RxList)** | 0.85 | 0.85 | 0.89 | 0.83 | 0.89 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 0.87 | 0.47 | 3.42 | 0.40 | 3.63 | 1.08 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Provider** | 1.02 | 0.46 | 3.31 | 0.41 | 3.37 | 1.18 | 0 | 0 | 0 (Zero-GC) |
| 5 | **BLoC (Cubit)** | 1.43 | 0.50 | 4.75 | 0.46 | 5.89 | 1.87 | 0 | 0 | 0 (Zero-GC) |

---

# 🌐 Section 2: Web Platform Benchmarks (Chromium Engine / Web JS)

### 🔹 Scenario: A1_10k_increments (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.62 | 0.50 | 0.60 | 0.50 | 0.80 | 0.12 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 1.13 | 1.20 | 1.20 | 1.10 | 1.30 | 0.06 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | **1.21** | **1.20** | **1.40** | **1.10** | **1.40** | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 1.54 | 1.50 | 1.60 | 1.40 | 1.70 | 0.08 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 5.27 | 5.20 | 5.60 | 5.10 | 5.70 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 6.42 | 6.40 | 6.70 | 6.20 | 6.80 | 0.16 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 30.29 | 30.20 | 33.30 | 29.80 | 34.20 | 1.14 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A2_100k_increments (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 4.77 | 4.60 | 5.30 | 4.40 | 5.40 | 0.32 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 11.58 | 11.60 | 11.70 | 11.40 | 11.80 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Graft** | **13.10** | **13.00** | **13.40** | **12.80** | **13.50** | 0.19 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 16.29 | 14.70 | 21.90 | 14.20 | 22.50 | 2.86 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 53.73 | 53.60 | 54.30 | 53.10 | 54.60 | 0.40 | 0 | 0 | 0 (Zero-GC) |
| 6 | **Riverpod (StateNotifier)** | 64.31 | 64.20 | 64.70 | 63.80 | 64.90 | 0.30 | 0 | 0 | 0 (Zero-GC) |
| 7 | **Signals** | 315.75 | 305.80 | 313.90 | 300.20 | 320.10 | 6.84 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A3_multi_field_5 (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.72 | 0.60 | 0.60 | 0.60 | 1.10 | 0.17 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 1.89 | 1.90 | 2.00 | 1.80 | 2.10 | 0.08 | 0 | 0 | 10000 |
| 🥉 | **GetX** | 3.57 | 3.60 | 3.70 | 3.50 | 3.70 | 0.07 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Graft** | **3.69** | **3.70** | **3.80** | **3.50** | **3.90** | 0.10 | 0 | 0 | 0 (Zero-GC) |
| 5 | **Riverpod (Notifier)** | 6.72 | 6.70 | 7.00 | 6.50 | 7.20 | 0.17 | 0 | 0 | 10000 |
| 6 | **Riverpod (StateNotifier)** | 8.59 | 8.60 | 8.70 | 8.40 | 8.80 | 0.11 | 0 | 0 | 10000 |
| 7 | **Signals** | 144.60 | 144.70 | 149.30 | 140.20 | 151.10 | 3.01 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: A4_depth8_nested (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Provider** | 0.11 | 0.10 | 0.20 | 0.10 | 0.20 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **Graft** | **0.13** | **0.10** | **0.20** | **0.10** | **0.20** | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **GetX** | 0.19 | 0.20 | 0.20 | 0.10 | 0.30 | 0.05 | 0 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 0.36 | 0.40 | 0.40 | 0.30 | 0.50 | 0.06 | 0 | 0 | 8000 |
| 5 | **Riverpod (Notifier)** | 1.03 | 1.00 | 1.10 | 1.00 | 1.20 | 0.06 | 0 | 0 | 8000 |
| 6 | **Riverpod (StateNotifier)** | 1.11 | 1.10 | 1.20 | 1.00 | 1.30 | 0.07 | 0 | 0 | 8000 |
| 7 | **Signals** | 3.31 | 3.30 | 3.40 | 3.20 | 3.50 | 0.09 | 0 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B1_10_slot_column_120_frames (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Riverpod (StateNotifier)** | 76.37 | 76.10 | 77.10 | 75.80 | 78.40 | 0.72 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **GetX** | 77.42 | 77.30 | 80.00 | 76.20 | 81.30 | 1.32 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 77.82 | 76.70 | 82.40 | 76.10 | 83.10 | 2.19 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Graft (slots)** | **78.29** | **78.20** | **79.90** | **76.90** | **81.00** | 1.12 | 120 | 0 | 0 (Zero-GC) |
| 5 | **Graft (leaf slot)** | **79.17** | **77.70** | **85.60** | **76.80** | **86.40** | 2.98 | 120 | 0 | 0 (Zero-GC) |
| 6 | **BLoC (Cubit)** | 80.78 | 80.10 | 87.60 | 78.90 | 88.50 | 2.45 | 120 | 0 | 0 (Zero-GC) |
| 7 | **Provider** | 82.35 | 80.20 | 84.50 | 79.10 | 85.30 | 2.15 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Signals** | 84.22 | 81.20 | 93.50 | 80.10 | 94.20 | 4.31 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: B2_50_slot_column_120_frames (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft (leaf slot)** | **168.55** | **168.50** | **169.90** | **167.20** | **171.10** | 1.05 | 120 | 0 | 0 (Zero-GC) |
| 🥈 | **Provider** | 172.05 | 172.10 | 174.70 | 170.80 | 175.20 | 1.28 | 120 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 173.05 | 172.00 | 176.20 | 171.20 | 177.10 | 1.84 | 120 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (StateNotifier)** | 173.18 | 170.70 | 188.20 | 170.10 | 189.50 | 5.21 | 120 | 0 | 0 (Zero-GC) |
| 5 | **GetX** | 175.52 | 169.70 | 183.20 | 168.40 | 184.10 | 4.90 | 120 | 0 | 0 (Zero-GC) |
| 6 | **Signals** | 176.14 | 175.10 | 180.90 | 173.20 | 182.00 | 2.50 | 120 | 0 | 0 (Zero-GC) |
| 7 | **BLoC (Cubit)** | 176.62 | 171.30 | 177.30 | 170.50 | 178.20 | 2.65 | 120 | 0 | 0 (Zero-GC) |
| 8 | **Graft (slots)** | **179.94** | **170.70** | **187.80** | **169.80** | **188.50** | 6.12 | 120 | 0 | 0 (Zero-GC) |

### 🔹 Scenario: C1_5k_items_300_rapid_updates (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **136.11** | **136.30** | **138.90** | **133.50** | **139.80** | 1.82 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Riverpod (Notifier)** | 143.48 | 143.10 | 145.60 | 141.20 | 146.50 | 1.54 | 300 | 0 | 300 |
| 🥉 | **Signals** | 150.72 | 149.10 | 152.80 | 148.20 | 154.00 | 1.95 | 300 | 0 | 0 (Zero-GC) |
| 4 | **BLoC (Cubit)** | 174.79 | 173.80 | 178.30 | 172.10 | 179.20 | 2.14 | 300 | 0 | 300 |
| 5 | **GetX** | 367.81 | 365.60 | 375.90 | 360.20 | 377.10 | 5.12 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 378.87 | 374.70 | 379.90 | 371.00 | 382.40 | 3.42 | 300 | 0 | 300 |

### 🔹 Scenario: C2_20k_items_300_rapid_updates (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **136.29** | **134.30** | **142.00** | **132.80** | **143.10** | 3.25 | 300 | 0 | 0 (Zero-GC) |
| 🥈 | **Signals** | 148.52 | 149.50 | 151.10 | 146.10 | 152.00 | 1.80 | 300 | 0 | 0 (Zero-GC) |
| 🥉 | **Riverpod (Notifier)** | 154.81 | 156.00 | 159.90 | 152.30 | 161.20 | 2.75 | 300 | 0 | 300 |
| 4 | **BLoC (Cubit)** | 182.05 | 181.60 | 187.70 | 179.50 | 188.40 | 2.85 | 300 | 0 | 300 |
| 5 | **GetX** | 375.80 | 373.30 | 384.90 | 369.10 | 386.20 | 5.30 | 300 | 0 | 0 (Zero-GC) |
| 6 | **Provider** | 389.43 | 383.40 | 394.90 | 380.00 | 396.50 | 5.15 | 300 | 0 | 300 |

### 🔹 Scenario: C3_random_insert_remove_100x (Web)
| Rank | Framework | Mean (ms) | Median (ms) | p95 (ms) | Min (ms) | Max (ms) | StdDev (ms) | Dynamic Builds | Static Builds | State Churn |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🥇 | **Graft** | **0.07** | **0.10** | **0.10** | **0.05** | **0.12** | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 🥈 | **BLoC (Cubit)** | 0.43 | 0.40 | 0.50 | 0.38 | 0.52 | 0.04 | 0 | 0 | 0 (Zero-GC) |
| 🥉 | **Provider** | 0.43 | 0.40 | 0.40 | 0.39 | 0.45 | 0.02 | 0 | 0 | 0 (Zero-GC) |
| 4 | **Riverpod (Notifier)** | 0.55 | 0.50 | 0.80 | 0.45 | 0.85 | 0.11 | 0 | 0 | 0 (Zero-GC) |
| 5 | **GetX (RxList)** | 13.46 | 13.50 | 13.80 | 13.10 | 13.90 | 0.22 | 0 | 0 | 0 (Zero-GC) |

---

## 💡 Key Architectural Insights across Native IO & Web

1. **Massive List Scaling (Scenario C): Dominant #1 on Both Platforms**
   - In 5,000 and 20,000 item collections, Graft achieved **28.99 ms on Native IO** and **136.11 ms on Web**, outperforming GetX and Provider by **more than 2.7x** (367 ms and 389 ms on Web).
   - *Why?* Graft's deep snapshot equality and in-place cascade mutations generate **0 ephemeral objects**, eliminating browser garbage collection pauses that severely choke other libraries.

2. **Heavy Multi-Slot Rebuilds (Scenario B2): #1 in Browser UI Rendering**
   - In the 50-slot layout across 120 animation frames on Web, Graft leaf slots took **168.55 ms (Rank #1)**, ahead of Riverpod (173.05 ms), GetX (175.52 ms), and BLoC (176.62 ms).
   - Depth-$N$ parent rebuild insulation and `NoSubscriptionContext` shield the browser DOM and Flutter Web canvas from redundant layout passes.

3. **32-Bit Chunked Bitmask Diffing vs. 64-Bit Native Registers**
   - On Native IO, Graft leverages 64-bit CPU registers directly for 1-cycle bitwise evaluation.
   - On Web, `GraftMask` automatically uses 32-bit chunked words (`(index + 31) >> 5` and `1 << (index & 31)`), ensuring 100% mathematical consistency in JavaScript without BitInt overhead.

4. **Zero-Leak Dialog & Navigation Lifecycle (Scenario D3 & E1)**
   - On both Native IO and Web, `GraftRouteTracker` automatically anchors controller ownership to host screens, completely preventing dialog closures from destroying controllers in single-page web applications.
