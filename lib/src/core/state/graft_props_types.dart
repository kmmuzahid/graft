part of '../graft_state.dart';

class _Sentinel {
  const _Sentinel();
}

abstract final class GraftProps extends Iterable<Object?> {
  const GraftProps();
  factory GraftProps.fromList(List<Object?> list) => _GraftPropsList(list);

  Object? operator [](int index);
  @override
  int get length;
  @override
  bool get isEmpty => length == 0;
  @override
  bool get isNotEmpty => length > 0;
}

final class _GraftPropsList extends GraftProps {
  final List<Object?> _list;
  const _GraftPropsList(this._list);

  @override
  Object? operator [](int index) => _list[index];
  @override
  int get length => _list.length;
  @override
  Iterator<Object?> get iterator => _list.iterator;
}

final class _EmptyGraftProps extends GraftProps {
  const _EmptyGraftProps();

  @override
  Object? operator [](int index) => throw RangeError.index(index, this);
  @override
  int get length => 0;
  @override
  Iterator<Object?> get iterator => const <Object?>[].iterator;
}

final class _GraftPropsBuffer extends GraftProps {
  final GraftStateStorage _state;
  final List<Object?> _buffer;
  final int _length;

  const _GraftPropsBuffer(this._state, this._buffer, this._length);

  @override
  Object? operator [](int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this);
    }
    if (_state._scalarCount >= 2 && _state._scalarCount <= 5) {
      if (index == 0) return _state._s0;
      if (index == 1) return _state._s1;
      if (index == 2) return _state._s2;
      if (index == 3) return _state._s3;
      if (index == 4) return _state._s4;
    }
    return _buffer[index];
  }

  @override
  int get length => _length;

  @override
  Iterator<Object?> get iterator {
    if (_state._scalarCount >= 2 && _state._scalarCount <= 5) {
      _buffer[0] = _state._s0;
      _buffer[1] = _state._s1;
      if (_state._scalarCount > 2) _buffer[2] = _state._s2;
      if (_state._scalarCount > 3) _buffer[3] = _state._s3;
      if (_state._scalarCount > 4) _buffer[4] = _state._s4;
    }
    return _GraftPropsIterator(_buffer, _length);
  }
}

final class _GraftPropsIterator implements Iterator<Object?> {
  final List<Object?> _buffer;
  final int _length;
  int _index = -1;

  _GraftPropsIterator(this._buffer, this._length);

  @override
  Object? get current =>
      _index >= 0 && _index < _length ? _buffer[_index] : null;

  @override
  bool moveNext() {
    if (_index + 1 < _length) {
      _index++;
      return true;
    }
    return false;
  }
}

final class _GraftPropsListView extends GraftProps {
  List<Object?> _list;
  _GraftPropsListView(this._list);
  set list(List<Object?> l) => _list = l;

  @override
  Object? operator [](int index) => _list[index];
  @override
  int get length => _list.length;
  @override
  Iterator<Object?> get iterator => _list.iterator;
}

final class _GraftPropsSingle extends GraftProps {
  Object? value;
  _GraftPropsSingle(this.value);

  @override
  Object? operator [](int index) {
    if (index != 0) throw RangeError.index(index, this);
    return value;
  }

  @override
  int get length => 1;
  @override
  Iterator<Object?> get iterator => _SingleIterator(value);
}

final class _SingleIterator implements Iterator<Object?> {
  final Object? _value;
  bool _moved = false;
  _SingleIterator(this._value);

  @override
  Object? get current => _moved ? _value : null;

  @override
  bool moveNext() {
    if (!_moved) {
      _moved = true;
      return true;
    }
    return false;
  }
}
