part of 'dry_state_hook.dart';

Object? _hydrateValue(Object? defaultVal, Object? cachedVal) {
  if (defaultVal is GraftModel && cachedVal is List) {
    if (defaultVal.factory != null) {
      final subProps = defaultVal.props;
      final subArgs = <Object?>[];
      for (int j = 0; j < subProps.length && j < cachedVal.length; j++) {
        subArgs.add(_hydrateValue(subProps[j], cachedVal[j]));
      }
      return Function.apply(defaultVal.factory!, subArgs);
    }
    return defaultVal;
  }
  if (defaultVal is List && cachedVal is List) {
    if (defaultVal is List<String>) {
      return cachedVal.cast<String>();
    } else if (defaultVal is List<int>) {
      return cachedVal.cast<int>();
    } else if (defaultVal is List<double>) {
      return cachedVal.map((e) => (e as num).toDouble()).toList();
    } else if (defaultVal is List<num>) {
      return cachedVal.cast<num>();
    } else if (defaultVal is List<bool>) {
      return cachedVal.cast<bool>();
    }
    return cachedVal;
  }
  return cachedVal;
}

