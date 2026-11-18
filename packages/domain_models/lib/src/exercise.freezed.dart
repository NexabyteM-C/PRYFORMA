// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; String? get nameEs; String get category; String? get description; String get status; bool get isGlobal; String? get createdBy; List<ExerciseVariant>? get variants; List<ExerciseMetricDefinition>? get metricDefinitions;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Exercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.nameEs, _this.nameEs) || other.nameEs == _this.nameEs)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isGlobal, _this.isGlobal) || other.isGlobal == _this.isGlobal)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&const DeepCollectionEquality().equals(other.variants, _this.variants)&&const DeepCollectionEquality().equals(other.metricDefinitions, _this.metricDefinitions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Exercise;
  return Object.hash(runtimeType,_this.id,_this.name,_this.nameEs,_this.category,_this.description,_this.status,_this.isGlobal,_this.createdBy,const DeepCollectionEquality().hash(_this.variants),const DeepCollectionEquality().hash(_this.metricDefinitions));
}

@override
String toString() {
  final _this = this as Exercise;
  return 'Exercise(id: ${_this.id}, name: ${_this.name}, nameEs: ${_this.nameEs}, category: ${_this.category}, description: ${_this.description}, status: ${_this.status}, isGlobal: ${_this.isGlobal}, createdBy: ${_this.createdBy}, variants: ${_this.variants}, metricDefinitions: ${_this.metricDefinitions})';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? nameEs, String category, String? description, String status, bool isGlobal, String? createdBy, List<ExerciseVariant>? variants, List<ExerciseMetricDefinition>? metricDefinitions
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nameEs = freezed,Object? category = null,Object? description = freezed,Object? status = null,Object? isGlobal = null,Object? createdBy = freezed,Object? variants = freezed,Object? metricDefinitions = freezed,}) {
  return _then(Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEs: freezed == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,variants: freezed == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<ExerciseVariant>?,metricDefinitions: freezed == metricDefinitions ? _self.metricDefinitions : metricDefinitions // ignore: cast_nullable_to_non_nullable
as List<ExerciseMetricDefinition>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? nameEs,  String category,  String? description,  String status,  bool isGlobal,  String? createdBy,  List<ExerciseVariant>? variants,  List<ExerciseMetricDefinition>? metricDefinitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.nameEs,_that.category,_that.description,_that.status,_that.isGlobal,_that.createdBy,_that.variants,_that.metricDefinitions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? nameEs,  String category,  String? description,  String status,  bool isGlobal,  String? createdBy,  List<ExerciseVariant>? variants,  List<ExerciseMetricDefinition>? metricDefinitions)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.nameEs,_that.category,_that.description,_that.status,_that.isGlobal,_that.createdBy,_that.variants,_that.metricDefinitions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? nameEs,  String category,  String? description,  String status,  bool isGlobal,  String? createdBy,  List<ExerciseVariant>? variants,  List<ExerciseMetricDefinition>? metricDefinitions)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.nameEs,_that.category,_that.description,_that.status,_that.isGlobal,_that.createdBy,_that.variants,_that.metricDefinitions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise implements Exercise {
  const _Exercise({required this.id, required this.name, this.nameEs, required this.category, this.description, this.status = 'active', this.isGlobal = true, this.createdBy,  List<ExerciseVariant>? variants,  List<ExerciseMetricDefinition>? metricDefinitions}): _variants = variants,_metricDefinitions = metricDefinitions;
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? nameEs;
@override final  String category;
@override final  String? description;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool isGlobal;
@override final  String? createdBy;
 final  List<ExerciseVariant>? _variants;
@override List<ExerciseVariant>? get variants {
  final value = _variants;
  if (value == null) return null;
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ExerciseMetricDefinition>? _metricDefinitions;
@override List<ExerciseMetricDefinition>? get metricDefinitions {
  final value = _metricDefinitions;
  if (value == null) return null;
  if (_metricDefinitions is EqualUnmodifiableListView) return _metricDefinitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEs, nameEs) || other.nameEs == nameEs)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.isGlobal, isGlobal) || other.isGlobal == isGlobal)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other.variants, _variants)&&const DeepCollectionEquality().equals(other.metricDefinitions, _metricDefinitions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,nameEs,category,description,status,isGlobal,createdBy,const DeepCollectionEquality().hash(_variants),const DeepCollectionEquality().hash(_metricDefinitions));
}

@override
String toString() {
    return 'Exercise(id: $id, name: $name, nameEs: $nameEs, category: $category, description: $description, status: $status, isGlobal: $isGlobal, createdBy: $createdBy, variants: $variants, metricDefinitions: $metricDefinitions)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? nameEs, String category, String? description, String status, bool isGlobal, String? createdBy, List<ExerciseVariant>? variants, List<ExerciseMetricDefinition>? metricDefinitions
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nameEs = freezed,Object? category = null,Object? description = freezed,Object? status = null,Object? isGlobal = null,Object? createdBy = freezed,Object? variants = freezed,Object? metricDefinitions = freezed,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameEs: freezed == nameEs ? _self.nameEs : nameEs // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,variants: freezed == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<ExerciseVariant>?,metricDefinitions: freezed == metricDefinitions ? _self._metricDefinitions : metricDefinitions // ignore: cast_nullable_to_non_nullable
as List<ExerciseMetricDefinition>?,
  ));
}


}


/// @nodoc
mixin _$ExerciseVariant {

 String get id; String get exerciseId; String get name; String? get variantType;
/// Create a copy of ExerciseVariant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseVariantCopyWith<ExerciseVariant> get copyWith => _$ExerciseVariantCopyWithImpl<ExerciseVariant>(this as ExerciseVariant, _$identity);

  /// Serializes this ExerciseVariant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseVariant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseVariant&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.variantType, _this.variantType) || other.variantType == _this.variantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseVariant;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.name,_this.variantType);
}

@override
String toString() {
  final _this = this as ExerciseVariant;
  return 'ExerciseVariant(id: ${_this.id}, exerciseId: ${_this.exerciseId}, name: ${_this.name}, variantType: ${_this.variantType})';
}


}

/// @nodoc
abstract mixin class $ExerciseVariantCopyWith<$Res>  {
  factory $ExerciseVariantCopyWith(ExerciseVariant value, $Res Function(ExerciseVariant) _then) = _$ExerciseVariantCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String name, String? variantType
});




}
/// @nodoc
class _$ExerciseVariantCopyWithImpl<$Res>
    implements $ExerciseVariantCopyWith<$Res> {
  _$ExerciseVariantCopyWithImpl(this._self, this._then);

  final ExerciseVariant _self;
  final $Res Function(ExerciseVariant) _then;

/// Create a copy of ExerciseVariant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? variantType = freezed,}) {
  return _then(ExerciseVariant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variantType: freezed == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseVariant].
extension ExerciseVariantPatterns on ExerciseVariant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseVariant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseVariant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseVariant value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseVariant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseVariant value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseVariant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String? variantType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseVariant() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.variantType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String? variantType)  $default,) {final _that = this;
switch (_that) {
case _ExerciseVariant():
return $default(_that.id,_that.exerciseId,_that.name,_that.variantType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String name,  String? variantType)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseVariant() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.variantType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseVariant implements ExerciseVariant {
  const _ExerciseVariant({required this.id, required this.exerciseId, required this.name, this.variantType});
  factory _ExerciseVariant.fromJson(Map<String, dynamic> json) => _$ExerciseVariantFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String name;
@override final  String? variantType;

/// Create a copy of ExerciseVariant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseVariantCopyWith<_ExerciseVariant> get copyWith => __$ExerciseVariantCopyWithImpl<_ExerciseVariant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseVariantToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseVariant&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.variantType, variantType) || other.variantType == variantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,name,variantType);
}

@override
String toString() {
    return 'ExerciseVariant(id: $id, exerciseId: $exerciseId, name: $name, variantType: $variantType)';
}


}

/// @nodoc
abstract mixin class _$ExerciseVariantCopyWith<$Res> implements $ExerciseVariantCopyWith<$Res> {
  factory _$ExerciseVariantCopyWith(_ExerciseVariant value, $Res Function(_ExerciseVariant) _then) = __$ExerciseVariantCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String name, String? variantType
});




}
/// @nodoc
class __$ExerciseVariantCopyWithImpl<$Res>
    implements _$ExerciseVariantCopyWith<$Res> {
  __$ExerciseVariantCopyWithImpl(this._self, this._then);

  final _ExerciseVariant _self;
  final $Res Function(_ExerciseVariant) _then;

/// Create a copy of ExerciseVariant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? variantType = freezed,}) {
  return _then(_ExerciseVariant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variantType: freezed == variantType ? _self.variantType : variantType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExerciseMetricDefinition {

 String get id; String get exerciseId; String get metricCode; String get valueType; String? get unit; bool get isPrimary;
/// Create a copy of ExerciseMetricDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseMetricDefinitionCopyWith<ExerciseMetricDefinition> get copyWith => _$ExerciseMetricDefinitionCopyWithImpl<ExerciseMetricDefinition>(this as ExerciseMetricDefinition, _$identity);

  /// Serializes this ExerciseMetricDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseMetricDefinition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseMetricDefinition&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.metricCode, _this.metricCode) || other.metricCode == _this.metricCode)&&(identical(other.valueType, _this.valueType) || other.valueType == _this.valueType)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseMetricDefinition;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.metricCode,_this.valueType,_this.unit,_this.isPrimary);
}

@override
String toString() {
  final _this = this as ExerciseMetricDefinition;
  return 'ExerciseMetricDefinition(id: ${_this.id}, exerciseId: ${_this.exerciseId}, metricCode: ${_this.metricCode}, valueType: ${_this.valueType}, unit: ${_this.unit}, isPrimary: ${_this.isPrimary})';
}


}

/// @nodoc
abstract mixin class $ExerciseMetricDefinitionCopyWith<$Res>  {
  factory $ExerciseMetricDefinitionCopyWith(ExerciseMetricDefinition value, $Res Function(ExerciseMetricDefinition) _then) = _$ExerciseMetricDefinitionCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String metricCode, String valueType, String? unit, bool isPrimary
});




}
/// @nodoc
class _$ExerciseMetricDefinitionCopyWithImpl<$Res>
    implements $ExerciseMetricDefinitionCopyWith<$Res> {
  _$ExerciseMetricDefinitionCopyWithImpl(this._self, this._then);

  final ExerciseMetricDefinition _self;
  final $Res Function(ExerciseMetricDefinition) _then;

/// Create a copy of ExerciseMetricDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? metricCode = null,Object? valueType = null,Object? unit = freezed,Object? isPrimary = null,}) {
  return _then(ExerciseMetricDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,metricCode: null == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String,valueType: null == valueType ? _self.valueType : valueType // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseMetricDefinition].
extension ExerciseMetricDefinitionPatterns on ExerciseMetricDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseMetricDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseMetricDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseMetricDefinition value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseMetricDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseMetricDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseMetricDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String metricCode,  String valueType,  String? unit,  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseMetricDefinition() when $default != null:
return $default(_that.id,_that.exerciseId,_that.metricCode,_that.valueType,_that.unit,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String metricCode,  String valueType,  String? unit,  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _ExerciseMetricDefinition():
return $default(_that.id,_that.exerciseId,_that.metricCode,_that.valueType,_that.unit,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String metricCode,  String valueType,  String? unit,  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseMetricDefinition() when $default != null:
return $default(_that.id,_that.exerciseId,_that.metricCode,_that.valueType,_that.unit,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseMetricDefinition implements ExerciseMetricDefinition {
  const _ExerciseMetricDefinition({required this.id, required this.exerciseId, required this.metricCode, required this.valueType, this.unit, this.isPrimary = false});
  factory _ExerciseMetricDefinition.fromJson(Map<String, dynamic> json) => _$ExerciseMetricDefinitionFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String metricCode;
@override final  String valueType;
@override final  String? unit;
@override@JsonKey() final  bool isPrimary;

/// Create a copy of ExerciseMetricDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseMetricDefinitionCopyWith<_ExerciseMetricDefinition> get copyWith => __$ExerciseMetricDefinitionCopyWithImpl<_ExerciseMetricDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseMetricDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseMetricDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.metricCode, metricCode) || other.metricCode == metricCode)&&(identical(other.valueType, valueType) || other.valueType == valueType)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,metricCode,valueType,unit,isPrimary);
}

@override
String toString() {
    return 'ExerciseMetricDefinition(id: $id, exerciseId: $exerciseId, metricCode: $metricCode, valueType: $valueType, unit: $unit, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$ExerciseMetricDefinitionCopyWith<$Res> implements $ExerciseMetricDefinitionCopyWith<$Res> {
  factory _$ExerciseMetricDefinitionCopyWith(_ExerciseMetricDefinition value, $Res Function(_ExerciseMetricDefinition) _then) = __$ExerciseMetricDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String metricCode, String valueType, String? unit, bool isPrimary
});




}
/// @nodoc
class __$ExerciseMetricDefinitionCopyWithImpl<$Res>
    implements _$ExerciseMetricDefinitionCopyWith<$Res> {
  __$ExerciseMetricDefinitionCopyWithImpl(this._self, this._then);

  final _ExerciseMetricDefinition _self;
  final $Res Function(_ExerciseMetricDefinition) _then;

/// Create a copy of ExerciseMetricDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? metricCode = null,Object? valueType = null,Object? unit = freezed,Object? isPrimary = null,}) {
  return _then(_ExerciseMetricDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,metricCode: null == metricCode ? _self.metricCode : metricCode // ignore: cast_nullable_to_non_nullable
as String,valueType: null == valueType ? _self.valueType : valueType // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
