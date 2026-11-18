// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassProgram {

 String get id; String get organizationId; String get locationId; String? get templateId; DateTime get programDate; String get title; String? get description; List<String> get focusTags; String? get objective; String? get coachNotes; String get status; DateTime? get scheduledPublishAt; DateTime? get publishedAt; DateTime? get cancelledAt; String get createdBy; int get currentVersion; List<ClassProgramBlock>? get blocks; List<ClassSession>? get sessions; Organization? get organization; OrganizationLocation? get location;
/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassProgramCopyWith<ClassProgram> get copyWith => _$ClassProgramCopyWithImpl<ClassProgram>(this as ClassProgram, _$identity);

  /// Serializes this ClassProgram to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassProgram;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassProgram&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&(identical(other.programDate, _this.programDate) || other.programDate == _this.programDate)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.focusTags, _this.focusTags)&&(identical(other.objective, _this.objective) || other.objective == _this.objective)&&(identical(other.coachNotes, _this.coachNotes) || other.coachNotes == _this.coachNotes)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.scheduledPublishAt, _this.scheduledPublishAt) || other.scheduledPublishAt == _this.scheduledPublishAt)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt)&&(identical(other.cancelledAt, _this.cancelledAt) || other.cancelledAt == _this.cancelledAt)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.currentVersion, _this.currentVersion) || other.currentVersion == _this.currentVersion)&&const DeepCollectionEquality().equals(other.blocks, _this.blocks)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.location, _this.location) || other.location == _this.location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassProgram;
  return Object.hashAll([runtimeType,_this.id,_this.organizationId,_this.locationId,_this.templateId,_this.programDate,_this.title,_this.description,const DeepCollectionEquality().hash(_this.focusTags),_this.objective,_this.coachNotes,_this.status,_this.scheduledPublishAt,_this.publishedAt,_this.cancelledAt,_this.createdBy,_this.currentVersion,const DeepCollectionEquality().hash(_this.blocks),const DeepCollectionEquality().hash(_this.sessions),_this.organization,_this.location]);
}

@override
String toString() {
  final _this = this as ClassProgram;
  return 'ClassProgram(id: ${_this.id}, organizationId: ${_this.organizationId}, locationId: ${_this.locationId}, templateId: ${_this.templateId}, programDate: ${_this.programDate}, title: ${_this.title}, description: ${_this.description}, focusTags: ${_this.focusTags}, objective: ${_this.objective}, coachNotes: ${_this.coachNotes}, status: ${_this.status}, scheduledPublishAt: ${_this.scheduledPublishAt}, publishedAt: ${_this.publishedAt}, cancelledAt: ${_this.cancelledAt}, createdBy: ${_this.createdBy}, currentVersion: ${_this.currentVersion}, blocks: ${_this.blocks}, sessions: ${_this.sessions}, organization: ${_this.organization}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $ClassProgramCopyWith<$Res>  {
  factory $ClassProgramCopyWith(ClassProgram value, $Res Function(ClassProgram) _then) = _$ClassProgramCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String locationId, String? templateId, DateTime programDate, String title, String? description, List<String> focusTags, String? objective, String? coachNotes, String status, DateTime? scheduledPublishAt, DateTime? publishedAt, DateTime? cancelledAt, String createdBy, int currentVersion, List<ClassProgramBlock>? blocks, List<ClassSession>? sessions, Organization? organization, OrganizationLocation? location
});


$OrganizationCopyWith<$Res>? get organization;$OrganizationLocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$ClassProgramCopyWithImpl<$Res>
    implements $ClassProgramCopyWith<$Res> {
  _$ClassProgramCopyWithImpl(this._self, this._then);

  final ClassProgram _self;
  final $Res Function(ClassProgram) _then;

/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? locationId = null,Object? templateId = freezed,Object? programDate = null,Object? title = null,Object? description = freezed,Object? focusTags = null,Object? objective = freezed,Object? coachNotes = freezed,Object? status = null,Object? scheduledPublishAt = freezed,Object? publishedAt = freezed,Object? cancelledAt = freezed,Object? createdBy = null,Object? currentVersion = null,Object? blocks = freezed,Object? sessions = freezed,Object? organization = freezed,Object? location = freezed,}) {
  return _then(ClassProgram(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,programDate: null == programDate ? _self.programDate : programDate // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,focusTags: null == focusTags ? _self.focusTags : focusTags // ignore: cast_nullable_to_non_nullable
as List<String>,objective: freezed == objective ? _self.objective : objective // ignore: cast_nullable_to_non_nullable
as String?,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scheduledPublishAt: freezed == scheduledPublishAt ? _self.scheduledPublishAt : scheduledPublishAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int,blocks: freezed == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ClassProgramBlock>?,sessions: freezed == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ClassSession>?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as OrganizationLocation?,
  ));
}
/// Create a copy of ClassProgram
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
}/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $OrganizationLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClassProgram].
extension ClassProgramPatterns on ClassProgram {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassProgram value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassProgram() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassProgram value)  $default,){
final _that = this;
switch (_that) {
case _ClassProgram():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassProgram value)?  $default,){
final _that = this;
switch (_that) {
case _ClassProgram() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String locationId,  String? templateId,  DateTime programDate,  String title,  String? description,  List<String> focusTags,  String? objective,  String? coachNotes,  String status,  DateTime? scheduledPublishAt,  DateTime? publishedAt,  DateTime? cancelledAt,  String createdBy,  int currentVersion,  List<ClassProgramBlock>? blocks,  List<ClassSession>? sessions,  Organization? organization,  OrganizationLocation? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassProgram() when $default != null:
return $default(_that.id,_that.organizationId,_that.locationId,_that.templateId,_that.programDate,_that.title,_that.description,_that.focusTags,_that.objective,_that.coachNotes,_that.status,_that.scheduledPublishAt,_that.publishedAt,_that.cancelledAt,_that.createdBy,_that.currentVersion,_that.blocks,_that.sessions,_that.organization,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String locationId,  String? templateId,  DateTime programDate,  String title,  String? description,  List<String> focusTags,  String? objective,  String? coachNotes,  String status,  DateTime? scheduledPublishAt,  DateTime? publishedAt,  DateTime? cancelledAt,  String createdBy,  int currentVersion,  List<ClassProgramBlock>? blocks,  List<ClassSession>? sessions,  Organization? organization,  OrganizationLocation? location)  $default,) {final _that = this;
switch (_that) {
case _ClassProgram():
return $default(_that.id,_that.organizationId,_that.locationId,_that.templateId,_that.programDate,_that.title,_that.description,_that.focusTags,_that.objective,_that.coachNotes,_that.status,_that.scheduledPublishAt,_that.publishedAt,_that.cancelledAt,_that.createdBy,_that.currentVersion,_that.blocks,_that.sessions,_that.organization,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String locationId,  String? templateId,  DateTime programDate,  String title,  String? description,  List<String> focusTags,  String? objective,  String? coachNotes,  String status,  DateTime? scheduledPublishAt,  DateTime? publishedAt,  DateTime? cancelledAt,  String createdBy,  int currentVersion,  List<ClassProgramBlock>? blocks,  List<ClassSession>? sessions,  Organization? organization,  OrganizationLocation? location)?  $default,) {final _that = this;
switch (_that) {
case _ClassProgram() when $default != null:
return $default(_that.id,_that.organizationId,_that.locationId,_that.templateId,_that.programDate,_that.title,_that.description,_that.focusTags,_that.objective,_that.coachNotes,_that.status,_that.scheduledPublishAt,_that.publishedAt,_that.cancelledAt,_that.createdBy,_that.currentVersion,_that.blocks,_that.sessions,_that.organization,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassProgram implements ClassProgram {
  const _ClassProgram({required this.id, required this.organizationId, required this.locationId, this.templateId, required this.programDate, required this.title, this.description,  List<String> focusTags = const [], this.objective, this.coachNotes, this.status = 'draft', this.scheduledPublishAt, this.publishedAt, this.cancelledAt, required this.createdBy, this.currentVersion = 1,  List<ClassProgramBlock>? blocks,  List<ClassSession>? sessions, this.organization, this.location}): _focusTags = focusTags,_blocks = blocks,_sessions = sessions;
  factory _ClassProgram.fromJson(Map<String, dynamic> json) => _$ClassProgramFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String locationId;
@override final  String? templateId;
@override final  DateTime programDate;
@override final  String title;
@override final  String? description;
 final  List<String> _focusTags;
@override@JsonKey() List<String> get focusTags {
  if (_focusTags is EqualUnmodifiableListView) return _focusTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_focusTags);
}

@override final  String? objective;
@override final  String? coachNotes;
@override@JsonKey() final  String status;
@override final  DateTime? scheduledPublishAt;
@override final  DateTime? publishedAt;
@override final  DateTime? cancelledAt;
@override final  String createdBy;
@override@JsonKey() final  int currentVersion;
 final  List<ClassProgramBlock>? _blocks;
@override List<ClassProgramBlock>? get blocks {
  final value = _blocks;
  if (value == null) return null;
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ClassSession>? _sessions;
@override List<ClassSession>? get sessions {
  final value = _sessions;
  if (value == null) return null;
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  Organization? organization;
@override final  OrganizationLocation? location;

/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassProgramCopyWith<_ClassProgram> get copyWith => __$ClassProgramCopyWithImpl<_ClassProgram>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassProgramToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassProgram&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.programDate, programDate) || other.programDate == programDate)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.focusTags, _focusTags)&&(identical(other.objective, objective) || other.objective == objective)&&(identical(other.coachNotes, coachNotes) || other.coachNotes == coachNotes)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledPublishAt, scheduledPublishAt) || other.scheduledPublishAt == scheduledPublishAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&const DeepCollectionEquality().equals(other.blocks, _blocks)&&const DeepCollectionEquality().equals(other.sessions, _sessions)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,organizationId,locationId,templateId,programDate,title,description,const DeepCollectionEquality().hash(_focusTags),objective,coachNotes,status,scheduledPublishAt,publishedAt,cancelledAt,createdBy,currentVersion,const DeepCollectionEquality().hash(_blocks),const DeepCollectionEquality().hash(_sessions),organization,location]);
}

@override
String toString() {
    return 'ClassProgram(id: $id, organizationId: $organizationId, locationId: $locationId, templateId: $templateId, programDate: $programDate, title: $title, description: $description, focusTags: $focusTags, objective: $objective, coachNotes: $coachNotes, status: $status, scheduledPublishAt: $scheduledPublishAt, publishedAt: $publishedAt, cancelledAt: $cancelledAt, createdBy: $createdBy, currentVersion: $currentVersion, blocks: $blocks, sessions: $sessions, organization: $organization, location: $location)';
}


}

/// @nodoc
abstract mixin class _$ClassProgramCopyWith<$Res> implements $ClassProgramCopyWith<$Res> {
  factory _$ClassProgramCopyWith(_ClassProgram value, $Res Function(_ClassProgram) _then) = __$ClassProgramCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String locationId, String? templateId, DateTime programDate, String title, String? description, List<String> focusTags, String? objective, String? coachNotes, String status, DateTime? scheduledPublishAt, DateTime? publishedAt, DateTime? cancelledAt, String createdBy, int currentVersion, List<ClassProgramBlock>? blocks, List<ClassSession>? sessions, Organization? organization, OrganizationLocation? location
});


@override $OrganizationCopyWith<$Res>? get organization;@override $OrganizationLocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$ClassProgramCopyWithImpl<$Res>
    implements _$ClassProgramCopyWith<$Res> {
  __$ClassProgramCopyWithImpl(this._self, this._then);

  final _ClassProgram _self;
  final $Res Function(_ClassProgram) _then;

/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? locationId = null,Object? templateId = freezed,Object? programDate = null,Object? title = null,Object? description = freezed,Object? focusTags = null,Object? objective = freezed,Object? coachNotes = freezed,Object? status = null,Object? scheduledPublishAt = freezed,Object? publishedAt = freezed,Object? cancelledAt = freezed,Object? createdBy = null,Object? currentVersion = null,Object? blocks = freezed,Object? sessions = freezed,Object? organization = freezed,Object? location = freezed,}) {
  return _then(_ClassProgram(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,programDate: null == programDate ? _self.programDate : programDate // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,focusTags: null == focusTags ? _self._focusTags : focusTags // ignore: cast_nullable_to_non_nullable
as List<String>,objective: freezed == objective ? _self.objective : objective // ignore: cast_nullable_to_non_nullable
as String?,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scheduledPublishAt: freezed == scheduledPublishAt ? _self.scheduledPublishAt : scheduledPublishAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int,blocks: freezed == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ClassProgramBlock>?,sessions: freezed == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ClassSession>?,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as Organization?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as OrganizationLocation?,
  ));
}

/// Create a copy of ClassProgram
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
}/// Create a copy of ClassProgram
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $OrganizationLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$ClassProgramBlock {

 String get id; String get programId; String get blockType; String get title; String? get description; int? get durationMinutes; int get sortOrder; List<ClassBlockExercise>? get exercises;
/// Create a copy of ClassProgramBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassProgramBlockCopyWith<ClassProgramBlock> get copyWith => _$ClassProgramBlockCopyWithImpl<ClassProgramBlock>(this as ClassProgramBlock, _$identity);

  /// Serializes this ClassProgramBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassProgramBlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassProgramBlock&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.programId, _this.programId) || other.programId == _this.programId)&&(identical(other.blockType, _this.blockType) || other.blockType == _this.blockType)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassProgramBlock;
  return Object.hash(runtimeType,_this.id,_this.programId,_this.blockType,_this.title,_this.description,_this.durationMinutes,_this.sortOrder,const DeepCollectionEquality().hash(_this.exercises));
}

@override
String toString() {
  final _this = this as ClassProgramBlock;
  return 'ClassProgramBlock(id: ${_this.id}, programId: ${_this.programId}, blockType: ${_this.blockType}, title: ${_this.title}, description: ${_this.description}, durationMinutes: ${_this.durationMinutes}, sortOrder: ${_this.sortOrder}, exercises: ${_this.exercises})';
}


}

/// @nodoc
abstract mixin class $ClassProgramBlockCopyWith<$Res>  {
  factory $ClassProgramBlockCopyWith(ClassProgramBlock value, $Res Function(ClassProgramBlock) _then) = _$ClassProgramBlockCopyWithImpl;
@useResult
$Res call({
 String id, String programId, String blockType, String title, String? description, int? durationMinutes, int sortOrder, List<ClassBlockExercise>? exercises
});




}
/// @nodoc
class _$ClassProgramBlockCopyWithImpl<$Res>
    implements $ClassProgramBlockCopyWith<$Res> {
  _$ClassProgramBlockCopyWithImpl(this._self, this._then);

  final ClassProgramBlock _self;
  final $Res Function(ClassProgramBlock) _then;

/// Create a copy of ClassProgramBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? programId = null,Object? blockType = null,Object? title = null,Object? description = freezed,Object? durationMinutes = freezed,Object? sortOrder = null,Object? exercises = freezed,}) {
  return _then(ClassProgramBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,blockType: null == blockType ? _self.blockType : blockType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,exercises: freezed == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ClassBlockExercise>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassProgramBlock].
extension ClassProgramBlockPatterns on ClassProgramBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassProgramBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassProgramBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassProgramBlock value)  $default,){
final _that = this;
switch (_that) {
case _ClassProgramBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassProgramBlock value)?  $default,){
final _that = this;
switch (_that) {
case _ClassProgramBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String programId,  String blockType,  String title,  String? description,  int? durationMinutes,  int sortOrder,  List<ClassBlockExercise>? exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassProgramBlock() when $default != null:
return $default(_that.id,_that.programId,_that.blockType,_that.title,_that.description,_that.durationMinutes,_that.sortOrder,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String programId,  String blockType,  String title,  String? description,  int? durationMinutes,  int sortOrder,  List<ClassBlockExercise>? exercises)  $default,) {final _that = this;
switch (_that) {
case _ClassProgramBlock():
return $default(_that.id,_that.programId,_that.blockType,_that.title,_that.description,_that.durationMinutes,_that.sortOrder,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String programId,  String blockType,  String title,  String? description,  int? durationMinutes,  int sortOrder,  List<ClassBlockExercise>? exercises)?  $default,) {final _that = this;
switch (_that) {
case _ClassProgramBlock() when $default != null:
return $default(_that.id,_that.programId,_that.blockType,_that.title,_that.description,_that.durationMinutes,_that.sortOrder,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassProgramBlock implements ClassProgramBlock {
  const _ClassProgramBlock({required this.id, required this.programId, required this.blockType, required this.title, this.description, this.durationMinutes, required this.sortOrder,  List<ClassBlockExercise>? exercises}): _exercises = exercises;
  factory _ClassProgramBlock.fromJson(Map<String, dynamic> json) => _$ClassProgramBlockFromJson(json);

@override final  String id;
@override final  String programId;
@override final  String blockType;
@override final  String title;
@override final  String? description;
@override final  int? durationMinutes;
@override final  int sortOrder;
 final  List<ClassBlockExercise>? _exercises;
@override List<ClassBlockExercise>? get exercises {
  final value = _exercises;
  if (value == null) return null;
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClassProgramBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassProgramBlockCopyWith<_ClassProgramBlock> get copyWith => __$ClassProgramBlockCopyWithImpl<_ClassProgramBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassProgramBlockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassProgramBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.programId, programId) || other.programId == programId)&&(identical(other.blockType, blockType) || other.blockType == blockType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,programId,blockType,title,description,durationMinutes,sortOrder,const DeepCollectionEquality().hash(_exercises));
}

@override
String toString() {
    return 'ClassProgramBlock(id: $id, programId: $programId, blockType: $blockType, title: $title, description: $description, durationMinutes: $durationMinutes, sortOrder: $sortOrder, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$ClassProgramBlockCopyWith<$Res> implements $ClassProgramBlockCopyWith<$Res> {
  factory _$ClassProgramBlockCopyWith(_ClassProgramBlock value, $Res Function(_ClassProgramBlock) _then) = __$ClassProgramBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String programId, String blockType, String title, String? description, int? durationMinutes, int sortOrder, List<ClassBlockExercise>? exercises
});




}
/// @nodoc
class __$ClassProgramBlockCopyWithImpl<$Res>
    implements _$ClassProgramBlockCopyWith<$Res> {
  __$ClassProgramBlockCopyWithImpl(this._self, this._then);

  final _ClassProgramBlock _self;
  final $Res Function(_ClassProgramBlock) _then;

/// Create a copy of ClassProgramBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? programId = null,Object? blockType = null,Object? title = null,Object? description = freezed,Object? durationMinutes = freezed,Object? sortOrder = null,Object? exercises = freezed,}) {
  return _then(_ClassProgramBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,programId: null == programId ? _self.programId : programId // ignore: cast_nullable_to_non_nullable
as String,blockType: null == blockType ? _self.blockType : blockType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,exercises: freezed == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ClassBlockExercise>?,
  ));
}


}


/// @nodoc
mixin _$ClassBlockExercise {

 String get id; String get blockId; String get exerciseId; String? get variantId; int get sortOrder; int? get sets; String? get reps; String? get weightPrescription; int? get durationMs; double? get distanceM; String? get notes; Exercise? get exercise;
/// Create a copy of ClassBlockExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassBlockExerciseCopyWith<ClassBlockExercise> get copyWith => _$ClassBlockExerciseCopyWithImpl<ClassBlockExercise>(this as ClassBlockExercise, _$identity);

  /// Serializes this ClassBlockExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassBlockExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassBlockExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.blockId, _this.blockId) || other.blockId == _this.blockId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.sets, _this.sets) || other.sets == _this.sets)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.weightPrescription, _this.weightPrescription) || other.weightPrescription == _this.weightPrescription)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.distanceM, _this.distanceM) || other.distanceM == _this.distanceM)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.exercise, _this.exercise) || other.exercise == _this.exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassBlockExercise;
  return Object.hash(runtimeType,_this.id,_this.blockId,_this.exerciseId,_this.variantId,_this.sortOrder,_this.sets,_this.reps,_this.weightPrescription,_this.durationMs,_this.distanceM,_this.notes,_this.exercise);
}

@override
String toString() {
  final _this = this as ClassBlockExercise;
  return 'ClassBlockExercise(id: ${_this.id}, blockId: ${_this.blockId}, exerciseId: ${_this.exerciseId}, variantId: ${_this.variantId}, sortOrder: ${_this.sortOrder}, sets: ${_this.sets}, reps: ${_this.reps}, weightPrescription: ${_this.weightPrescription}, durationMs: ${_this.durationMs}, distanceM: ${_this.distanceM}, notes: ${_this.notes}, exercise: ${_this.exercise})';
}


}

/// @nodoc
abstract mixin class $ClassBlockExerciseCopyWith<$Res>  {
  factory $ClassBlockExerciseCopyWith(ClassBlockExercise value, $Res Function(ClassBlockExercise) _then) = _$ClassBlockExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String blockId, String exerciseId, String? variantId, int sortOrder, int? sets, String? reps, String? weightPrescription, int? durationMs, double? distanceM, String? notes, Exercise? exercise
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$ClassBlockExerciseCopyWithImpl<$Res>
    implements $ClassBlockExerciseCopyWith<$Res> {
  _$ClassBlockExerciseCopyWithImpl(this._self, this._then);

  final ClassBlockExercise _self;
  final $Res Function(ClassBlockExercise) _then;

/// Create a copy of ClassBlockExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? blockId = null,Object? exerciseId = null,Object? variantId = freezed,Object? sortOrder = null,Object? sets = freezed,Object? reps = freezed,Object? weightPrescription = freezed,Object? durationMs = freezed,Object? distanceM = freezed,Object? notes = freezed,Object? exercise = freezed,}) {
  return _then(ClassBlockExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String?,weightPrescription: freezed == weightPrescription ? _self.weightPrescription : weightPrescription // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,
  ));
}
/// Create a copy of ClassBlockExercise
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


/// Adds pattern-matching-related methods to [ClassBlockExercise].
extension ClassBlockExercisePatterns on ClassBlockExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassBlockExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassBlockExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassBlockExercise value)  $default,){
final _that = this;
switch (_that) {
case _ClassBlockExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassBlockExercise value)?  $default,){
final _that = this;
switch (_that) {
case _ClassBlockExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String blockId,  String exerciseId,  String? variantId,  int sortOrder,  int? sets,  String? reps,  String? weightPrescription,  int? durationMs,  double? distanceM,  String? notes,  Exercise? exercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassBlockExercise() when $default != null:
return $default(_that.id,_that.blockId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.sets,_that.reps,_that.weightPrescription,_that.durationMs,_that.distanceM,_that.notes,_that.exercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String blockId,  String exerciseId,  String? variantId,  int sortOrder,  int? sets,  String? reps,  String? weightPrescription,  int? durationMs,  double? distanceM,  String? notes,  Exercise? exercise)  $default,) {final _that = this;
switch (_that) {
case _ClassBlockExercise():
return $default(_that.id,_that.blockId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.sets,_that.reps,_that.weightPrescription,_that.durationMs,_that.distanceM,_that.notes,_that.exercise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String blockId,  String exerciseId,  String? variantId,  int sortOrder,  int? sets,  String? reps,  String? weightPrescription,  int? durationMs,  double? distanceM,  String? notes,  Exercise? exercise)?  $default,) {final _that = this;
switch (_that) {
case _ClassBlockExercise() when $default != null:
return $default(_that.id,_that.blockId,_that.exerciseId,_that.variantId,_that.sortOrder,_that.sets,_that.reps,_that.weightPrescription,_that.durationMs,_that.distanceM,_that.notes,_that.exercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassBlockExercise implements ClassBlockExercise {
  const _ClassBlockExercise({required this.id, required this.blockId, required this.exerciseId, this.variantId, required this.sortOrder, this.sets, this.reps, this.weightPrescription, this.durationMs, this.distanceM, this.notes, this.exercise});
  factory _ClassBlockExercise.fromJson(Map<String, dynamic> json) => _$ClassBlockExerciseFromJson(json);

@override final  String id;
@override final  String blockId;
@override final  String exerciseId;
@override final  String? variantId;
@override final  int sortOrder;
@override final  int? sets;
@override final  String? reps;
@override final  String? weightPrescription;
@override final  int? durationMs;
@override final  double? distanceM;
@override final  String? notes;
@override final  Exercise? exercise;

/// Create a copy of ClassBlockExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassBlockExerciseCopyWith<_ClassBlockExercise> get copyWith => __$ClassBlockExerciseCopyWithImpl<_ClassBlockExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassBlockExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassBlockExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.blockId, blockId) || other.blockId == blockId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightPrescription, weightPrescription) || other.weightPrescription == weightPrescription)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.exercise, exercise) || other.exercise == exercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,blockId,exerciseId,variantId,sortOrder,sets,reps,weightPrescription,durationMs,distanceM,notes,exercise);
}

@override
String toString() {
    return 'ClassBlockExercise(id: $id, blockId: $blockId, exerciseId: $exerciseId, variantId: $variantId, sortOrder: $sortOrder, sets: $sets, reps: $reps, weightPrescription: $weightPrescription, durationMs: $durationMs, distanceM: $distanceM, notes: $notes, exercise: $exercise)';
}


}

/// @nodoc
abstract mixin class _$ClassBlockExerciseCopyWith<$Res> implements $ClassBlockExerciseCopyWith<$Res> {
  factory _$ClassBlockExerciseCopyWith(_ClassBlockExercise value, $Res Function(_ClassBlockExercise) _then) = __$ClassBlockExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String blockId, String exerciseId, String? variantId, int sortOrder, int? sets, String? reps, String? weightPrescription, int? durationMs, double? distanceM, String? notes, Exercise? exercise
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$ClassBlockExerciseCopyWithImpl<$Res>
    implements _$ClassBlockExerciseCopyWith<$Res> {
  __$ClassBlockExerciseCopyWithImpl(this._self, this._then);

  final _ClassBlockExercise _self;
  final $Res Function(_ClassBlockExercise) _then;

/// Create a copy of ClassBlockExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? blockId = null,Object? exerciseId = null,Object? variantId = freezed,Object? sortOrder = null,Object? sets = freezed,Object? reps = freezed,Object? weightPrescription = freezed,Object? durationMs = freezed,Object? distanceM = freezed,Object? notes = freezed,Object? exercise = freezed,}) {
  return _then(_ClassBlockExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,blockId: null == blockId ? _self.blockId : blockId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as String?,weightPrescription: freezed == weightPrescription ? _self.weightPrescription : weightPrescription // ignore: cast_nullable_to_non_nullable
as String?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,
  ));
}

/// Create a copy of ClassBlockExercise
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
