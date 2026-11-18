// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Announcement {

 String get id; String get organizationId; String get authorId; String get title; String get body; DateTime? get publishedAt; bool get pinned; DateTime get createdAt; User? get author; Organization? get organization;
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<Announcement> get copyWith => _$AnnouncementCopyWithImpl<Announcement>(this as Announcement, _$identity);

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Announcement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Announcement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.authorId, _this.authorId) || other.authorId == _this.authorId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.organization, _this.organization) || other.organization == _this.organization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Announcement;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.authorId,_this.title,_this.body,_this.publishedAt,_this.pinned,_this.createdAt,_this.author,_this.organization);
}

@override
String toString() {
  final _this = this as Announcement;
  return 'Announcement(id: ${_this.id}, organizationId: ${_this.organizationId}, authorId: ${_this.authorId}, title: ${_this.title}, body: ${_this.body}, publishedAt: ${_this.publishedAt}, pinned: ${_this.pinned}, createdAt: ${_this.createdAt}, author: ${_this.author}, organization: ${_this.organization})';
}


}

/// @nodoc
abstract mixin class $AnnouncementCopyWith<$Res>  {
  factory $AnnouncementCopyWith(Announcement value, $Res Function(Announcement) _then) = _$AnnouncementCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String authorId, String title, String body, DateTime? publishedAt, bool pinned, DateTime createdAt, User? author, Organization? organization
});


$UserCopyWith<$Res>? get author;$OrganizationCopyWith<$Res>? get organization;

}
/// @nodoc
class _$AnnouncementCopyWithImpl<$Res>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._self, this._then);

  final Announcement _self;
  final $Res Function(Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? authorId = null,Object? title = null,Object? body = null,Object? publishedAt = freezed,Object? pinned = null,Object? createdAt = null,Object? author = freezed,Object? organization = freezed,}) {
  return _then(Announcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,
  ));
}
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Announcement
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


/// Adds pattern-matching-related methods to [Announcement].
extension AnnouncementPatterns on Announcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Announcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Announcement value)  $default,){
final _that = this;
switch (_that) {
case _Announcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Announcement value)?  $default,){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String authorId,  String title,  String body,  DateTime? publishedAt,  bool pinned,  DateTime createdAt,  User? author,  Organization? organization)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.organizationId,_that.authorId,_that.title,_that.body,_that.publishedAt,_that.pinned,_that.createdAt,_that.author,_that.organization);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String authorId,  String title,  String body,  DateTime? publishedAt,  bool pinned,  DateTime createdAt,  User? author,  Organization? organization)  $default,) {final _that = this;
switch (_that) {
case _Announcement():
return $default(_that.id,_that.organizationId,_that.authorId,_that.title,_that.body,_that.publishedAt,_that.pinned,_that.createdAt,_that.author,_that.organization);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String authorId,  String title,  String body,  DateTime? publishedAt,  bool pinned,  DateTime createdAt,  User? author,  Organization? organization)?  $default,) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.organizationId,_that.authorId,_that.title,_that.body,_that.publishedAt,_that.pinned,_that.createdAt,_that.author,_that.organization);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Announcement implements Announcement {
  const _Announcement({required this.id, required this.organizationId, required this.authorId, required this.title, required this.body, this.publishedAt, this.pinned = false, required this.createdAt, this.author, this.organization});
  factory _Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String authorId;
@override final  String title;
@override final  String body;
@override final  DateTime? publishedAt;
@override@JsonKey() final  bool pinned;
@override final  DateTime createdAt;
@override final  User? author;
@override final  Organization? organization;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementCopyWith<_Announcement> get copyWith => __$AnnouncementCopyWithImpl<_Announcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.organization, organization) || other.organization == organization));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,authorId,title,body,publishedAt,pinned,createdAt,author,organization);
}

@override
String toString() {
    return 'Announcement(id: $id, organizationId: $organizationId, authorId: $authorId, title: $title, body: $body, publishedAt: $publishedAt, pinned: $pinned, createdAt: $createdAt, author: $author, organization: $organization)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementCopyWith<$Res> implements $AnnouncementCopyWith<$Res> {
  factory _$AnnouncementCopyWith(_Announcement value, $Res Function(_Announcement) _then) = __$AnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String authorId, String title, String body, DateTime? publishedAt, bool pinned, DateTime createdAt, User? author, Organization? organization
});


@override $UserCopyWith<$Res>? get author;@override $OrganizationCopyWith<$Res>? get organization;

}
/// @nodoc
class __$AnnouncementCopyWithImpl<$Res>
    implements _$AnnouncementCopyWith<$Res> {
  __$AnnouncementCopyWithImpl(this._self, this._then);

  final _Announcement _self;
  final $Res Function(_Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? authorId = null,Object? title = null,Object? body = null,Object? publishedAt = freezed,Object? pinned = null,Object? createdAt = null,Object? author = freezed,Object? organization = freezed,}) {
  return _then(_Announcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as User?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,
  ));
}

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Announcement
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
