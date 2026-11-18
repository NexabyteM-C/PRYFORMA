// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalRecord {

 String get id; String get athleteId; String get exerciseId; String? get variantId; String get recordType; double get valueNumeric; String? get resultSourceId; String get markType; DateTime get achievedAt; Exercise? get exercise;
/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalRecordCopyWith<PersonalRecord> get copyWith => _$PersonalRecordCopyWithImpl<PersonalRecord>(this as PersonalRecord, _$identity);

  /// Serializes this PersonalRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PersonalRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.athleteId, _this.athleteId) || other.athleteId == _this.athleteId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.recordType, _this.recordType) || other.recordType == _this.recordType)&&(identical(other.valueNumeric, _this.valueNumeric) || other.valueNumeric == _this.valueNumeric)&&(identical(other.resultSourceId, _this.resultSourceId) || other.resultSourceId == _this.resultSourceId)&&(identical(other.markType, _this.markType) || other.markType == _this.markType)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PersonalRecord;
  return Object.hash(runtimeType,_this.id,_this.athleteId,_this.exerciseId,_this.variantId,_this.recordType,_this.valueNumeric,_this.resultSourceId,_this.markType,_this.achievedAt,_this.exercise);
}

@override
String toString() {
  final _this = this as PersonalRecord;
  return 'PersonalRecord(id: ${_this.id}, athleteId: ${_this.athleteId}, exerciseId: ${_this.exerciseId}, variantId: ${_this.variantId}, recordType: ${_this.recordType}, valueNumeric: ${_this.valueNumeric}, resultSourceId: ${_this.resultSourceId}, markType: ${_this.markType}, achievedAt: ${_this.achievedAt}, exercise: ${_this.exercise})';
}


}

/// @nodoc
abstract mixin class $PersonalRecordCopyWith<$Res>  {
  factory $PersonalRecordCopyWith(PersonalRecord value, $Res Function(PersonalRecord) _then) = _$PersonalRecordCopyWithImpl;
@useResult
$Res call({
 String id, String athleteId, String exerciseId, String? variantId, String recordType, double valueNumeric, String? resultSourceId, String markType, DateTime achievedAt, Exercise? exercise
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$PersonalRecordCopyWithImpl<$Res>
    implements $PersonalRecordCopyWith<$Res> {
  _$PersonalRecordCopyWithImpl(this._self, this._then);

  final PersonalRecord _self;
  final $Res Function(PersonalRecord) _then;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? athleteId = null,Object? exerciseId = null,Object? variantId = freezed,Object? recordType = null,Object? valueNumeric = null,Object? resultSourceId = freezed,Object? markType = null,Object? achievedAt = null,Object? exercise = freezed,}) {
  return _then(PersonalRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,recordType: null == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as String,valueNumeric: null == valueNumeric ? _self.valueNumeric : valueNumeric // ignore: cast_nullable_to_non_nullable
as double,resultSourceId: freezed == resultSourceId ? _self.resultSourceId : resultSourceId // ignore: cast_nullable_to_non_nullable
as String?,markType: null == markType ? _self.markType : markType // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,
  ));
}
/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonalRecord].
extension PersonalRecordPatterns on PersonalRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalRecord value)  $default,){
final _that = this;
switch (_that) {
case _PersonalRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String athleteId,  String exerciseId,  String? variantId,  String recordType,  double valueNumeric,  String? resultSourceId,  String markType,  DateTime achievedAt,  Exercise? exercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.variantId,_that.recordType,_that.valueNumeric,_that.resultSourceId,_that.markType,_that.achievedAt,_that.exercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String athleteId,  String exerciseId,  String? variantId,  String recordType,  double valueNumeric,  String? resultSourceId,  String markType,  DateTime achievedAt,  Exercise? exercise)  $default,) {final _that = this;
switch (_that) {
case _PersonalRecord():
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.variantId,_that.recordType,_that.valueNumeric,_that.resultSourceId,_that.markType,_that.achievedAt,_that.exercise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String athleteId,  String exerciseId,  String? variantId,  String recordType,  double valueNumeric,  String? resultSourceId,  String markType,  DateTime achievedAt,  Exercise? exercise)?  $default,) {final _that = this;
switch (_that) {
case _PersonalRecord() when $default != null:
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.variantId,_that.recordType,_that.valueNumeric,_that.resultSourceId,_that.markType,_that.achievedAt,_that.exercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalRecord implements PersonalRecord {
  const _PersonalRecord({required this.id, required this.athleteId, required this.exerciseId, this.variantId, required this.recordType, required this.valueNumeric, this.resultSourceId, this.markType = 'real', required this.achievedAt, this.exercise});
  factory _PersonalRecord.fromJson(Map<String, dynamic> json) => _$PersonalRecordFromJson(json);

@override final  String id;
@override final  String athleteId;
@override final  String exerciseId;
@override final  String? variantId;
@override final  String recordType;
@override final  double valueNumeric;
@override final  String? resultSourceId;
@override@JsonKey() final  String markType;
@override final  DateTime achievedAt;
@override final  Exercise? exercise;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalRecordCopyWith<_PersonalRecord> get copyWith => __$PersonalRecordCopyWithImpl<_PersonalRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.recordType, recordType) || other.recordType == recordType)&&(identical(other.valueNumeric, valueNumeric) || other.valueNumeric == valueNumeric)&&(identical(other.resultSourceId, resultSourceId) || other.resultSourceId == resultSourceId)&&(identical(other.markType, markType) || other.markType == markType)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,athleteId,exerciseId,variantId,recordType,valueNumeric,resultSourceId,markType,achievedAt,exercise);
}

@override
String toString() {
    return 'PersonalRecord(id: $id, athleteId: $athleteId, exerciseId: $exerciseId, variantId: $variantId, recordType: $recordType, valueNumeric: $valueNumeric, resultSourceId: $resultSourceId, markType: $markType, achievedAt: $achievedAt, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class _$PersonalRecordCopyWith<$Res> implements $PersonalRecordCopyWith<$Res> {
  factory _$PersonalRecordCopyWith(_PersonalRecord value, $Res Function(_PersonalRecord) _then) = __$PersonalRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String athleteId, String exerciseId, String? variantId, String recordType, double valueNumeric, String? resultSourceId, String markType, DateTime achievedAt, Exercise? exercise
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$PersonalRecordCopyWithImpl<$Res>
    implements _$PersonalRecordCopyWith<$Res> {
  __$PersonalRecordCopyWithImpl(this._self, this._then);

  final _PersonalRecord _self;
  final $Res Function(_PersonalRecord) _then;

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? athleteId = null,Object? exerciseId = null,Object? variantId = freezed,Object? recordType = null,Object? valueNumeric = null,Object? resultSourceId = freezed,Object? markType = null,Object? achievedAt = null,Object? exercise = freezed,}) {
  return _then(_PersonalRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,recordType: null == recordType ? _self.recordType : recordType // ignore: cast_nullable_to_non_nullable
as String,valueNumeric: null == valueNumeric ? _self.valueNumeric : valueNumeric // ignore: cast_nullable_to_non_nullable
as double,resultSourceId: freezed == resultSourceId ? _self.resultSourceId : resultSourceId // ignore: cast_nullable_to_non_nullable
as String?,markType: null == markType ? _self.markType : markType // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,
  ));
}

/// Create a copy of PersonalRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}

// dart format on
