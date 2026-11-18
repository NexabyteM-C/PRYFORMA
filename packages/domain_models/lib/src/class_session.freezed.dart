// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassSession {

 String get id; String get programId; String get locationId; String get startTime; String? get endTime; int? get capacity; List<User>? get coaches;
/// Create a copy of ClassSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassSessionCopyWith<ClassSession> get copyWith => _$ClassSessionCopyWithImpl<ClassSession>(this as ClassSession, _$identity);

  /// Serializes this ClassSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.programId, _this.programId) || other.programId == _this.programId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity)&&const DeepCollectionEquality().equals(other.coaches, _this.coaches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassSession;
  return Object.hash(runtimeType,_this.id,_this.programId,_this.locationId,_this.startTime,_this.endTime,_this.capacity,const DeepCollectionEquality().hash(_this.coaches));
}

@override
String toString() {
  final _this = this as ClassSession;
  return 'ClassSession(id: ${_this.id}, programId: ${_this.programId}, locationId: ${_this.locationId}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, capacity: ${_this.capacity}, coaches: ${_this.coaches})';
}


}

/// @nodoc
abstract mixin class $ClassSessionCopyWith<$Res>  {
  factory $ClassSessionCopyWith(ClassSession value, $Res Function(ClassSession) _then) = _$ClassSessionCopyWithImpl;
@useResult
$Res call({
 String id, String programId, String locationId, String startTime, String? endTime, int? capacity, List<User>? coaches
});




}
/// @nodoc
class _$ClassSessionCopyWithImpl<$Res>
    implements $ClassSessionCopyWith<$Res> {
  _$ClassSessionCopyWithImpl(this._self, this._then);

  final ClassSession _self;
  final $Res Function(ClassSession) _then;

/// Create a copy of ClassSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? programId = null,Object? locationId = null,Object? startTime = null,Object? endTime = freezed,Object? capacity = freezed,Object? coaches = freezed,}) {
  return _then(ClassSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,coaches: freezed == coaches ? _self.coaches : coaches // ignore: cast_nullable_to_non_nullable
as List<User>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassSession].
extension ClassSessionPatterns on ClassSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassSession value)  $default,){
final _that = this;
switch (_that) {
case _ClassSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassSession value)?  $default,){
final _that = this;
switch (_that) {
case _ClassSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String programId,  String locationId,  String startTime,  String? endTime,  int? capacity,  List<User>? coaches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassSession() when $default != null:
return $default(_that.id,_that.programId,_that.locationId,_that.startTime,_that.endTime,_that.capacity,_that.coaches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String programId,  String locationId,  String startTime,  String? endTime,  int? capacity,  List<User>? coaches)  $default,) {final _that = this;
switch (_that) {
case _ClassSession():
return $default(_that.id,_that.programId,_that.locationId,_that.startTime,_that.endTime,_that.capacity,_that.coaches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String programId,  String locationId,  String startTime,  String? endTime,  int? capacity,  List<User>? coaches)?  $default,) {final _that = this;
switch (_that) {
case _ClassSession() when $default != null:
return $default(_that.id,_that.programId,_that.locationId,_that.startTime,_that.endTime,_that.capacity,_that.coaches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassSession implements ClassSession {
  const _ClassSession({required this.id, required this.programId, required this.locationId, required this.startTime, this.endTime, this.capacity,  List<User>? coaches}): _coaches = coaches;
  factory _ClassSession.fromJson(Map<String, dynamic> json) => _$ClassSessionFromJson(json);

@override final  String id;
@override final  String programId;
@override final  String locationId;
@override final  String startTime;
@override final  String? endTime;
@override final  int? capacity;
 final  List<User>? _coaches;
@override List<User>? get coaches {
  final value = _coaches;
  if (value == null) return null;
  if (_coaches is EqualUnmodifiableListView) return _coaches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClassSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassSessionCopyWith<_ClassSession> get copyWith => __$ClassSessionCopyWithImpl<_ClassSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassSession&&(identical(other.id, id) || other.id == id)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&const DeepCollectionEquality().equals(other.coaches, _coaches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,programId,locationId,startTime,endTime,capacity,const DeepCollectionEquality().hash(_coaches));
}

@override
String toString() {
    return 'ClassSession(id: $id, programId: $programId, locationId: $locationId, startTime: $startTime, endTime: $endTime, capacity: $capacity, coaches: $coaches)';
}


}

/// @nodoc
abstract mixin class _$ClassSessionCopyWith<$Res> implements $ClassSessionCopyWith<$Res> {
  factory _$ClassSessionCopyWith(_ClassSession value, $Res Function(_ClassSession) _then) = __$ClassSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String programId, String locationId, String startTime, String? endTime, int? capacity, List<User>? coaches
});




}
/// @nodoc
class __$ClassSessionCopyWithImpl<$Res>
    implements _$ClassSessionCopyWith<$Res> {
  __$ClassSessionCopyWithImpl(this._self, this._then);

  final _ClassSession _self;
  final $Res Function(_ClassSession) _then;

/// Create a copy of ClassSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? programId = null,Object? locationId = null,Object? startTime = null,Object? endTime = freezed,Object? capacity = freezed,Object? coaches = freezed,}) {
  return _then(_ClassSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int?,coaches: freezed == coaches ? _self._coaches : coaches // ignore: cast_nullable_to_non_nullable
as List<User>?,
  ));
}


}

// dart format on
