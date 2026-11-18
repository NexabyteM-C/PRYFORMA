// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationMember {

 String get id; String get organizationId; String get userId; String get role; String get status; DateTime? get joinedAt; User? get user; Organization? get organization;
/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationMemberCopyWith<OrganizationMember> get copyWith => _$OrganizationMemberCopyWithImpl<OrganizationMember>(this as OrganizationMember, _$identity);

  /// Serializes this OrganizationMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrganizationMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationMember&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.organization, _this.organization) || other.organization == _this.organization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrganizationMember;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.userId,_this.role,_this.status,_this.joinedAt,_this.user,_this.organization);
}

@override
String toString() {
  final _this = this as OrganizationMember;
  return 'OrganizationMember(id: ${_this.id}, organizationId: ${_this.organizationId}, userId: ${_this.userId}, role: ${_this.role}, status: ${_this.status}, joinedAt: ${_this.joinedAt}, user: ${_this.user}, organization: ${_this.organization})';
}


}

/// @nodoc
abstract mixin class $OrganizationMemberCopyWith<$Res>  {
  factory $OrganizationMemberCopyWith(OrganizationMember value, $Res Function(OrganizationMember) _then) = _$OrganizationMemberCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String userId, String role, String status, DateTime? joinedAt, User? user, Organization? organization
});


$UserCopyWith<$Res>? get user;$OrganizationCopyWith<$Res>? get organization;

}
/// @nodoc
class _$OrganizationMemberCopyWithImpl<$Res>
    implements $OrganizationMemberCopyWith<$Res> {
  _$OrganizationMemberCopyWithImpl(this._self, this._then);

  final OrganizationMember _self;
  final $Res Function(OrganizationMember) _then;

/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? user = freezed,Object? organization = freezed,}) {
  return _then(OrganizationMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,
  ));
}
/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationCopyWith<$Res>? get organization {
    if (_self.organization == null) {
    return null;
  }

  return $OrganizationCopyWith<$Res>(_self.organization!, (value) {
    return _then(_self.copyWith(organization: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrganizationMember].
extension OrganizationMemberPatterns on OrganizationMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationMember value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationMember value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  String role,  String status,  DateTime? joinedAt,  User? user,  Organization? organization)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationMember() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.user,_that.organization);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String userId,  String role,  String status,  DateTime? joinedAt,  User? user,  Organization? organization)  $default,) {final _that = this;
switch (_that) {
case _OrganizationMember():
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.user,_that.organization);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String userId,  String role,  String status,  DateTime? joinedAt,  User? user,  Organization? organization)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationMember() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.role,_that.status,_that.joinedAt,_that.user,_that.organization);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationMember implements OrganizationMember {
  const _OrganizationMember({required this.id, required this.organizationId, required this.userId, required this.role, this.status = 'active', this.joinedAt, this.user, this.organization});
  factory _OrganizationMember.fromJson(Map<String, dynamic> json) => _$OrganizationMemberFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String userId;
@override final  String role;
@override@JsonKey() final  String status;
@override final  DateTime? joinedAt;
@override final  User? user;
@override final  Organization? organization;

/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationMemberCopyWith<_OrganizationMember> get copyWith => __$OrganizationMemberCopyWithImpl<_OrganizationMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationMember&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.organization, organization) || other.organization == organization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,userId,role,status,joinedAt,user,organization);
}

@override
String toString() {
    return 'OrganizationMember(id: $id, organizationId: $organizationId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt, user: $user, organization: $organization)';
}


}

/// @nodoc
abstract mixin class _$OrganizationMemberCopyWith<$Res> implements $OrganizationMemberCopyWith<$Res> {
  factory _$OrganizationMemberCopyWith(_OrganizationMember value, $Res Function(_OrganizationMember) _then) = __$OrganizationMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String userId, String role, String status, DateTime? joinedAt, User? user, Organization? organization
});


@override $UserCopyWith<$Res>? get user;@override $OrganizationCopyWith<$Res>? get organization;

}
/// @nodoc
class __$OrganizationMemberCopyWithImpl<$Res>
    implements _$OrganizationMemberCopyWith<$Res> {
  __$OrganizationMemberCopyWithImpl(this._self, this._then);

  final _OrganizationMember _self;
  final $Res Function(_OrganizationMember) _then;

/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? user = freezed,Object? organization = freezed,}) {
  return _then(_OrganizationMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,
  ));
}

/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of OrganizationMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationCopyWith<$Res>? get organization {
    if (_self.organization == null) {
    return null;
  }

  return $OrganizationCopyWith<$Res>(_self.organization!, (value) {
    return _then(_self.copyWith(organization: value));
  });
}
}

// dart format on
