// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerformanceSet {

 String get id; String get workoutExerciseId; int get setNumber; double? get weightKg; int? get reps; int? get durationMs; double? get distanceM; int? get calories; double? get rpe; bool get isWarmup;
/// Create a copy of PerformanceSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceSetCopyWith<PerformanceSet> get copyWith => _$PerformanceSetCopyWithImpl<PerformanceSet>(this as PerformanceSet, _$identity);

  /// Serializes this PerformanceSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PerformanceSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceSet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.workoutExerciseId, _this.workoutExerciseId) || other.workoutExerciseId == _this.workoutExerciseId)&&(identical(other.setNumber, _this.setNumber) || other.setNumber == _this.setNumber)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.distanceM, _this.distanceM) || other.distanceM == _this.distanceM)&&(identical(other.calories, _this.calories) || other.calories == _this.calories)&&(identical(other.rpe, _this.rpe) || other.rpe == _this.rpe)&&(identical(other.isWarmup, _this.isWarmup) || other.isWarmup == _this.isWarmup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PerformanceSet;
  return Object.hash(runtimeType,_this.id,_this.workoutExerciseId,_this.setNumber,_this.weightKg,_this.reps,_this.durationMs,_this.distanceM,_this.calories,_this.rpe,_this.isWarmup);
}

@override
String toString() {
  final _this = this as PerformanceSet;
  return 'PerformanceSet(id: ${_this.id}, workoutExerciseId: ${_this.workoutExerciseId}, setNumber: ${_this.setNumber}, weightKg: ${_this.weightKg}, reps: ${_this.reps}, durationMs: ${_this.durationMs}, distanceM: ${_this.distanceM}, calories: ${_this.calories}, rpe: ${_this.rpe}, isWarmup: ${_this.isWarmup})';
}


}

/// @nodoc
abstract mixin class $PerformanceSetCopyWith<$Res>  {
  factory $PerformanceSetCopyWith(PerformanceSet value, $Res Function(PerformanceSet) _then) = _$PerformanceSetCopyWithImpl;
@useResult
$Res call({
 String id, String workoutExerciseId, int setNumber, double? weightKg, int? reps, int? durationMs, double? distanceM, int? calories, double? rpe, bool isWarmup
});




}
/// @nodoc
class _$PerformanceSetCopyWithImpl<$Res>
    implements $PerformanceSetCopyWith<$Res> {
  _$PerformanceSetCopyWithImpl(this._self, this._then);

  final PerformanceSet _self;
  final $Res Function(PerformanceSet) _then;

/// Create a copy of PerformanceSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutExerciseId = null,Object? setNumber = null,Object? weightKg = freezed,Object? reps = freezed,Object? durationMs = freezed,Object? distanceM = freezed,Object? calories = freezed,Object? rpe = freezed,Object? isWarmup = null,}) {
  return _then(PerformanceSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceSet].
extension PerformanceSetPatterns on PerformanceSet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceSet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceSet value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceSet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceSet value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceSet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutExerciseId,  int setNumber,  double? weightKg,  int? reps,  int? durationMs,  double? distanceM,  int? calories,  double? rpe,  bool isWarmup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceSet() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.weightKg,_that.reps,_that.durationMs,_that.distanceM,_that.calories,_that.rpe,_that.isWarmup);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutExerciseId,  int setNumber,  double? weightKg,  int? reps,  int? durationMs,  double? distanceM,  int? calories,  double? rpe,  bool isWarmup)  $default,) {final _that = this;
switch (_that) {
case _PerformanceSet():
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.weightKg,_that.reps,_that.durationMs,_that.distanceM,_that.calories,_that.rpe,_that.isWarmup);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutExerciseId,  int setNumber,  double? weightKg,  int? reps,  int? durationMs,  double? distanceM,  int? calories,  double? rpe,  bool isWarmup)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceSet() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.weightKg,_that.reps,_that.durationMs,_that.distanceM,_that.calories,_that.rpe,_that.isWarmup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceSet implements PerformanceSet {
  const _PerformanceSet({required this.id, required this.workoutExerciseId, required this.setNumber, this.weightKg, this.reps, this.durationMs, this.distanceM, this.calories, this.rpe, this.isWarmup = false});
  factory _PerformanceSet.fromJson(Map<String, dynamic> json) => _$PerformanceSetFromJson(json);

@override final  String id;
@override final  String workoutExerciseId;
@override final  int setNumber;
@override final  double? weightKg;
@override final  int? reps;
@override final  int? durationMs;
@override final  double? distanceM;
@override final  int? calories;
@override final  double? rpe;
@override@JsonKey() final  bool isWarmup;

/// Create a copy of PerformanceSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceSetCopyWith<_PerformanceSet> get copyWith => __$PerformanceSetCopyWithImpl<_PerformanceSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceSet&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutExerciseId, workoutExerciseId) || other.workoutExerciseId == workoutExerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,workoutExerciseId,setNumber,weightKg,reps,durationMs,distanceM,calories,rpe,isWarmup);
}

@override
String toString() {
    return 'PerformanceSet(id: $id, workoutExerciseId: $workoutExerciseId, setNumber: $setNumber, weightKg: $weightKg, reps: $reps, durationMs: $durationMs, distanceM: $distanceM, calories: $calories, rpe: $rpe, isWarmup: $isWarmup)';
}


}

/// @nodoc
abstract mixin class _$PerformanceSetCopyWith<$Res> implements $PerformanceSetCopyWith<$Res> {
  factory _$PerformanceSetCopyWith(_PerformanceSet value, $Res Function(_PerformanceSet) _then) = __$PerformanceSetCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutExerciseId, int setNumber, double? weightKg, int? reps, int? durationMs, double? distanceM, int? calories, double? rpe, bool isWarmup
});




}
/// @nodoc
class __$PerformanceSetCopyWithImpl<$Res>
    implements _$PerformanceSetCopyWith<$Res> {
  __$PerformanceSetCopyWithImpl(this._self, this._then);

  final _PerformanceSet _self;
  final $Res Function(_PerformanceSet) _then;

/// Create a copy of PerformanceSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutExerciseId = null,Object? setNumber = null,Object? weightKg = freezed,Object? reps = freezed,Object? durationMs = freezed,Object? distanceM = freezed,Object? calories = freezed,Object? rpe = freezed,Object? isWarmup = null,}) {
  return _then(_PerformanceSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as double?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PerformanceAttempt {

 String get id; String get workoutExerciseId; int get attemptNumber; double get targetWeightKg; bool get success; DateTime get performedAt;
/// Create a copy of PerformanceAttempt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceAttemptCopyWith<PerformanceAttempt> get copyWith => _$PerformanceAttemptCopyWithImpl<PerformanceAttempt>(this as PerformanceAttempt, _$identity);

  /// Serializes this PerformanceAttempt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PerformanceAttempt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceAttempt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.workoutExerciseId, _this.workoutExerciseId) || other.workoutExerciseId == _this.workoutExerciseId)&&(identical(other.attemptNumber, _this.attemptNumber) || other.attemptNumber == _this.attemptNumber)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.performedAt, _this.performedAt) || other.performedAt == _this.performedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PerformanceAttempt;
  return Object.hash(runtimeType,_this.id,_this.workoutExerciseId,_this.attemptNumber,_this.targetWeightKg,_this.success,_this.performedAt);
}

@override
String toString() {
  final _this = this as PerformanceAttempt;
  return 'PerformanceAttempt(id: ${_this.id}, workoutExerciseId: ${_this.workoutExerciseId}, attemptNumber: ${_this.attemptNumber}, targetWeightKg: ${_this.targetWeightKg}, success: ${_this.success}, performedAt: ${_this.performedAt})';
}


}

/// @nodoc
abstract mixin class $PerformanceAttemptCopyWith<$Res>  {
  factory $PerformanceAttemptCopyWith(PerformanceAttempt value, $Res Function(PerformanceAttempt) _then) = _$PerformanceAttemptCopyWithImpl;
@useResult
$Res call({
 String id, String workoutExerciseId, int attemptNumber, double targetWeightKg, bool success, DateTime performedAt
});




}
/// @nodoc
class _$PerformanceAttemptCopyWithImpl<$Res>
    implements $PerformanceAttemptCopyWith<$Res> {
  _$PerformanceAttemptCopyWithImpl(this._self, this._then);

  final PerformanceAttempt _self;
  final $Res Function(PerformanceAttempt) _then;

/// Create a copy of PerformanceAttempt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutExerciseId = null,Object? attemptNumber = null,Object? targetWeightKg = null,Object? success = null,Object? performedAt = null,}) {
  return _then(PerformanceAttempt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,attemptNumber: null == attemptNumber ? _self.attemptNumber : attemptNumber // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceAttempt].
extension PerformanceAttemptPatterns on PerformanceAttempt {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceAttempt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceAttempt() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceAttempt value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceAttempt():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceAttempt value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceAttempt() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutExerciseId,  int attemptNumber,  double targetWeightKg,  bool success,  DateTime performedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceAttempt() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.attemptNumber,_that.targetWeightKg,_that.success,_that.performedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutExerciseId,  int attemptNumber,  double targetWeightKg,  bool success,  DateTime performedAt)  $default,) {final _that = this;
switch (_that) {
case _PerformanceAttempt():
return $default(_that.id,_that.workoutExerciseId,_that.attemptNumber,_that.targetWeightKg,_that.success,_that.performedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutExerciseId,  int attemptNumber,  double targetWeightKg,  bool success,  DateTime performedAt)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceAttempt() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.attemptNumber,_that.targetWeightKg,_that.success,_that.performedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceAttempt implements PerformanceAttempt {
  const _PerformanceAttempt({required this.id, required this.workoutExerciseId, required this.attemptNumber, required this.targetWeightKg, required this.success, required this.performedAt});
  factory _PerformanceAttempt.fromJson(Map<String, dynamic> json) => _$PerformanceAttemptFromJson(json);

@override final  String id;
@override final  String workoutExerciseId;
@override final  int attemptNumber;
@override final  double targetWeightKg;
@override final  bool success;
@override final  DateTime performedAt;

/// Create a copy of PerformanceAttempt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceAttemptCopyWith<_PerformanceAttempt> get copyWith => __$PerformanceAttemptCopyWithImpl<_PerformanceAttempt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceAttemptToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceAttempt&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutExerciseId, workoutExerciseId) || other.workoutExerciseId == workoutExerciseId)&&(identical(other.attemptNumber, attemptNumber) || other.attemptNumber == attemptNumber)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.success, success) || other.success == success)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,workoutExerciseId,attemptNumber,targetWeightKg,success,performedAt);
}

@override
String toString() {
    return 'PerformanceAttempt(id: $id, workoutExerciseId: $workoutExerciseId, attemptNumber: $attemptNumber, targetWeightKg: $targetWeightKg, success: $success, performedAt: $performedAt)';
}


}

/// @nodoc
abstract mixin class _$PerformanceAttemptCopyWith<$Res> implements $PerformanceAttemptCopyWith<$Res> {
  factory _$PerformanceAttemptCopyWith(_PerformanceAttempt value, $Res Function(_PerformanceAttempt) _then) = __$PerformanceAttemptCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutExerciseId, int attemptNumber, double targetWeightKg, bool success, DateTime performedAt
});




}
/// @nodoc
class __$PerformanceAttemptCopyWithImpl<$Res>
    implements _$PerformanceAttemptCopyWith<$Res> {
  __$PerformanceAttemptCopyWithImpl(this._self, this._then);

  final _PerformanceAttempt _self;
  final $Res Function(_PerformanceAttempt) _then;

/// Create a copy of PerformanceAttempt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutExerciseId = null,Object? attemptNumber = null,Object? targetWeightKg = null,Object? success = null,Object? performedAt = null,}) {
  return _then(_PerformanceAttempt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,attemptNumber: null == attemptNumber ? _self.attemptNumber : attemptNumber // ignore: cast_nullable_to_non_nullable
as int,targetWeightKg: null == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
