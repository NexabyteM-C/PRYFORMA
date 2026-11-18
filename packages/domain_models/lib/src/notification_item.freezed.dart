// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationItem {

 String get id; String get eventType; String get eventId; String get userId; String get channel; String get status; String get title; String get body; Map<String, dynamic>? get dataJson; DateTime? get sentAt; DateTime? get readAt; DateTime get createdAt;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventType, _this.eventType) || other.eventType == _this.eventType)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.dataJson, _this.dataJson)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationItem;
  return Object.hash(runtimeType,_this.id,_this.eventType,_this.eventId,_this.userId,_this.channel,_this.status,_this.title,_this.body,const DeepCollectionEquality().hash(_this.dataJson),_this.sentAt,_this.readAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as NotificationItem;
  return 'NotificationItem(id: ${_this.id}, eventType: ${_this.eventType}, eventId: ${_this.eventId}, userId: ${_this.userId}, channel: ${_this.channel}, status: ${_this.status}, title: ${_this.title}, body: ${_this.body}, dataJson: ${_this.dataJson}, sentAt: ${_this.sentAt}, readAt: ${_this.readAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
 String id, String eventType, String eventId, String userId, String channel, String status, String title, String body, Map<String, dynamic>? dataJson, DateTime? sentAt, DateTime? readAt, DateTime createdAt
});




}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventType = null,Object? eventId = null,Object? userId = null,Object? channel = null,Object? status = null,Object? title = null,Object? body = null,Object? dataJson = freezed,Object? sentAt = freezed,Object? readAt = freezed,Object? createdAt = null,}) {
  return _then(NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,dataJson: freezed == dataJson ? _self.dataJson : dataJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String eventType,  String eventId,  String userId,  String channel,  String status,  String title,  String body,  Map<String, dynamic>? dataJson,  DateTime? sentAt,  DateTime? readAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.eventType,_that.eventId,_that.userId,_that.channel,_that.status,_that.title,_that.body,_that.dataJson,_that.sentAt,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String eventType,  String eventId,  String userId,  String channel,  String status,  String title,  String body,  Map<String, dynamic>? dataJson,  DateTime? sentAt,  DateTime? readAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.eventType,_that.eventId,_that.userId,_that.channel,_that.status,_that.title,_that.body,_that.dataJson,_that.sentAt,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String eventType,  String eventId,  String userId,  String channel,  String status,  String title,  String body,  Map<String, dynamic>? dataJson,  DateTime? sentAt,  DateTime? readAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.eventType,_that.eventId,_that.userId,_that.channel,_that.status,_that.title,_that.body,_that.dataJson,_that.sentAt,_that.readAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationItem implements NotificationItem {
  const _NotificationItem({required this.id, required this.eventType, required this.eventId, required this.userId, required this.channel, this.status = 'pending', required this.title, required this.body,  Map<String, dynamic>? dataJson, this.sentAt, this.readAt, required this.createdAt}): _dataJson = dataJson;
  factory _NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);

@override final  String id;
@override final  String eventType;
@override final  String eventId;
@override final  String userId;
@override final  String channel;
@override@JsonKey() final  String status;
@override final  String title;
@override final  String body;
 final  Map<String, dynamic>? _dataJson;
@override Map<String, dynamic>? get dataJson {
  final value = _dataJson;
  if (value == null) return null;
  if (_dataJson is EqualUnmodifiableMapView) return _dataJson;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? sentAt;
@override final  DateTime? readAt;
@override final  DateTime createdAt;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.dataJson, _dataJson)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventType,eventId,userId,channel,status,title,body,const DeepCollectionEquality().hash(_dataJson),sentAt,readAt,createdAt);
}

@override
String toString() {
    return 'NotificationItem(id: $id, eventType: $eventType, eventId: $eventId, userId: $userId, channel: $channel, status: $status, title: $title, body: $body, dataJson: $dataJson, sentAt: $sentAt, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String eventType, String eventId, String userId, String channel, String status, String title, String body, Map<String, dynamic>? dataJson, DateTime? sentAt, DateTime? readAt, DateTime createdAt
});




}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventType = null,Object? eventId = null,Object? userId = null,Object? channel = null,Object? status = null,Object? title = null,Object? body = null,Object? dataJson = freezed,Object? sentAt = freezed,Object? readAt = freezed,Object? createdAt = null,}) {
  return _then(_NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,dataJson: freezed == dataJson ? _self._dataJson : dataJson // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
