/// Pure static tuple serializer for state props and GraftModel entities.
library;

import 'dart:convert';
import '../../core/graft_state.dart';
import 'graft_model.dart';

/// Serializes and deserializes GraftProps tuples and nested models to/from JSON.
final class TupleSerializer {
  TupleSerializer._();

  /// Serializes [props] recursively into a JSON-safe tuple [List<Object?>].
  static List<Object?> toTuple(GraftProps props) {
    final list = <Object?>[];
    for (final item in props) {
      list.add(_serializeValue(item));
    }
    return list;
  }

  static Object? _serializeValue(Object? value) {
    if (value == null || value is num || value is String || value is bool) {
      return value;
    }
    if (value is GraftModel) {
      return toTuple(value.props);
    }
    if (value is GraftProps) {
      return toTuple(value);
    }
    if (value is List) {
      return value.map(_serializeValue).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _serializeValue(v)));
    }
    if (value is Set) {
      return value.map(_serializeValue).toList();
    }
    return value.toString();
  }

  /// Encodes [props] with its [fingerprint] into a JSON string.
  static String encode(GraftProps props, int fingerprint) {
    final payload = {
      'f': fingerprint,
      'd': toTuple(props),
    };
    return jsonEncode(payload);
  }

  /// Decodes [jsonStr] returning the schema fingerprint and data tuple, or null on error.
  static ({int fingerprint, List<Object?> data})? decode(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr);
      if (map is Map) {
        final f = map['f'];
        final d = map['d'];
        if (f is int && d is List) {
          return (fingerprint: f, data: d.cast<Object?>());
        }
      }
    } catch (_) {
      // Corrupt or malformed json returns null
    }
    return null;
  }
}
