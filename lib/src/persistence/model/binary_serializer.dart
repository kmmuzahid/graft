/// Ultra-fast binary serializer for state props and GraftModel entities.
library;

import 'dart:convert';
import 'dart:typed_data';
import '../../core/graft_state.dart';
import 'graft_model.dart';

/// Serializes and deserializes GraftProps tuples and nested models to/from binary bytes.
final class BinarySerializer {
  BinarySerializer._();

  /// Encodes [props] with its schema [fingerprint] into a compact [Uint8List].
  static Uint8List encode(GraftProps props, int fingerprint) {
    final builder = BytesBuilder(copy: false);
    final header = ByteData(7);
    header.setInt32(0, fingerprint);
    header.setUint8(4, 1); // Format version
    header.setUint16(5, props.length);
    builder.add(header.buffer.asUint8List());

    for (final item in props) {
      _writeField(builder, item);
    }
    return builder.takeBytes();
  }

  static void _writeField(BytesBuilder builder, Object? val) {
    if (val == null) {
      builder.addByte(0);
    } else if (val is bool) {
      builder.addByte(val ? 1 : 2);
    } else if (val is int) {
      final bd = ByteData(9);
      bd.setUint8(0, 3);
      bd.setInt64(1, val);
      builder.add(bd.buffer.asUint8List());
    } else if (val is double) {
      final bd = ByteData(9);
      bd.setUint8(0, 4);
      bd.setFloat64(1, val);
      builder.add(bd.buffer.asUint8List());
    } else if (val is String) {
      final utf8Bytes = utf8.encode(val);
      final bd = ByteData(3);
      bd.setUint8(0, 5);
      bd.setUint16(1, utf8Bytes.length);
      builder.add(bd.buffer.asUint8List());
      builder.add(utf8Bytes);
    } else if (val is GraftModel) {
      _writeProps(builder, val.props);
    } else if (val is GraftProps) {
      _writeProps(builder, val);
    } else if (val is List) {
      final bd = ByteData(3);
      bd.setUint8(0, 6);
      bd.setUint16(1, val.length);
      builder.add(bd.buffer.asUint8List());
      for (final item in val) {
        _writeField(builder, item);
      }
    } else {
      final utf8Bytes = utf8.encode(val.toString());
      final bd = ByteData(3);
      bd.setUint8(0, 5);
      bd.setUint16(1, utf8Bytes.length);
      builder.add(bd.buffer.asUint8List());
      builder.add(utf8Bytes);
    }
  }

  static void _writeProps(BytesBuilder builder, GraftProps props) {
    final bd = ByteData(3);
    bd.setUint8(0, 6);
    bd.setUint16(1, props.length);
    builder.add(bd.buffer.asUint8List());
    for (final item in props) {
      _writeField(builder, item);
    }
  }

  /// Decodes [bytes] into a schema fingerprint and list of unpacked data, or null on error.
  static ({int fingerprint, List<Object?> data})? decode(Uint8List bytes) {
    if (bytes.length < 7) return null;
    try {
      final bd = ByteData.sublistView(bytes);
      final fp = bd.getInt32(0);
      final count = bd.getUint16(5);
      int offset = 7;
      final list = <Object?>[];

      for (int i = 0; i < count; i++) {
        if (offset >= bytes.length) break;
        final (val, newOffset) = _readField(bytes, bd, offset);
        list.add(val);
        offset = newOffset;
      }
      return (fingerprint: fp, data: list);
    } catch (_) {
      return null;
    }
  }

  static (Object?, int) _readField(Uint8List bytes, ByteData bd, int offset) {
    final tag = bytes[offset++];
    switch (tag) {
      case 0: return (null, offset);
      case 1: return (true, offset);
      case 2: return (false, offset);
      case 3:
        final val = bd.getInt64(offset);
        return (val, offset + 8);
      case 4:
        final val = bd.getFloat64(offset);
        return (val, offset + 8);
      case 5:
        final len = bd.getUint16(offset);
        offset += 2;
        final str = utf8.decode(bytes.sublist(offset, offset + len));
        return (str, offset + len);
      case 6:
        final len = bd.getUint16(offset);
        offset += 2;
        final subList = <Object?>[];
        for (int i = 0; i < len; i++) {
          final (subVal, newOff) = _readField(bytes, bd, offset);
          subList.add(subVal);
          offset = newOff;
        }
        return (subList, offset);
      default:
        return (null, offset);
    }
  }
}
