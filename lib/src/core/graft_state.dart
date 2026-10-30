import 'package:flutter/foundation.dart';

import 'graft.dart';
import 'graft_async.dart';
import 'graft_change.dart';
import 'graft_mask.dart';
import '../persistence/dry/dry_state_hook.dart';
import '../persistence/model/graft_model.dart';

part 'state/graft_props_types.dart';
part 'state/graft_state_storage.dart';
part 'state/graft_state_props.dart';
part 'state/graft_state_baseline.dart';
part 'state/graft_state_snapshot.dart';
part 'state/graft_state_collection_diff.dart';
part 'state/graft_state_diff_helper.dart';
part 'state/graft_state_diff_single.dart';
part 'state/graft_state_diff_dual.dart';
part 'state/graft_state_diff_triple.dart';
part 'state/graft_state_diff_quad.dart';
part 'state/graft_state_diff_penta.dart';
part 'state/graft_state_diff_general.dart';
part 'state/graft_state_diff_engine.dart';
part 'state/graft_state_fast_scalar.dart';
part 'state/graft_state_fast_buffer.dart';
part 'state/graft_state_fast_nested.dart';
part 'state/graft_state_dispatch.dart';
part 'state/graft_state_engine.dart';

const Object _undefined = _Sentinel();

/// Base class for domain states that enables direct cascade mutation with zero boilerplate.
abstract class GraftState extends GraftStateStorage with GraftStateProps {
  /// Identity hash code for the state instance.
  @override
  int get hashCode => identityHashCode(this);

  /// Equality is instance identity.
  @override
  bool operator ==(Object other) => identical(this, other);

  /// Unique domain state persistence identifier used by DRY storage engines.
  String get dryKey => _customDryKey ?? runtimeType.toString();

  /// Schema version for DRY schema migration. Defaults to 0.
  int get schemaVersion => 0;

  /// Invalidates this state in the active DRY storage cache.
  void invalidateDry() => DryStateHook.invalidate(this);

  /// Current dirty mask for this state.
  GraftMask get dirtyMask => _dirtyMask;

  /// Hardware-aligned domain property container.
  @protected
  GraftProps get props;

  @pragma('vm:prefer-inline')
  void _bindGraft(Graft graft) {
    _graft = graft;
    _initBaseline();
  }

  @pragma('vm:prefer-inline')
  void _initBaseline() => _initBaselineImpl(this);

  List<Object?> get _baselineSnapshot => _getBaselineSnapshot(this);

  @pragma('vm:prefer-inline')
  GraftMask _diffChanges() => _stateDiffChanges(this);

  /// Triggers fine-grained slot diffing and notifies all listeners synchronously.
  @nonVirtual
  @pragma('vm:prefer-inline')
  void update({int? itemIndex}) => _stateUpdate(this, itemIndex: itemIndex);

  /// Resets this state by invoking [onReset] and triggering fine-grained diffing synchronously.
  @nonVirtual
  void reset() {
    _baseline = null;
    _singleBaseline = _undefined;
    _dirtyMask = GraftMask.allDirty;
    onReset();
    update();
  }

  /// Optional lifecycle hook called during [reset] to restore domain field values.
  @protected
  void onReset() {}
}
