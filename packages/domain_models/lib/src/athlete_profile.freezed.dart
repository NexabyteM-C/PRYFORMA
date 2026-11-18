// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athlete_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AthleteProfile {

 String get userId; String get experienceLevel; String get preferredUnit; String? get primarySport; DateTime? get dateOfBirth; double? get heightCm; double? get weightKg;
/// Create a copy of AthleteProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthleteProfileCopyWith<AthleteProfile> get copyWith => _$AthleteProfileCopyWithImpl<AthleteProfile>(this as AthleteProfile, _$identity);

  /// Serializes this AthleteProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AthleteProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthleteProfile&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.experienceLevel, _this.experienceLevel) || other.experienceLevel == _this.experienceLevel)&&(identical(other.preferredUnit, _this.preferredUnit) || other.preferredUnit == _this.preferredUnit)&&(identical(other.primarySport, _this.primarySport) || other.primarySport == _this.primarySport)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.heightCm, _this.heightCm) || other.heightCm == _this.heightCm)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AthleteProfile;
  return Object.hash(runtimeType,_this.userId,_this.experienceLevel,_this.preferredUnit,_this.primarySport,_this.dateOfBirth,_this.heightCm,_this.weightKg);
}

@override
String toString() {
  final _this = this as AthleteProfile;
  return 'AthleteProfile(userId: ${_this.userId}, experienceLevel: ${_this.experienceLevel}, preferredUnit: ${_this.preferredUnit}, primarySport: ${_this.primarySport}, dateOfBirth: ${_this.dateOfBirth}, heightCm: ${_this.heightCm}, weightKg: ${_this.weightKg})';
}


}

/// @nodoc
abstract mixin class $AthleteProfileCopyWith<$Res>  {
  factory $AthleteProfileCopyWith(AthleteProfile value, $Res Function(AthleteProfile) _then) = _$AthleteProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String experienceLevel, String preferredUnit, String? primarySport, DateTime? dateOfBirth, double? heightCm, double? weightKg
});




}
/// @nodoc
class _$AthleteProfileCopyWithImpl<$Res>
    implements $AthleteProfileCopyWith<$Res> {
  _$AthleteProfileCopyWithImpl(this._self, this._then);

  final AthleteProfile _self;
  final $Res Function(AthleteProfile) _then;

/// Create a copy of AthleteProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? experienceLevel = null,Object? preferredUnit = null,Object? primarySport = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,}) {
  return _then(AthleteProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String,preferredUnit: null == preferredUnit ? _self.preferredUnit : preferredUnit // ignore: cast_nullable_to_non_nullable
as String,primarySport: freezed == primarySport ? _self.primarySport : primarySport // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AthleteProfile].
extension AthleteProfilePatterns on AthleteProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthleteProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthleteProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthleteProfile value)  $default,){
final _that = this;
switch (_that) {
case _AthleteProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthleteProfile value)?  $default,){
final _that = this;
switch (_that) {
case _AthleteProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String experienceLevel,  String preferredUnit,  String? primarySport,  DateTime? dateOfBirth,  double? heightCm,  double? weightKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthleteProfile() when $default != null:
return $default(_that.userId,_that.experienceLevel,_that.preferredUnit,_that.primarySport,_that.dateOfBirth,_that.heightCm,_that.weightKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String experienceLevel,  String preferredUnit,  String? primarySport,  DateTime? dateOfBirth,  double? heightCm,  double? weightKg)  $default,) {final _that = this;
switch (_that) {
case _AthleteProfile():
return $default(_that.userId,_that.experienceLevel,_that.preferredUnit,_that.primarySport,_that.dateOfBirth,_that.heightCm,_that.weightKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String experienceLevel,  String preferredUnit,  String? primarySport,  DateTime? dateOfBirth,  double? heightCm,  double? weightKg)?  $default,) {final _that = this;
switch (_that) {
case _AthleteProfile() when $default != null:
return $default(_that.userId,_that.experienceLevel,_that.preferredUnit,_that.primarySport,_that.dateOfBirth,_that.heightCm,_that.weightKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AthleteProfile implements AthleteProfile {
  const _AthleteProfile({required this.userId, this.experienceLevel = 'beginner', this.preferredUnit = 'kg', this.primarySport, this.dateOfBirth, this.heightCm, this.weightKg});
  factory _AthleteProfile.fromJson(Map<String, dynamic> json) => _$AthleteProfileFromJson(json);

@override final  String userId;
@override@JsonKey() final  String experienceLevel;
@override@JsonKey() final  String preferredUnit;
@override final  String? primarySport;
@override final  DateTime? dateOfBirth;
@override final  double? heightCm;
@override final  double? weightKg;

/// Create a copy of AthleteProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthleteProfileCopyWith<_AthleteProfile> get copyWith => __$AthleteProfileCopyWithImpl<_AthleteProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AthleteProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthleteProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.preferredUnit, preferredUnit) || other.preferredUnit == preferredUnit)&&(identical(other.primarySport, primarySport) || other.primarySport == primarySport)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,experienceLevel,preferredUnit,primarySport,dateOfBirth,heightCm,weightKg);
}

@override
String toString() {
    return 'AthleteProfile(userId: $userId, experienceLevel: $experienceLevel, preferredUnit: $preferredUnit, primarySport: $primarySport, dateOfBirth: $dateOfBirth, heightCm: $heightCm, weightKg: $weightKg)';
}


}

/// @nodoc
abstract mixin class _$AthleteProfileCopyWith<$Res> implements $AthleteProfileCopyWith<$Res> {
  factory _$AthleteProfileCopyWith(_AthleteProfile value, $Res Function(_AthleteProfile) _then) = __$AthleteProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String experienceLevel, String preferredUnit, String? primarySport, DateTime? dateOfBirth, double? heightCm, double? weightKg
});




}
/// @nodoc
class __$AthleteProfileCopyWithImpl<$Res>
    implements _$AthleteProfileCopyWith<$Res> {
  __$AthleteProfileCopyWithImpl(this._self, this._then);

  final _AthleteProfile _self;
  final $Res Function(_AthleteProfile) _then;

/// Create a copy of AthleteProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? experienceLevel = null,Object? preferredUnit = null,Object? primarySport = freezed,Object? dateOfBirth = freezed,Object? heightCm = freezed,Object? weightKg = freezed,}) {
  return _then(_AthleteProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String,preferredUnit: null == preferredUnit ? _self.preferredUnit : preferredUnit // ignore: cast_nullable_to_non_nullable
as String,primarySport: freezed == primarySport ? _self.primarySport : primarySport // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
