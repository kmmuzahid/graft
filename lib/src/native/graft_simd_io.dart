import 'dart:ffi';
import 'dart:io';
import '../core/graft_mask.dart';

part 'graft_simd_bindings.dart';

/// Optional native SIMD hardware accelerator for massive states (1,000+ fields).
abstract final class GraftSimd {
  static DynamicLibrary? _dylib;
  static _DartDiffProps? _nativeDiff;
  static _DartVersion? _nativeVersion;
  static bool _initialized = false;
  static _DartMalloc? _malloc;
  static _DartFree? _free;

  /// Returns the underlying native dynamic library, or null if running pure Dart fallback.
  static DynamicLibrary? get dylib => _dylib;

  /// Returns true if the hardware SIMD native library is loaded and active.
  static bool get isAvailable {
    _ensureInitialized();
    return _nativeDiff != null;
  }

  /// Returns the native SIMD engine version code, or -1 if pure Dart fallback.
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
    _initSimdPlatform(
      _bind,
      () {
        _dylib = null;
        _nativeDiff = null;
      },
    );
  }

  static void _bind(DynamicLibrary lib) {
    try {
      _nativeDiff = lib.lookupFunction<_NativeDiffProps, _DartDiffProps>(
          'graft_simd_diff_props');
      _nativeVersion = lib
          .lookupFunction<_NativeVersion, _DartVersion>('graft_simd_version');
      _dylib = lib;
    } catch (_) {
      _nativeDiff = null;
      _nativeVersion = null;
    }
  }

  static void _ensureMemoryBindings() {
    if (_malloc != null) return;
    try {
      final libc = Platform.isWindows
          ? DynamicLibrary.open('msvcrt.dll')
          : DynamicLibrary.process();
      _malloc = libc.lookupFunction<_NativeMalloc, _DartMalloc>('malloc');
      _free = libc.lookupFunction<_NativeFree, _DartFree>('free');
    } catch (_) {
      // Memory allocation fallback unavailable
    }
  }

  /// Compares two integer property buffers using SIMD acceleration or 64-bit Dart VM fast path.
  static GraftMask diffInt64(List<int> oldProps, List<int> newProps) {
    final count =
        oldProps.length < newProps.length ? oldProps.length : newProps.length;
    if (count <= 0) return GraftMask.empty;

    _ensureMemoryBindings();

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
  static GraftMask _diffPureDart(
      List<int> oldProps, List<int> newProps, int count) {
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
