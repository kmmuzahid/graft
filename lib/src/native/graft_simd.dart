import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import '../core/graft_mask.dart';

typedef _NativeDiffProps = Int32 Function(
  Pointer<Int64> oldProps,
  Pointer<Int64> newProps,
  Int64 count,
  Pointer<Uint64> outDirtyWords,
);

typedef _DartDiffProps = int Function(
  Pointer<Int64> oldProps,
  Pointer<Int64> newProps,
  int count,
  Pointer<Uint64> outDirtyWords,
);

typedef _NativeVersion = Int32 Function();
typedef _DartVersion = int Function();

/// Optional native SIMD hardware accelerator for massive states (1,000+ fields).
///
/// Seamlessly utilizes ARM Neon (`vceqq_u64`) and x86 AVX2/SSE4 vector instructions
/// via `dart:ffi`. When the native dynamic library is absent, transparently
/// falls back to Graft's pure Dart 64-bit register bitmask engine with 0 behavioral divergence.
class GraftSimd {
  static DynamicLibrary? _dylib;
  static _DartDiffProps? _nativeDiff;
  static _DartVersion? _nativeVersion;
  static bool _initialized = false;

  /// Returns the underlying native dynamic library, or null if running pure Dart fallback.
  static DynamicLibrary? get dylib => _dylib;

  /// Returns true if the hardware SIMD native library is loaded and active.
  static bool get isAvailable {
    _ensureInitialized();
    return _nativeDiff != null;
  }

  /// Returns the native SIMD engine version code (e.g. 100 for 1.0.0), or -1 if pure Dart fallback.
  static int get version {
    _ensureInitialized();
    return _nativeVersion?.call() ?? -1;
  }

  /// Manually initializes the SIMD engine from a custom dynamic library path.
  static bool loadFrom(String dylibPath) {
    try {
      final lib = DynamicLibrary.open(dylibPath);
      _bind(lib);
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    try {
      DynamicLibrary? lib;
      if (Platform.isMacOS) {
        // Look in local bundle, native/bin, or standard library paths
        final candidatePaths = [
          'native/bin/libgraft_simd.dylib',
          'libgraft_simd.dylib',
        ];
        for (final p in candidatePaths) {
          if (File(p).existsSync()) {
            lib = DynamicLibrary.open(p);
            break;
          }
        }
        lib ??= DynamicLibrary.process();
      } else if (Platform.isLinux || Platform.isAndroid) {
        final candidatePaths = [
          'native/bin/libgraft_simd.so',
          'libgraft_simd.so',
        ];
        for (final p in candidatePaths) {
          if (File(p).existsSync()) {
            lib = DynamicLibrary.open(p);
            break;
          }
        }
        lib ??= DynamicLibrary.process();
      } else if (Platform.isWindows) {
        final candidatePaths = [
          'native/bin/graft_simd.dll',
          'graft_simd.dll',
        ];
        for (final p in candidatePaths) {
          if (File(p).existsSync()) {
            lib = DynamicLibrary.open(p);
            break;
          }
        }
      }

      if (lib != null) {
        _bind(lib);
      }
    } catch (_) {
      // Graceful fallback to pure Dart register engine
      _dylib = null;
      _nativeDiff = null;
    }
  }

  static void _bind(DynamicLibrary lib) {
    try {
      _nativeDiff = lib
          .lookupFunction<_NativeDiffProps, _DartDiffProps>('graft_simd_diff_props');
      _nativeVersion = lib
          .lookupFunction<_NativeVersion, _DartVersion>('graft_simd_version');
      _dylib = lib;
    } catch (_) {
      _nativeDiff = null;
      _nativeVersion = null;
    }
  }

  static _DartMalloc? _malloc;
  static _DartFree? _free;

  static void _ensureMemoryBindings() {
    if (_malloc != null) return;
    try {
      final libc = Platform.isWindows ? DynamicLibrary.open('msvcrt.dll') : DynamicLibrary.process();
      _malloc = libc.lookupFunction<_NativeMalloc, _DartMalloc>('malloc');
      _free = libc.lookupFunction<_NativeFree, _DartFree>('free');
    } catch (_) {
      // Memory allocation fallback unavailable
    }
  }

  /// Compares two 64-bit integer property buffers using SIMD acceleration.
  ///
  /// Returns a [GraftMask] bitset where dirty indices are set to 1.
  static GraftMask diffInt64(Int64List oldProps, Int64List newProps) {
    final count = oldProps.length < newProps.length ? oldProps.length : newProps.length;
    if (count <= 0) return GraftMask.empty;

    _ensureMemoryBindings();

    // Use pure Dart fast path if count is small (< 64 elements) or native lib is unavailable
    if (count <= 64 || !isAvailable || _malloc == null || _free == null) {
      return _diffPureDart(oldProps, newProps, count);
    }

    final numWords = (count + 63) >> 6;
    final oldPtr = _malloc!(count * 8).cast<Int64>();
    final newPtr = _malloc!(count * 8).cast<Int64>();
    final outPtr = _malloc!(numWords * 8).cast<Uint64>();

    try {
      for (int i = 0; i < count; i++) {
        oldPtr[i] = oldProps[i];
        newPtr[i] = newProps[i];
      }

      final hasDiff = _nativeDiff!(oldPtr, newPtr, count, outPtr);
      if (hasDiff == 0) return GraftMask.empty;

      final words = List<int>.generate(numWords, (i) => outPtr[i]);
      return _maskFromWords64(words);
    } finally {
      _free!(oldPtr.cast());
      _free!(newPtr.cast());
      _free!(outPtr.cast());
    }
  }

  /// Pure Dart fallback implementation for bitmask diffing
  static GraftMask _diffPureDart(Int64List oldProps, Int64List newProps, int count) {
    final numWords = (count + 63) >> 6;
    final words = List<int>.filled(numWords, 0);
    bool hasDiff = false;

    for (int i = 0; i < count; i++) {
      if (oldProps[i] != newProps[i]) {
        words[i >> 6] |= (1 << (i & 63));
        hasDiff = true;
      }
    }

    if (!hasDiff) return GraftMask.empty;
    return _maskFromWords64(words);
  }

  static GraftMask _maskFromWords64(List<int> words64) {
    if (words64.isEmpty) return GraftMask.empty;
    final w0 = words64[0] & 0xFFFFFFFF;
    final w1 = (words64[0] >> 32) & 0xFFFFFFFF;
    List<int>? extra;
    if (words64.length > 1) {
      extra = <int>[];
      for (int i = 1; i < words64.length; i++) {
        extra.add(words64[i] & 0xFFFFFFFF);
        extra.add((words64[i] >> 32) & 0xFFFFFFFF);
      }
    }
    return GraftMask.fromWords(w0, w1, extra);
  }
}

typedef _NativeMalloc = Pointer<Void> Function(IntPtr size);
typedef _DartMalloc = Pointer<Void> Function(int size);

typedef _NativeFree = Void Function(Pointer<Void> ptr);
typedef _DartFree = void Function(Pointer<Void> ptr);
