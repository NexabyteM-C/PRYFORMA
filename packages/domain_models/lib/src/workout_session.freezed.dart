// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSession {

 String get id; String get athleteId; String? get organizationId; String? get classSessionId; String? get title; String? get notes; DateTime get performedAt; int? get durationMs; String get status; String? get clientId; List<WorkoutExercise>? get exercises;
/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<WorkoutSession> get copyWith => _$WorkoutSessionCopyWithImpl<WorkoutSession>(this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.athleteId, _this.athleteId) || other.athleteId == _this.athleteId)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.classSessionId, _this.classSessionId) || other.classSessionId == _this.classSessionId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.performedAt, _this.performedAt) || other.performedAt == _this.performedAt)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.clientId, _this.clientId) || other.clientId == _this.clientId)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutSession;
  return Object.hash(runtimeType,_this.id,_this.athleteId,_this.organizationId,_this.classSessionId,_this.title,_this.notes,_this.performedAt,_this.durationMs,_this.status,_this.clientId,const DeepCollectionEquality().hash(_this.exercises));
}

@override
String toString() {
  final _this = this as WorkoutSession;
  return 'WorkoutSession(id: ${_this.id}, athleteId: ${_this.athleteId}, organizationId: ${_this.organizationId}, classSessionId: ${_this.classSessionId}, title: ${_this.title}, notes: ${_this.notes}, performedAt: ${_this.performedAt}, durationMs: ${_this.durationMs}, status: ${_this.status}, clientId: ${_this.clientId}, exercises: ${_this.exercises})';
}


}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res>  {
  factory $WorkoutSessionCopyWith(WorkoutSession value, $Res Function(WorkoutSession) _then) = _$WorkoutSessionCopyWithImpl;
@useResult
$Res call({
 String id, String athleteId, String? organizationId, String? classSessionId, String? title, String? notes, DateTime performedAt, int? durationMs, String status, String? clientId, List<WorkoutExercise>? exercises
});




}
/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? athleteId = null,Object? organizationId = freezed,Object? classSessionId = freezed,Object? title = freezed,Object? notes = freezed,Object? performedAt = null,Object? durationMs = freezed,Object? status = null,Object? clientId = freezed,Object? exercises = freezed,}) {
  return _then(WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,classSessionId: freezed == classSessionId ? _self.classSessionId : classSessionId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,exercises: freezed == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? organizationId,  String? classSessionId,  String? title,  String? notes,  DateTime performedAt,  int? durationMs,  String status,  String? clientId,  List<WorkoutExercise>? exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.athleteId,_that.organizationId,_that.classSessionId,_that.title,_that.notes,_that.performedAt,_that.durationMs,_that.status,_that.clientId,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? organizationId,  String? classSessionId,  String? title,  String? notes,  DateTime performedAt,  int? durationMs,  String status,  String? clientId,  List<WorkoutExercise>? exercises)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession():
return $default(_that.id,_that.athleteId,_that.organizationId,_that.classSessionId,_that.title,_that.notes,_that.performedAt,_that.durationMs,_that.status,_that.clientId,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String athleteId,  String? organizationId,  String? classSessionId,  String? title,  String? notes,  DateTime performedAt,  int? durationMs,  String status,  String? clientId,  List<WorkoutExercise>? exercises)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.athleteId,_that.organizationId,_that.classSessionId,_that.title,_that.notes,_that.performedAt,_that.durationMs,_that.status,_that.clientId,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSession implements WorkoutSession {
  const _WorkoutSession({required this.id, required this.athleteId, this.organizationId, this.classSessionId, this.title, this.notes, required this.performedAt, this.durationMs, this.status = 'completed', this.clientId,  List<WorkoutExercise>? exercises}): _exercises = exercises;
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

@override final  String id;
@override final  String athleteId;
@override final  String? organizationId;
@override final  String? classSessionId;
@override final  String? title;
@override final  String? notes;
@override final  DateTime performedAt;
@override final  int? durationMs;
@override@JsonKey() final  String status;
@override final  String? clientId;
 final  List<WorkoutExercise>? _exercises;
@override List<WorkoutExercise>? get exercises {
  final value = _exercises;
  if (value == null) return null;
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSessionCopyWith<_WorkoutSession> get copyWith => __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.classSessionId, classSessionId) || other.classSessionId == classSessionId)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.status, status) || other.status == status)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&const DeepCollectionEquality().equals(other.exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,athleteId,organizationId,classSessionId,title,notes,performedAt,durationMs,status,clientId,const DeepCollectionEquality().hash(_exercises));
}

@override
String toString() {
    return 'WorkoutSession(id: $id, athleteId: $athleteId, organizationId: $organizationId, classSessionId: $classSessionId, title: $title, notes: $notes, performedAt: $performedAt, durationMs: $durationMs, status: $status, clientId: $clientId, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res> implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(_WorkoutSession value, $Res Function(_WorkoutSession) _then) = __$WorkoutSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String athleteId, String? organizationId, String? classSessionId, String? title, String? notes, DateTime performedAt, int? durationMs, String status, String? clientId, List<WorkoutExercise>? exercises
});




}
/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? athleteId = null,Object? organizationId = freezed,Object? classSessionId = freezed,Object? title = freezed,Object? notes = freezed,Object? performedAt = null,Object? durationMs = freezed,Object? status = null,Object? clientId = freezed,Object? exercises = freezed,}) {
  return _then(_WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,classSessionId: freezed == classSessionId ? _self.classSessionId : classSessionId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,exercises: freezed == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>?,
  ));
}


}


/// @nodoc
mixin _$WorkoutExercise {

 String get id; String get sessionId; String get exerciseId; String? get variantId; int get sortOrder; String? get notes; Exercise? get exercise; List<PerformanceSet>? get sets;
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutExerciseCopyWith<WorkoutExercise> get copyWith => _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(this as WorkoutExercise, _$identity);

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise)&&const DeepCollectionEquality().equals(other.sets, _this.sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutExercise;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.exerciseId,_this.variantId,_this.sortOrder,_this.notes,_this.exercise,const DeepCollectionEquality().hash(_this.sets));
}

@override
String toString() {
  final _this = this as WorkoutExercise;
  return 'WorkoutExercise(id: ${_this.id}, sessionId: ${_this.sessionId}, exerciseId: ${_this.exerciseId}, variantId: ${_this.variantId}, sortOrder: ${_this.sortOrder}, notes: ${_this.notes}, exercise: ${_this.exercise}, sets: ${_this.sets})';
}


}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res>  {
  factory $WorkoutExerciseCopyWith(WorkoutExercise value, $Res Function(WorkoutExercise) _then) = _$WorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String exerciseId, String? variantId, int sortOrder, String? notes, Exercise? exercise, List<PerformanceSet>? sets
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? exerciseId = null,Object? variantId = freezed,Object? sortOrder = null,Object? notes = freezed,Object? exercise = freezed,Object? sets = freezed,}) {
  return _then(WorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<PerformanceSet>?,
  ));
}
/// Create a copy of WorkoutExercise
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


/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String exerciseId,  String? variantId,  int sortOrder,  String? notes,  Exercise? exercise,  List<PerformanceSet>? sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.notes,_that.exercise,_that.sets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String exerciseId,  String? variantId,  int sortOrder,  String? notes,  Exercise? exercise,  List<PerformanceSet>? sets)  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.notes,_that.exercise,_that.sets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String exerciseId,  String? variantId,  int sortOrder,  String? notes,  Exercise? exercise,  List<PerformanceSet>? sets)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.sessionId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.notes,_that.exercise,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutExercise implements WorkoutExercise {
  const _WorkoutExercise({required this.id, required this.sessionId, required this.exerciseId, this.variantId, required this.sortOrder, this.notes, this.exercise,  List<PerformanceSet>? sets}): _sets = sets;
  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String exerciseId;
@override final  String? variantId;
@override final  int sortOrder;
@override final  String? notes;
@override final  Exercise? exercise;
 final  List<PerformanceSet>? _sets;
@override List<PerformanceSet>? get sets {
  final value = _sets;
  if (value == null) return null;
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith => __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&const DeepCollectionEquality().equals(other.sets, _sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,exerciseId,variantId,sortOrder,notes,exercise,const DeepCollectionEquality().hash(_sets));
}

@override
String toString() {
    return 'WorkoutExercise(id: $id, sessionId: $sessionId, exerciseId: $exerciseId, variantId: $variantId, sortOrder: $sortOrder, notes: $notes, exercise: $exercise, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res> implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(_WorkoutExercise value, $Res Function(_WorkoutExercise) _then) = __$WorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String exerciseId, String? variantId, int sortOrder, String? notes, Exercise? exercise, List<PerformanceSet>? sets
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? exerciseId = null,Object? variantId = freezed,Object? sortOrder = null,Object? notes = freezed,Object? exercise = freezed,Object? sets = freezed,}) {
  return _then(_WorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,sets: freezed == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<PerformanceSet>?,
  ));
}

/// Create a copy of WorkoutExercise
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
