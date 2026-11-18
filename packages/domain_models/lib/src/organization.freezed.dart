// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Organization {

 String get id; String get name; String get slug; String? get description; String? get logoUrl; String get status; String get ownerUserId; List<OrganizationLocation>? get locations;
/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationCopyWith<Organization> get copyWith => _$OrganizationCopyWithImpl<Organization>(this as Organization, _$identity);

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Organization;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Organization&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.ownerUserId, _this.ownerUserId) || other.ownerUserId == _this.ownerUserId)&&const DeepCollectionEquality().equals(other.locations, _this.locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Organization;
  return Object.hash(runtimeType,_this.id,_this.name,_this.slug,_this.description,_this.logoUrl,_this.status,_this.ownerUserId,const DeepCollectionEquality().hash(_this.locations));
}

@override
String toString() {
  final _this = this as Organization;
  return 'Organization(id: ${_this.id}, name: ${_this.name}, slug: ${_this.slug}, description: ${_this.description}, logoUrl: ${_this.logoUrl}, status: ${_this.status}, ownerUserId: ${_this.ownerUserId}, locations: ${_this.locations})';
}


}

/// @nodoc
abstract mixin class $OrganizationCopyWith<$Res>  {
  factory $OrganizationCopyWith(Organization value, $Res Function(Organization) _then) = _$OrganizationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? description, String? logoUrl, String status, String ownerUserId, List<OrganizationLocation>? locations
});




}
/// @nodoc
class _$OrganizationCopyWithImpl<$Res>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._self, this._then);

  final Organization _self;
  final $Res Function(Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? logoUrl = freezed,Object? status = null,Object? ownerUserId = null,Object? locations = freezed,}) {
  return _then(Organization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,locations: freezed == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<OrganizationLocation>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Organization].
extension OrganizationPatterns on Organization {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Organization value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Organization value)  $default,){
final _that = this;
switch (_that) {
case _Organization():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Organization value)?  $default,){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? logoUrl,  String status,  String ownerUserId,  List<OrganizationLocation>? locations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.status,_that.ownerUserId,_that.locations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? logoUrl,  String status,  String ownerUserId,  List<OrganizationLocation>? locations)  $default,) {final _that = this;
switch (_that) {
case _Organization():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.status,_that.ownerUserId,_that.locations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? description,  String? logoUrl,  String status,  String ownerUserId,  List<OrganizationLocation>? locations)?  $default,) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.status,_that.ownerUserId,_that.locations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Organization implements Organization {
  const _Organization({required this.id, required this.name, required this.slug, this.description, this.logoUrl, this.status = 'active', required this.ownerUserId,  List<OrganizationLocation>? locations}): _locations = locations;
  factory _Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? description;
@override final  String? logoUrl;
@override@JsonKey() final  String status;
@override final  String ownerUserId;
 final  List<OrganizationLocation>? _locations;
@override List<OrganizationLocation>? get locations {
  final value = _locations;
  if (value == null) return null;
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationCopyWith<_Organization> get copyWith => __$OrganizationCopyWithImpl<_Organization>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Organization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&const DeepCollectionEquality().equals(other.locations, _locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,slug,description,logoUrl,status,ownerUserId,const DeepCollectionEquality().hash(_locations));
}

@override
String toString() {
    return 'Organization(id: $id, name: $name, slug: $slug, description: $description, logoUrl: $logoUrl, status: $status, ownerUserId: $ownerUserId, locations: $locations)';
}


}

/// @nodoc
abstract mixin class _$OrganizationCopyWith<$Res> implements $OrganizationCopyWith<$Res> {
  factory _$OrganizationCopyWith(_Organization value, $Res Function(_Organization) _then) = __$OrganizationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? description, String? logoUrl, String status, String ownerUserId, List<OrganizationLocation>? locations
});




}
/// @nodoc
class __$OrganizationCopyWithImpl<$Res>
    implements _$OrganizationCopyWith<$Res> {
  __$OrganizationCopyWithImpl(this._self, this._then);

  final _Organization _self;
  final $Res Function(_Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? logoUrl = freezed,Object? status = null,Object? ownerUserId = null,Object? locations = freezed,}) {
  return _then(_Organization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,locations: freezed == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<OrganizationLocation>?,
  ));
}


}


/// @nodoc
mixin _$OrganizationLocation {

 String get id; String get organizationId; String get name; String get timezone; String? get address; String? get city; String? get country; bool get isPrimary;
/// Create a copy of OrganizationLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationLocationCopyWith<OrganizationLocation> get copyWith => _$OrganizationLocationCopyWithImpl<OrganizationLocation>(this as OrganizationLocation, _$identity);

  /// Serializes this OrganizationLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrganizationLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationLocation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrganizationLocation;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.name,_this.timezone,_this.address,_this.city,_this.country,_this.isPrimary);
}

@override
String toString() {
  final _this = this as OrganizationLocation;
  return 'OrganizationLocation(id: ${_this.id}, organizationId: ${_this.organizationId}, name: ${_this.name}, timezone: ${_this.timezone}, address: ${_this.address}, city: ${_this.city}, country: ${_this.country}, isPrimary: ${_this.isPrimary})';
}


}

/// @nodoc
abstract mixin class $OrganizationLocationCopyWith<$Res>  {
  factory $OrganizationLocationCopyWith(OrganizationLocation value, $Res Function(OrganizationLocation) _then) = _$OrganizationLocationCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String timezone, String? address, String? city, String? country, bool isPrimary
});




}
/// @nodoc
class _$OrganizationLocationCopyWithImpl<$Res>
    implements $OrganizationLocationCopyWith<$Res> {
  _$OrganizationLocationCopyWithImpl(this._self, this._then);

  final OrganizationLocation _self;
  final $Res Function(OrganizationLocation) _then;

/// Create a copy of OrganizationLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? timezone = null,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? isPrimary = null,}) {
  return _then(OrganizationLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationLocation].
extension OrganizationLocationPatterns on OrganizationLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationLocation value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationLocation value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String timezone,  String? address,  String? city,  String? country,  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationLocation() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.timezone,_that.address,_that.city,_that.country,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String timezone,  String? address,  String? city,  String? country,  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _OrganizationLocation():
return $default(_that.id,_that.organizationId,_that.name,_that.timezone,_that.address,_that.city,_that.country,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String timezone,  String? address,  String? city,  String? country,  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationLocation() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.timezone,_that.address,_that.city,_that.country,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationLocation implements OrganizationLocation {
  const _OrganizationLocation({required this.id, required this.organizationId, required this.name, required this.timezone, this.address, this.city, this.country, this.isPrimary = false});
  factory _OrganizationLocation.fromJson(Map<String, dynamic> json) => _$OrganizationLocationFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String timezone;
@override final  String? address;
@override final  String? city;
@override final  String? country;
@override@JsonKey() final  bool isPrimary;

/// Create a copy of OrganizationLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationLocationCopyWith<_OrganizationLocation> get copyWith => __$OrganizationLocationCopyWithImpl<_OrganizationLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,name,timezone,address,city,country,isPrimary);
}

@override
String toString() {
    return 'OrganizationLocation(id: $id, organizationId: $organizationId, name: $name, timezone: $timezone, address: $address, city: $city, country: $country, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$OrganizationLocationCopyWith<$Res> implements $OrganizationLocationCopyWith<$Res> {
  factory _$OrganizationLocationCopyWith(_OrganizationLocation value, $Res Function(_OrganizationLocation) _then) = __$OrganizationLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String timezone, String? address, String? city, String? country, bool isPrimary
});




}
/// @nodoc
class __$OrganizationLocationCopyWithImpl<$Res>
    implements _$OrganizationLocationCopyWith<$Res> {
  __$OrganizationLocationCopyWithImpl(this._self, this._then);

  final _OrganizationLocation _self;
  final $Res Function(_OrganizationLocation) _then;

/// Create a copy of OrganizationLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? timezone = null,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? isPrimary = null,}) {
  return _then(_OrganizationLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
