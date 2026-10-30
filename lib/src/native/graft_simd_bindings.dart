part of 'graft_simd_io.dart';

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

typedef _NativeMalloc = Pointer<Void> Function(IntPtr size);
typedef _DartMalloc = Pointer<Void> Function(int size);

typedef _NativeFree = Void Function(Pointer<Void> ptr);
typedef _DartFree = void Function(Pointer<Void> ptr);

void _initSimdPlatform(
  void Function(DynamicLibrary lib) onBind,
  void Function() onFallback,
) {
  try {
    DynamicLibrary? lib;
    if (Platform.isMacOS) {
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
      onBind(lib);
    }
  } catch (_) {
    onFallback();
  }
}

