// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceConfigurationRequest {

@JsonKey(name: 'device_unique_id') String? get deviceUniqueId;@JsonKey(name: 'data_type') String? get dataType;@JsonKey(name: 'time_unit') String? get timeUnit;@JsonKey(name: 'description') String? get description;@JsonKey(name: 'is_active') bool? get isActive;@JsonKey(name: 'frequency_secs') double? get frequency;@JsonKey(name: 'full_name') String? get fullName;@JsonKey(name: 'short_name') String? get shortName;@JsonKey(name: 'no_of_sensors') int? get numberOfSensors;
/// Create a copy of DeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceConfigurationRequestCopyWith<DeviceConfigurationRequest> get copyWith => _$DeviceConfigurationRequestCopyWithImpl<DeviceConfigurationRequest>(this as DeviceConfigurationRequest, _$identity);

  /// Serializes this DeviceConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceConfigurationRequest&&(identical(other.deviceUniqueId, deviceUniqueId) || other.deviceUniqueId == deviceUniqueId)&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.timeUnit, timeUnit) || other.timeUnit == timeUnit)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.numberOfSensors, numberOfSensors) || other.numberOfSensors == numberOfSensors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceUniqueId,dataType,timeUnit,description,isActive,frequency,fullName,shortName,numberOfSensors);

@override
String toString() {
  return 'DeviceConfigurationRequest(deviceUniqueId: $deviceUniqueId, dataType: $dataType, timeUnit: $timeUnit, description: $description, isActive: $isActive, frequency: $frequency, fullName: $fullName, shortName: $shortName, numberOfSensors: $numberOfSensors)';
}


}

/// @nodoc
abstract mixin class $DeviceConfigurationRequestCopyWith<$Res>  {
  factory $DeviceConfigurationRequestCopyWith(DeviceConfigurationRequest value, $Res Function(DeviceConfigurationRequest) _then) = _$DeviceConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'device_unique_id') String? deviceUniqueId,@JsonKey(name: 'data_type') String? dataType,@JsonKey(name: 'time_unit') String? timeUnit,@JsonKey(name: 'description') String? description,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'frequency_secs') double? frequency,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'short_name') String? shortName,@JsonKey(name: 'no_of_sensors') int? numberOfSensors
});




}
/// @nodoc
class _$DeviceConfigurationRequestCopyWithImpl<$Res>
    implements $DeviceConfigurationRequestCopyWith<$Res> {
  _$DeviceConfigurationRequestCopyWithImpl(this._self, this._then);

  final DeviceConfigurationRequest _self;
  final $Res Function(DeviceConfigurationRequest) _then;

/// Create a copy of DeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceUniqueId = freezed,Object? dataType = freezed,Object? timeUnit = freezed,Object? description = freezed,Object? isActive = freezed,Object? frequency = freezed,Object? fullName = freezed,Object? shortName = freezed,Object? numberOfSensors = freezed,}) {
  return _then(_self.copyWith(
deviceUniqueId: freezed == deviceUniqueId ? _self.deviceUniqueId : deviceUniqueId // ignore: cast_nullable_to_non_nullable
as String?,dataType: freezed == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as String?,timeUnit: freezed == timeUnit ? _self.timeUnit : timeUnit // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as double?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,numberOfSensors: freezed == numberOfSensors ? _self.numberOfSensors : numberOfSensors // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceConfigurationRequest].
extension DeviceConfigurationRequestPatterns on DeviceConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _DeviceConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'device_unique_id')  String? deviceUniqueId, @JsonKey(name: 'data_type')  String? dataType, @JsonKey(name: 'time_unit')  String? timeUnit, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'frequency_secs')  double? frequency, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'short_name')  String? shortName, @JsonKey(name: 'no_of_sensors')  int? numberOfSensors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceConfigurationRequest() when $default != null:
return $default(_that.deviceUniqueId,_that.dataType,_that.timeUnit,_that.description,_that.isActive,_that.frequency,_that.fullName,_that.shortName,_that.numberOfSensors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'device_unique_id')  String? deviceUniqueId, @JsonKey(name: 'data_type')  String? dataType, @JsonKey(name: 'time_unit')  String? timeUnit, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'frequency_secs')  double? frequency, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'short_name')  String? shortName, @JsonKey(name: 'no_of_sensors')  int? numberOfSensors)  $default,) {final _that = this;
switch (_that) {
case _DeviceConfigurationRequest():
return $default(_that.deviceUniqueId,_that.dataType,_that.timeUnit,_that.description,_that.isActive,_that.frequency,_that.fullName,_that.shortName,_that.numberOfSensors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'device_unique_id')  String? deviceUniqueId, @JsonKey(name: 'data_type')  String? dataType, @JsonKey(name: 'time_unit')  String? timeUnit, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'frequency_secs')  double? frequency, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'short_name')  String? shortName, @JsonKey(name: 'no_of_sensors')  int? numberOfSensors)?  $default,) {final _that = this;
switch (_that) {
case _DeviceConfigurationRequest() when $default != null:
return $default(_that.deviceUniqueId,_that.dataType,_that.timeUnit,_that.description,_that.isActive,_that.frequency,_that.fullName,_that.shortName,_that.numberOfSensors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceConfigurationRequest implements DeviceConfigurationRequest {
  const _DeviceConfigurationRequest({@JsonKey(name: 'device_unique_id') this.deviceUniqueId, @JsonKey(name: 'data_type') this.dataType, @JsonKey(name: 'time_unit') this.timeUnit, @JsonKey(name: 'description') this.description, @JsonKey(name: 'is_active') this.isActive, @JsonKey(name: 'frequency_secs') this.frequency, @JsonKey(name: 'full_name') this.fullName, @JsonKey(name: 'short_name') this.shortName, @JsonKey(name: 'no_of_sensors') this.numberOfSensors});
  factory _DeviceConfigurationRequest.fromJson(Map<String, dynamic> json) => _$DeviceConfigurationRequestFromJson(json);

@override@JsonKey(name: 'device_unique_id') final  String? deviceUniqueId;
@override@JsonKey(name: 'data_type') final  String? dataType;
@override@JsonKey(name: 'time_unit') final  String? timeUnit;
@override@JsonKey(name: 'description') final  String? description;
@override@JsonKey(name: 'is_active') final  bool? isActive;
@override@JsonKey(name: 'frequency_secs') final  double? frequency;
@override@JsonKey(name: 'full_name') final  String? fullName;
@override@JsonKey(name: 'short_name') final  String? shortName;
@override@JsonKey(name: 'no_of_sensors') final  int? numberOfSensors;

/// Create a copy of DeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceConfigurationRequestCopyWith<_DeviceConfigurationRequest> get copyWith => __$DeviceConfigurationRequestCopyWithImpl<_DeviceConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceConfigurationRequest&&(identical(other.deviceUniqueId, deviceUniqueId) || other.deviceUniqueId == deviceUniqueId)&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.timeUnit, timeUnit) || other.timeUnit == timeUnit)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.numberOfSensors, numberOfSensors) || other.numberOfSensors == numberOfSensors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceUniqueId,dataType,timeUnit,description,isActive,frequency,fullName,shortName,numberOfSensors);

@override
String toString() {
  return 'DeviceConfigurationRequest(deviceUniqueId: $deviceUniqueId, dataType: $dataType, timeUnit: $timeUnit, description: $description, isActive: $isActive, frequency: $frequency, fullName: $fullName, shortName: $shortName, numberOfSensors: $numberOfSensors)';
}


}

/// @nodoc
abstract mixin class _$DeviceConfigurationRequestCopyWith<$Res> implements $DeviceConfigurationRequestCopyWith<$Res> {
  factory _$DeviceConfigurationRequestCopyWith(_DeviceConfigurationRequest value, $Res Function(_DeviceConfigurationRequest) _then) = __$DeviceConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'device_unique_id') String? deviceUniqueId,@JsonKey(name: 'data_type') String? dataType,@JsonKey(name: 'time_unit') String? timeUnit,@JsonKey(name: 'description') String? description,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'frequency_secs') double? frequency,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'short_name') String? shortName,@JsonKey(name: 'no_of_sensors') int? numberOfSensors
});




}
/// @nodoc
class __$DeviceConfigurationRequestCopyWithImpl<$Res>
    implements _$DeviceConfigurationRequestCopyWith<$Res> {
  __$DeviceConfigurationRequestCopyWithImpl(this._self, this._then);

  final _DeviceConfigurationRequest _self;
  final $Res Function(_DeviceConfigurationRequest) _then;

/// Create a copy of DeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceUniqueId = freezed,Object? dataType = freezed,Object? timeUnit = freezed,Object? description = freezed,Object? isActive = freezed,Object? frequency = freezed,Object? fullName = freezed,Object? shortName = freezed,Object? numberOfSensors = freezed,}) {
  return _then(_DeviceConfigurationRequest(
deviceUniqueId: freezed == deviceUniqueId ? _self.deviceUniqueId : deviceUniqueId // ignore: cast_nullable_to_non_nullable
as String?,dataType: freezed == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as String?,timeUnit: freezed == timeUnit ? _self.timeUnit : timeUnit // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as double?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,numberOfSensors: freezed == numberOfSensors ? _self.numberOfSensors : numberOfSensors // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
