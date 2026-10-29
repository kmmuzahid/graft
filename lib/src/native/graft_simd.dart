/// Conditional export for GraftSimd hardware acceleration.
///
/// Automatically selects native FFI implementation on native platforms,
/// or pure Dart 64-bit fallback on Web and WASM.
library;

export 'graft_simd_io.dart' if (dart.library.js_interop) 'graft_simd_web.dart';
