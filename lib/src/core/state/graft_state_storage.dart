part of '../graft_state.dart';

@internal
abstract class GraftStateStorage {
  Graft? _graft;
  int _version = 0;
  GraftMask _dirtyMask = GraftMask.allDirty;

  List<Object?>? _baseline;
  Object? _singleBaseline = _undefined;
  bool _baselineNeedsSync = false;
  int _prevListLength = -1;
  bool _hasAsyncProps = false;
  bool _isDryEnabled = false;
  String? _customDryKey;

  Object? _b0, _b1, _b2, _b3, _b4;
  Object? _s0, _s1, _s2, _s3, _s4;
  int _scalarCount = 0;
  bool _allScalarProps = false;
  List<int>? _nestedVersions;
  GraftState? _leafState;
  int _singleNestedVersion = -1;

  List<Object?>? _propsBuffer;
  _GraftPropsBuffer? _propsView;
  _GraftPropsSingle? _singleView;
  Object? _pendingSingle = _undefined;
  GraftFastReceiver? _fastReceiver;
}
