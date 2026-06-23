// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_type_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SensorTypeConfigurationRequest {

@JsonKey(name: 'sensor_type_name') String? get sensorTypeName;@JsonKey(name: 'category') int? get category;@JsonKey(name: 'name') String? get name;@JsonKey(name: 'description') String? get description;@JsonKey(name: 'value_format') String? get valueFormat;@JsonKey(name: 'min_expected_value') int? get minExpectedValue;@JsonKey(name: 'max_expected_value') int? get maxExpectedValue;@JsonKey(name: 'sampling_frequency') double? get samplingFrequency;@JsonKey(name: 'time_interval') String? get timeInterval;@JsonKey(name: 'is_active') bool? get isActive;@JsonKey(name: 'unit_ids') List<int>? get unitIds;@JsonKey(name: 'device_ids') List<String>? get deviceIds;
/// Create a copy of SensorTypeConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorTypeConfigurationRequestCopyWith<SensorTypeConfigurationRequest> get copyWith => _$SensorTypeConfigurationRequestCopyWithImpl<SensorTypeConfigurationRequest>(this as SensorTypeConfigurationRequest, _$identity);

  /// Serializes this SensorTypeConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorTypeConfigurationRequest&&(identical(other.sensorTypeName, sensorTypeName) || other.sensorTypeName == sensorTypeName)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.valueFormat, valueFormat) || other.valueFormat == valueFormat)&&(identical(other.minExpectedValue, minExpectedValue) || other.minExpectedValue == minExpectedValue)&&(identical(other.maxExpectedValue, maxExpectedValue) || other.maxExpectedValue == maxExpectedValue)&&(identical(other.samplingFrequency, samplingFrequency) || other.samplingFrequency == samplingFrequency)&&(identical(other.timeInterval, timeInterval) || other.timeInterval == timeInterval)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.unitIds, unitIds)&&const DeepCollectionEquality().equals(other.deviceIds, deviceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sensorTypeName,category,name,description,valueFormat,minExpectedValue,maxExpectedValue,samplingFrequency,timeInterval,isActive,const DeepCollectionEquality().hash(unitIds),const DeepCollectionEquality().hash(deviceIds));

@override
String toString() {
  return 'SensorTypeConfigurationRequest(sensorTypeName: $sensorTypeName, category: $category, name: $name, description: $description, valueFormat: $valueFormat, minExpectedValue: $minExpectedValue, maxExpectedValue: $maxExpectedValue, samplingFrequency: $samplingFrequency, timeInterval: $timeInterval, isActive: $isActive, unitIds: $unitIds, deviceIds: $deviceIds)';
}


}

/// @nodoc
abstract mixin class $SensorTypeConfigurationRequestCopyWith<$Res>  {
  factory $SensorTypeConfigurationRequestCopyWith(SensorTypeConfigurationRequest value, $Res Function(SensorTypeConfigurationRequest) _then) = _$SensorTypeConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sensor_type_name') String? sensorTypeName,@JsonKey(name: 'category') int? category,@JsonKey(name: 'name') String? name,@JsonKey(name: 'description') String? description,@JsonKey(name: 'value_format') String? valueFormat,@JsonKey(name: 'min_expected_value') int? minExpectedValue,@JsonKey(name: 'max_expected_value') int? maxExpectedValue,@JsonKey(name: 'sampling_frequency') double? samplingFrequency,@JsonKey(name: 'time_interval') String? timeInterval,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'unit_ids') List<int>? unitIds,@JsonKey(name: 'device_ids') List<String>? deviceIds
});




}
/// @nodoc
class _$SensorTypeConfigurationRequestCopyWithImpl<$Res>
    implements $SensorTypeConfigurationRequestCopyWith<$Res> {
  _$SensorTypeConfigurationRequestCopyWithImpl(this._self, this._then);

  final SensorTypeConfigurationRequest _self;
  final $Res Function(SensorTypeConfigurationRequest) _then;

/// Create a copy of SensorTypeConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sensorTypeName = freezed,Object? category = freezed,Object? name = freezed,Object? description = freezed,Object? valueFormat = freezed,Object? minExpectedValue = freezed,Object? maxExpectedValue = freezed,Object? samplingFrequency = freezed,Object? timeInterval = freezed,Object? isActive = freezed,Object? unitIds = freezed,Object? deviceIds = freezed,}) {
  return _then(_self.copyWith(
sensorTypeName: freezed == sensorTypeName ? _self.sensorTypeName : sensorTypeName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,valueFormat: freezed == valueFormat ? _self.valueFormat : valueFormat // ignore: cast_nullable_to_non_nullable
as String?,minExpectedValue: freezed == minExpectedValue ? _self.minExpectedValue : minExpectedValue // ignore: cast_nullable_to_non_nullable
as int?,maxExpectedValue: freezed == maxExpectedValue ? _self.maxExpectedValue : maxExpectedValue // ignore: cast_nullable_to_non_nullable
as int?,samplingFrequency: freezed == samplingFrequency ? _self.samplingFrequency : samplingFrequency // ignore: cast_nullable_to_non_nullable
as double?,timeInterval: freezed == timeInterval ? _self.timeInterval : timeInterval // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,unitIds: freezed == unitIds ? _self.unitIds : unitIds // ignore: cast_nullable_to_non_nullable
as List<int>?,deviceIds: freezed == deviceIds ? _self.deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorTypeConfigurationRequest].
extension SensorTypeConfigurationRequestPatterns on SensorTypeConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorTypeConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorTypeConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorTypeConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sensor_type_name')  String? sensorTypeName, @JsonKey(name: 'category')  int? category, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'min_expected_value')  int? minExpectedValue, @JsonKey(name: 'max_expected_value')  int? maxExpectedValue, @JsonKey(name: 'sampling_frequency')  double? samplingFrequency, @JsonKey(name: 'time_interval')  String? timeInterval, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'unit_ids')  List<int>? unitIds, @JsonKey(name: 'device_ids')  List<String>? deviceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest() when $default != null:
return $default(_that.sensorTypeName,_that.category,_that.name,_that.description,_that.valueFormat,_that.minExpectedValue,_that.maxExpectedValue,_that.samplingFrequency,_that.timeInterval,_that.isActive,_that.unitIds,_that.deviceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sensor_type_name')  String? sensorTypeName, @JsonKey(name: 'category')  int? category, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'min_expected_value')  int? minExpectedValue, @JsonKey(name: 'max_expected_value')  int? maxExpectedValue, @JsonKey(name: 'sampling_frequency')  double? samplingFrequency, @JsonKey(name: 'time_interval')  String? timeInterval, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'unit_ids')  List<int>? unitIds, @JsonKey(name: 'device_ids')  List<String>? deviceIds)  $default,) {final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest():
return $default(_that.sensorTypeName,_that.category,_that.name,_that.description,_that.valueFormat,_that.minExpectedValue,_that.maxExpectedValue,_that.samplingFrequency,_that.timeInterval,_that.isActive,_that.unitIds,_that.deviceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sensor_type_name')  String? sensorTypeName, @JsonKey(name: 'category')  int? category, @JsonKey(name: 'name')  String? name, @JsonKey(name: 'description')  String? description, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'min_expected_value')  int? minExpectedValue, @JsonKey(name: 'max_expected_value')  int? maxExpectedValue, @JsonKey(name: 'sampling_frequency')  double? samplingFrequency, @JsonKey(name: 'time_interval')  String? timeInterval, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'unit_ids')  List<int>? unitIds, @JsonKey(name: 'device_ids')  List<String>? deviceIds)?  $default,) {final _that = this;
switch (_that) {
case _SensorTypeConfigurationRequest() when $default != null:
return $default(_that.sensorTypeName,_that.category,_that.name,_that.description,_that.valueFormat,_that.minExpectedValue,_that.maxExpectedValue,_that.samplingFrequency,_that.timeInterval,_that.isActive,_that.unitIds,_that.deviceIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SensorTypeConfigurationRequest implements SensorTypeConfigurationRequest {
  const _SensorTypeConfigurationRequest({@JsonKey(name: 'sensor_type_name') this.sensorTypeName, @JsonKey(name: 'category') this.category, @JsonKey(name: 'name') this.name, @JsonKey(name: 'description') this.description, @JsonKey(name: 'value_format') this.valueFormat, @JsonKey(name: 'min_expected_value') this.minExpectedValue, @JsonKey(name: 'max_expected_value') this.maxExpectedValue, @JsonKey(name: 'sampling_frequency') this.samplingFrequency, @JsonKey(name: 'time_interval') this.timeInterval, @JsonKey(name: 'is_active') this.isActive, @JsonKey(name: 'unit_ids') final  List<int>? unitIds, @JsonKey(name: 'device_ids') final  List<String>? deviceIds}): _unitIds = unitIds,_deviceIds = deviceIds;
  factory _SensorTypeConfigurationRequest.fromJson(Map<String, dynamic> json) => _$SensorTypeConfigurationRequestFromJson(json);

@override@JsonKey(name: 'sensor_type_name') final  String? sensorTypeName;
@override@JsonKey(name: 'category') final  int? category;
@override@JsonKey(name: 'name') final  String? name;
@override@JsonKey(name: 'description') final  String? description;
@override@JsonKey(name: 'value_format') final  String? valueFormat;
@override@JsonKey(name: 'min_expected_value') final  int? minExpectedValue;
@override@JsonKey(name: 'max_expected_value') final  int? maxExpectedValue;
@override@JsonKey(name: 'sampling_frequency') final  double? samplingFrequency;
@override@JsonKey(name: 'time_interval') final  String? timeInterval;
@override@JsonKey(name: 'is_active') final  bool? isActive;
 final  List<int>? _unitIds;
@override@JsonKey(name: 'unit_ids') List<int>? get unitIds {
  final value = _unitIds;
  if (value == null) return null;
  if (_unitIds is EqualUnmodifiableListView) return _unitIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _deviceIds;
@override@JsonKey(name: 'device_ids') List<String>? get deviceIds {
  final value = _deviceIds;
  if (value == null) return null;
  if (_deviceIds is EqualUnmodifiableListView) return _deviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SensorTypeConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorTypeConfigurationRequestCopyWith<_SensorTypeConfigurationRequest> get copyWith => __$SensorTypeConfigurationRequestCopyWithImpl<_SensorTypeConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SensorTypeConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorTypeConfigurationRequest&&(identical(other.sensorTypeName, sensorTypeName) || other.sensorTypeName == sensorTypeName)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.valueFormat, valueFormat) || other.valueFormat == valueFormat)&&(identical(other.minExpectedValue, minExpectedValue) || other.minExpectedValue == minExpectedValue)&&(identical(other.maxExpectedValue, maxExpectedValue) || other.maxExpectedValue == maxExpectedValue)&&(identical(other.samplingFrequency, samplingFrequency) || other.samplingFrequency == samplingFrequency)&&(identical(other.timeInterval, timeInterval) || other.timeInterval == timeInterval)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._unitIds, _unitIds)&&const DeepCollectionEquality().equals(other._deviceIds, _deviceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sensorTypeName,category,name,description,valueFormat,minExpectedValue,maxExpectedValue,samplingFrequency,timeInterval,isActive,const DeepCollectionEquality().hash(_unitIds),const DeepCollectionEquality().hash(_deviceIds));

@override
String toString() {
  return 'SensorTypeConfigurationRequest(sensorTypeName: $sensorTypeName, category: $category, name: $name, description: $description, valueFormat: $valueFormat, minExpectedValue: $minExpectedValue, maxExpectedValue: $maxExpectedValue, samplingFrequency: $samplingFrequency, timeInterval: $timeInterval, isActive: $isActive, unitIds: $unitIds, deviceIds: $deviceIds)';
}


}

/// @nodoc
abstract mixin class _$SensorTypeConfigurationRequestCopyWith<$Res> implements $SensorTypeConfigurationRequestCopyWith<$Res> {
  factory _$SensorTypeConfigurationRequestCopyWith(_SensorTypeConfigurationRequest value, $Res Function(_SensorTypeConfigurationRequest) _then) = __$SensorTypeConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sensor_type_name') String? sensorTypeName,@JsonKey(name: 'category') int? category,@JsonKey(name: 'name') String? name,@JsonKey(name: 'description') String? description,@JsonKey(name: 'value_format') String? valueFormat,@JsonKey(name: 'min_expected_value') int? minExpectedValue,@JsonKey(name: 'max_expected_value') int? maxExpectedValue,@JsonKey(name: 'sampling_frequency') double? samplingFrequency,@JsonKey(name: 'time_interval') String? timeInterval,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'unit_ids') List<int>? unitIds,@JsonKey(name: 'device_ids') List<String>? deviceIds
});




}
/// @nodoc
class __$SensorTypeConfigurationRequestCopyWithImpl<$Res>
    implements _$SensorTypeConfigurationRequestCopyWith<$Res> {
  __$SensorTypeConfigurationRequestCopyWithImpl(this._self, this._then);

  final _SensorTypeConfigurationRequest _self;
  final $Res Function(_SensorTypeConfigurationRequest) _then;

/// Create a copy of SensorTypeConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sensorTypeName = freezed,Object? category = freezed,Object? name = freezed,Object? description = freezed,Object? valueFormat = freezed,Object? minExpectedValue = freezed,Object? maxExpectedValue = freezed,Object? samplingFrequency = freezed,Object? timeInterval = freezed,Object? isActive = freezed,Object? unitIds = freezed,Object? deviceIds = freezed,}) {
  return _then(_SensorTypeConfigurationRequest(
sensorTypeName: freezed == sensorTypeName ? _self.sensorTypeName : sensorTypeName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,valueFormat: freezed == valueFormat ? _self.valueFormat : valueFormat // ignore: cast_nullable_to_non_nullable
as String?,minExpectedValue: freezed == minExpectedValue ? _self.minExpectedValue : minExpectedValue // ignore: cast_nullable_to_non_nullable
as int?,maxExpectedValue: freezed == maxExpectedValue ? _self.maxExpectedValue : maxExpectedValue // ignore: cast_nullable_to_non_nullable
as int?,samplingFrequency: freezed == samplingFrequency ? _self.samplingFrequency : samplingFrequency // ignore: cast_nullable_to_non_nullable
as double?,timeInterval: freezed == timeInterval ? _self.timeInterval : timeInterval // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,unitIds: freezed == unitIds ? _self._unitIds : unitIds // ignore: cast_nullable_to_non_nullable
as List<int>?,deviceIds: freezed == deviceIds ? _self._deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
