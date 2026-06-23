// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachConfigurationRequest {

@JsonKey(name: 'entity_type') String? get entityType;@JsonKey(name: 'coach_unique_id') String? get coachUniqueId;@JsonKey(name: 'coach_display_id') String? get coachDisplayId;@JsonKey(name: 'manufacturing_year') String? get manufacturingYear;@JsonKey(name: 'make_of_coach') String? get makeOfCoach;@JsonKey(name: 'type_of_coach') String? get typeOfCoach;@JsonKey(name: 'no_of_master_module') int? get noOfMasterModule;@JsonKey(name: 'coach_status') String? get coachStatus;@JsonKey(name: 'position') int? get position;
/// Create a copy of CoachConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachConfigurationRequestCopyWith<CoachConfigurationRequest> get copyWith => _$CoachConfigurationRequestCopyWithImpl<CoachConfigurationRequest>(this as CoachConfigurationRequest, _$identity);

  /// Serializes this CoachConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachConfigurationRequest&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.coachUniqueId, coachUniqueId) || other.coachUniqueId == coachUniqueId)&&(identical(other.coachDisplayId, coachDisplayId) || other.coachDisplayId == coachDisplayId)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear)&&(identical(other.makeOfCoach, makeOfCoach) || other.makeOfCoach == makeOfCoach)&&(identical(other.typeOfCoach, typeOfCoach) || other.typeOfCoach == typeOfCoach)&&(identical(other.noOfMasterModule, noOfMasterModule) || other.noOfMasterModule == noOfMasterModule)&&(identical(other.coachStatus, coachStatus) || other.coachStatus == coachStatus)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,coachUniqueId,coachDisplayId,manufacturingYear,makeOfCoach,typeOfCoach,noOfMasterModule,coachStatus,position);

@override
String toString() {
  return 'CoachConfigurationRequest(entityType: $entityType, coachUniqueId: $coachUniqueId, coachDisplayId: $coachDisplayId, manufacturingYear: $manufacturingYear, makeOfCoach: $makeOfCoach, typeOfCoach: $typeOfCoach, noOfMasterModule: $noOfMasterModule, coachStatus: $coachStatus, position: $position)';
}


}

/// @nodoc
abstract mixin class $CoachConfigurationRequestCopyWith<$Res>  {
  factory $CoachConfigurationRequestCopyWith(CoachConfigurationRequest value, $Res Function(CoachConfigurationRequest) _then) = _$CoachConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'entity_type') String? entityType,@JsonKey(name: 'coach_unique_id') String? coachUniqueId,@JsonKey(name: 'coach_display_id') String? coachDisplayId,@JsonKey(name: 'manufacturing_year') String? manufacturingYear,@JsonKey(name: 'make_of_coach') String? makeOfCoach,@JsonKey(name: 'type_of_coach') String? typeOfCoach,@JsonKey(name: 'no_of_master_module') int? noOfMasterModule,@JsonKey(name: 'coach_status') String? coachStatus,@JsonKey(name: 'position') int? position
});




}
/// @nodoc
class _$CoachConfigurationRequestCopyWithImpl<$Res>
    implements $CoachConfigurationRequestCopyWith<$Res> {
  _$CoachConfigurationRequestCopyWithImpl(this._self, this._then);

  final CoachConfigurationRequest _self;
  final $Res Function(CoachConfigurationRequest) _then;

/// Create a copy of CoachConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = freezed,Object? coachUniqueId = freezed,Object? coachDisplayId = freezed,Object? manufacturingYear = freezed,Object? makeOfCoach = freezed,Object? typeOfCoach = freezed,Object? noOfMasterModule = freezed,Object? coachStatus = freezed,Object? position = freezed,}) {
  return _then(_self.copyWith(
entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,coachUniqueId: freezed == coachUniqueId ? _self.coachUniqueId : coachUniqueId // ignore: cast_nullable_to_non_nullable
as String?,coachDisplayId: freezed == coachDisplayId ? _self.coachDisplayId : coachDisplayId // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as String?,makeOfCoach: freezed == makeOfCoach ? _self.makeOfCoach : makeOfCoach // ignore: cast_nullable_to_non_nullable
as String?,typeOfCoach: freezed == typeOfCoach ? _self.typeOfCoach : typeOfCoach // ignore: cast_nullable_to_non_nullable
as String?,noOfMasterModule: freezed == noOfMasterModule ? _self.noOfMasterModule : noOfMasterModule // ignore: cast_nullable_to_non_nullable
as int?,coachStatus: freezed == coachStatus ? _self.coachStatus : coachStatus // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachConfigurationRequest].
extension CoachConfigurationRequestPatterns on CoachConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _CoachConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CoachConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'entity_type')  String? entityType, @JsonKey(name: 'coach_unique_id')  String? coachUniqueId, @JsonKey(name: 'coach_display_id')  String? coachDisplayId, @JsonKey(name: 'manufacturing_year')  String? manufacturingYear, @JsonKey(name: 'make_of_coach')  String? makeOfCoach, @JsonKey(name: 'type_of_coach')  String? typeOfCoach, @JsonKey(name: 'no_of_master_module')  int? noOfMasterModule, @JsonKey(name: 'coach_status')  String? coachStatus, @JsonKey(name: 'position')  int? position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachConfigurationRequest() when $default != null:
return $default(_that.entityType,_that.coachUniqueId,_that.coachDisplayId,_that.manufacturingYear,_that.makeOfCoach,_that.typeOfCoach,_that.noOfMasterModule,_that.coachStatus,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'entity_type')  String? entityType, @JsonKey(name: 'coach_unique_id')  String? coachUniqueId, @JsonKey(name: 'coach_display_id')  String? coachDisplayId, @JsonKey(name: 'manufacturing_year')  String? manufacturingYear, @JsonKey(name: 'make_of_coach')  String? makeOfCoach, @JsonKey(name: 'type_of_coach')  String? typeOfCoach, @JsonKey(name: 'no_of_master_module')  int? noOfMasterModule, @JsonKey(name: 'coach_status')  String? coachStatus, @JsonKey(name: 'position')  int? position)  $default,) {final _that = this;
switch (_that) {
case _CoachConfigurationRequest():
return $default(_that.entityType,_that.coachUniqueId,_that.coachDisplayId,_that.manufacturingYear,_that.makeOfCoach,_that.typeOfCoach,_that.noOfMasterModule,_that.coachStatus,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'entity_type')  String? entityType, @JsonKey(name: 'coach_unique_id')  String? coachUniqueId, @JsonKey(name: 'coach_display_id')  String? coachDisplayId, @JsonKey(name: 'manufacturing_year')  String? manufacturingYear, @JsonKey(name: 'make_of_coach')  String? makeOfCoach, @JsonKey(name: 'type_of_coach')  String? typeOfCoach, @JsonKey(name: 'no_of_master_module')  int? noOfMasterModule, @JsonKey(name: 'coach_status')  String? coachStatus, @JsonKey(name: 'position')  int? position)?  $default,) {final _that = this;
switch (_that) {
case _CoachConfigurationRequest() when $default != null:
return $default(_that.entityType,_that.coachUniqueId,_that.coachDisplayId,_that.manufacturingYear,_that.makeOfCoach,_that.typeOfCoach,_that.noOfMasterModule,_that.coachStatus,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachConfigurationRequest implements CoachConfigurationRequest {
  const _CoachConfigurationRequest({@JsonKey(name: 'entity_type') this.entityType, @JsonKey(name: 'coach_unique_id') this.coachUniqueId, @JsonKey(name: 'coach_display_id') this.coachDisplayId, @JsonKey(name: 'manufacturing_year') this.manufacturingYear, @JsonKey(name: 'make_of_coach') this.makeOfCoach, @JsonKey(name: 'type_of_coach') this.typeOfCoach, @JsonKey(name: 'no_of_master_module') this.noOfMasterModule, @JsonKey(name: 'coach_status') this.coachStatus, @JsonKey(name: 'position') this.position});
  factory _CoachConfigurationRequest.fromJson(Map<String, dynamic> json) => _$CoachConfigurationRequestFromJson(json);

@override@JsonKey(name: 'entity_type') final  String? entityType;
@override@JsonKey(name: 'coach_unique_id') final  String? coachUniqueId;
@override@JsonKey(name: 'coach_display_id') final  String? coachDisplayId;
@override@JsonKey(name: 'manufacturing_year') final  String? manufacturingYear;
@override@JsonKey(name: 'make_of_coach') final  String? makeOfCoach;
@override@JsonKey(name: 'type_of_coach') final  String? typeOfCoach;
@override@JsonKey(name: 'no_of_master_module') final  int? noOfMasterModule;
@override@JsonKey(name: 'coach_status') final  String? coachStatus;
@override@JsonKey(name: 'position') final  int? position;

/// Create a copy of CoachConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachConfigurationRequestCopyWith<_CoachConfigurationRequest> get copyWith => __$CoachConfigurationRequestCopyWithImpl<_CoachConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachConfigurationRequest&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.coachUniqueId, coachUniqueId) || other.coachUniqueId == coachUniqueId)&&(identical(other.coachDisplayId, coachDisplayId) || other.coachDisplayId == coachDisplayId)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear)&&(identical(other.makeOfCoach, makeOfCoach) || other.makeOfCoach == makeOfCoach)&&(identical(other.typeOfCoach, typeOfCoach) || other.typeOfCoach == typeOfCoach)&&(identical(other.noOfMasterModule, noOfMasterModule) || other.noOfMasterModule == noOfMasterModule)&&(identical(other.coachStatus, coachStatus) || other.coachStatus == coachStatus)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,entityType,coachUniqueId,coachDisplayId,manufacturingYear,makeOfCoach,typeOfCoach,noOfMasterModule,coachStatus,position);

@override
String toString() {
  return 'CoachConfigurationRequest(entityType: $entityType, coachUniqueId: $coachUniqueId, coachDisplayId: $coachDisplayId, manufacturingYear: $manufacturingYear, makeOfCoach: $makeOfCoach, typeOfCoach: $typeOfCoach, noOfMasterModule: $noOfMasterModule, coachStatus: $coachStatus, position: $position)';
}


}

/// @nodoc
abstract mixin class _$CoachConfigurationRequestCopyWith<$Res> implements $CoachConfigurationRequestCopyWith<$Res> {
  factory _$CoachConfigurationRequestCopyWith(_CoachConfigurationRequest value, $Res Function(_CoachConfigurationRequest) _then) = __$CoachConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'entity_type') String? entityType,@JsonKey(name: 'coach_unique_id') String? coachUniqueId,@JsonKey(name: 'coach_display_id') String? coachDisplayId,@JsonKey(name: 'manufacturing_year') String? manufacturingYear,@JsonKey(name: 'make_of_coach') String? makeOfCoach,@JsonKey(name: 'type_of_coach') String? typeOfCoach,@JsonKey(name: 'no_of_master_module') int? noOfMasterModule,@JsonKey(name: 'coach_status') String? coachStatus,@JsonKey(name: 'position') int? position
});




}
/// @nodoc
class __$CoachConfigurationRequestCopyWithImpl<$Res>
    implements _$CoachConfigurationRequestCopyWith<$Res> {
  __$CoachConfigurationRequestCopyWithImpl(this._self, this._then);

  final _CoachConfigurationRequest _self;
  final $Res Function(_CoachConfigurationRequest) _then;

/// Create a copy of CoachConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = freezed,Object? coachUniqueId = freezed,Object? coachDisplayId = freezed,Object? manufacturingYear = freezed,Object? makeOfCoach = freezed,Object? typeOfCoach = freezed,Object? noOfMasterModule = freezed,Object? coachStatus = freezed,Object? position = freezed,}) {
  return _then(_CoachConfigurationRequest(
entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,coachUniqueId: freezed == coachUniqueId ? _self.coachUniqueId : coachUniqueId // ignore: cast_nullable_to_non_nullable
as String?,coachDisplayId: freezed == coachDisplayId ? _self.coachDisplayId : coachDisplayId // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as String?,makeOfCoach: freezed == makeOfCoach ? _self.makeOfCoach : makeOfCoach // ignore: cast_nullable_to_non_nullable
as String?,typeOfCoach: freezed == typeOfCoach ? _self.typeOfCoach : typeOfCoach // ignore: cast_nullable_to_non_nullable
as String?,noOfMasterModule: freezed == noOfMasterModule ? _self.noOfMasterModule : noOfMasterModule // ignore: cast_nullable_to_non_nullable
as int?,coachStatus: freezed == coachStatus ? _self.coachStatus : coachStatus // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
