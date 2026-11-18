// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Goal {

 String get id; String get athleteId; String? get exerciseId; String get title; String? get description; String get goalType; String? get metricCode; double? get initialValue; double get targetValue; double? get currentValue; String? get unit; String get status; DateTime? get targetDate; DateTime? get achievedAt; Exercise? get exercise; List<GoalMilestone>? get milestones;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);

  /// Serializes this Goal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Goal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.athleteId, _this.athleteId) || other.athleteId == _this.athleteId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.goalType, _this.goalType) || other.goalType == _this.goalType)&&(identical(other.metricCode, _this.metricCode) || other.metricCode == _this.metricCode)&&(identical(other.initialValue, _this.initialValue) || other.initialValue == _this.initialValue)&&(identical(other.targetValue, _this.targetValue) || other.targetValue == _this.targetValue)&&(identical(other.currentValue, _this.currentValue) || other.currentValue == _this.currentValue)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.targetDate, _this.targetDate) || other.targetDate == _this.targetDate)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise)&&const DeepCollectionEquality().equals(other.milestones, _this.milestones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Goal;
  return Object.hash(runtimeType,_this.id,_this.athleteId,_this.exerciseId,_this.title,_this.description,_this.goalType,_this.metricCode,_this.initialValue,_this.targetValue,_this.currentValue,_this.unit,_this.status,_this.targetDate,_this.achievedAt,_this.exercise,const DeepCollectionEquality().hash(_this.milestones));
}

@override
String toString() {
  final _this = this as Goal;
  return 'Goal(id: ${_this.id}, athleteId: ${_this.athleteId}, exerciseId: ${_this.exerciseId}, title: ${_this.title}, description: ${_this.description}, goalType: ${_this.goalType}, metricCode: ${_this.metricCode}, initialValue: ${_this.initialValue}, targetValue: ${_this.targetValue}, currentValue: ${_this.currentValue}, unit: ${_this.unit}, status: ${_this.status}, targetDate: ${_this.targetDate}, achievedAt: ${_this.achievedAt}, exercise: ${_this.exercise}, milestones: ${_this.milestones})';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 String id, String athleteId, String? exerciseId, String title, String? description, String goalType, String? metricCode, double? initialValue, double targetValue, double? currentValue, String? unit, String status, DateTime? targetDate, DateTime? achievedAt, Exercise? exercise, List<GoalMilestone>? milestones
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? athleteId = null,Object? exerciseId = freezed,Object? title = null,Object? description = freezed,Object? goalType = null,Object? metricCode = freezed,Object? initialValue = freezed,Object? targetValue = null,Object? currentValue = freezed,Object? unit = freezed,Object? status = null,Object? targetDate = freezed,Object? achievedAt = freezed,Object? exercise = freezed,Object? milestones = freezed,}) {
  return _then(Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as String,metricCode: freezed == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String?,initialValue: freezed == initialValue ? _self.initialValue : initialValue // ignore: cast_nullable_to_non_nullable
as double?,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,milestones: freezed == milestones ? _self.milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<GoalMilestone>?,
  ));
}
/// Create a copy of Goal
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


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? exerciseId,  String title,  String? description,  String goalType,  String? metricCode,  double? initialValue,  double targetValue,  double? currentValue,  String? unit,  String status,  DateTime? targetDate,  DateTime? achievedAt,  Exercise? exercise,  List<GoalMilestone>? milestones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.title,_that.description,_that.goalType,_that.metricCode,_that.initialValue,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.achievedAt,_that.exercise,_that.milestones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? exerciseId,  String title,  String? description,  String goalType,  String? metricCode,  double? initialValue,  double targetValue,  double? currentValue,  String? unit,  String status,  DateTime? targetDate,  DateTime? achievedAt,  Exercise? exercise,  List<GoalMilestone>? milestones)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.title,_that.description,_that.goalType,_that.metricCode,_that.initialValue,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.achievedAt,_that.exercise,_that.milestones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String athleteId,  String? exerciseId,  String title,  String? description,  String goalType,  String? metricCode,  double? initialValue,  double targetValue,  double? currentValue,  String? unit,  String status,  DateTime? targetDate,  DateTime? achievedAt,  Exercise? exercise,  List<GoalMilestone>? milestones)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.athleteId,_that.exerciseId,_that.title,_that.description,_that.goalType,_that.metricCode,_that.initialValue,_that.targetValue,_that.currentValue,_that.unit,_that.status,_that.targetDate,_that.achievedAt,_that.exercise,_that.milestones);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Goal implements Goal {
  const _Goal({required this.id, required this.athleteId, this.exerciseId, required this.title, this.description, required this.goalType, this.metricCode, this.initialValue, required this.targetValue, this.currentValue, this.unit, this.status = 'active', this.targetDate, this.achievedAt, this.exercise,  List<GoalMilestone>? milestones}): _milestones = milestones;
  factory _Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

@override final  String id;
@override final  String athleteId;
@override final  String? exerciseId;
@override final  String title;
@override final  String? description;
@override final  String goalType;
@override final  String? metricCode;
@override final  double? initialValue;
@override final  double targetValue;
@override final  double? currentValue;
@override final  String? unit;
@override@JsonKey() final  String status;
@override final  DateTime? targetDate;
@override final  DateTime? achievedAt;
@override final  Exercise? exercise;
 final  List<GoalMilestone>? _milestones;
@override List<GoalMilestone>? get milestones {
  final value = _milestones;
  if (value == null) return null;
  if (_milestones is EqualUnmodifiableListView) return _milestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.metricCode, metricCode) || other.metricCode == metricCode)&&(identical(other.initialValue, initialValue) || other.initialValue == initialValue)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.status, status) || other.status == status)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&const DeepCollectionEquality().equals(other.milestones, _milestones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,athleteId,exerciseId,title,description,goalType,metricCode,initialValue,targetValue,currentValue,unit,status,targetDate,achievedAt,exercise,const DeepCollectionEquality().hash(_milestones));
}

@override
String toString() {
    return 'Goal(id: $id, athleteId: $athleteId, exerciseId: $exerciseId, title: $title, description: $description, goalType: $goalType, metricCode: $metricCode, initialValue: $initialValue, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, status: $status, targetDate: $targetDate, achievedAt: $achievedAt, exercise: $exercise, milestones: $milestones)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String athleteId, String? exerciseId, String title, String? description, String goalType, String? metricCode, double? initialValue, double targetValue, double? currentValue, String? unit, String status, DateTime? targetDate, DateTime? achievedAt, Exercise? exercise, List<GoalMilestone>? milestones
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? athleteId = null,Object? exerciseId = freezed,Object? title = null,Object? description = freezed,Object? goalType = null,Object? metricCode = freezed,Object? initialValue = freezed,Object? targetValue = null,Object? currentValue = freezed,Object? unit = freezed,Object? status = null,Object? targetDate = freezed,Object? achievedAt = freezed,Object? exercise = freezed,Object? milestones = freezed,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as String,metricCode: freezed == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String?,initialValue: freezed == initialValue ? _self.initialValue : initialValue // ignore: cast_nullable_to_non_nullable
as double?,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,milestones: freezed == milestones ? _self._milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<GoalMilestone>?,
  ));
}

/// Create a copy of Goal
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


/// @nodoc
mixin _$GoalMilestone {

 String get id; String get goalId; double get value; String? get note; DateTime get achievedAt;
/// Create a copy of GoalMilestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalMilestoneCopyWith<GoalMilestone> get copyWith => _$GoalMilestoneCopyWithImpl<GoalMilestone>(this as GoalMilestone, _$identity);

  /// Serializes this GoalMilestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoalMilestone;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalMilestone&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.goalId, _this.goalId) || other.goalId == _this.goalId)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoalMilestone;
  return Object.hash(runtimeType,_this.id,_this.goalId,_this.value,_this.note,_this.achievedAt);
}

@override
String toString() {
  final _this = this as GoalMilestone;
  return 'GoalMilestone(id: ${_this.id}, goalId: ${_this.goalId}, value: ${_this.value}, note: ${_this.note}, achievedAt: ${_this.achievedAt})';
}


}

/// @nodoc
abstract mixin class $GoalMilestoneCopyWith<$Res>  {
  factory $GoalMilestoneCopyWith(GoalMilestone value, $Res Function(GoalMilestone) _then) = _$GoalMilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, double value, String? note, DateTime achievedAt
});




}
/// @nodoc
class _$GoalMilestoneCopyWithImpl<$Res>
    implements $GoalMilestoneCopyWith<$Res> {
  _$GoalMilestoneCopyWithImpl(this._self, this._then);

  final GoalMilestone _self;
  final $Res Function(GoalMilestone) _then;

/// Create a copy of GoalMilestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? value = null,Object? note = freezed,Object? achievedAt = null,}) {
  return _then(GoalMilestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalMilestone].
extension GoalMilestonePatterns on GoalMilestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalMilestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalMilestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalMilestone value)  $default,){
final _that = this;
switch (_that) {
case _GoalMilestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalMilestone value)?  $default,){
final _that = this;
switch (_that) {
case _GoalMilestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  double value,  String? note,  DateTime achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalMilestone() when $default != null:
return $default(_that.id,_that.goalId,_that.value,_that.note,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  double value,  String? note,  DateTime achievedAt)  $default,) {final _that = this;
switch (_that) {
case _GoalMilestone():
return $default(_that.id,_that.goalId,_that.value,_that.note,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  double value,  String? note,  DateTime achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _GoalMilestone() when $default != null:
return $default(_that.id,_that.goalId,_that.value,_that.note,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalMilestone implements GoalMilestone {
  const _GoalMilestone({required this.id, required this.goalId, required this.value, this.note, required this.achievedAt});
  factory _GoalMilestone.fromJson(Map<String, dynamic> json) => _$GoalMilestoneFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  double value;
@override final  String? note;
@override final  DateTime achievedAt;

/// Create a copy of GoalMilestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalMilestoneCopyWith<_GoalMilestone> get copyWith => __$GoalMilestoneCopyWithImpl<_GoalMilestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalMilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.value, value) || other.value == value)&&(identical(other.note, note) || other.note == note)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,goalId,value,note,achievedAt);
}

@override
String toString() {
    return 'GoalMilestone(id: $id, goalId: $goalId, value: $value, note: $note, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$GoalMilestoneCopyWith<$Res> implements $GoalMilestoneCopyWith<$Res> {
  factory _$GoalMilestoneCopyWith(_GoalMilestone value, $Res Function(_GoalMilestone) _then) = __$GoalMilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, double value, String? note, DateTime achievedAt
});




}
/// @nodoc
class __$GoalMilestoneCopyWithImpl<$Res>
    implements _$GoalMilestoneCopyWith<$Res> {
  __$GoalMilestoneCopyWithImpl(this._self, this._then);

  final _GoalMilestone _self;
  final $Res Function(_GoalMilestone) _then;

/// Create a copy of GoalMilestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? value = null,Object? note = freezed,Object? achievedAt = null,}) {
  return _then(_GoalMilestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
