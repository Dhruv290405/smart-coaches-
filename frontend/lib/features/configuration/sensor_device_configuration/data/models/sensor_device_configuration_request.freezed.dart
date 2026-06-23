// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_device_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SensorDeviceConfigurationRequest {

@JsonKey(name: 'coach_id') int? get coachId;@JsonKey(name: 'master_module_id') int? get masterModuleId;@JsonKey(name: 'device_id') String? get deviceId;@JsonKey(name: 'sensors') List<SensorRequest>? get sensors;
/// Create a copy of SensorDeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorDeviceConfigurationRequestCopyWith<SensorDeviceConfigurationRequest> get copyWith => _$SensorDeviceConfigurationRequestCopyWithImpl<SensorDeviceConfigurationRequest>(this as SensorDeviceConfigurationRequest, _$identity);

  /// Serializes this SensorDeviceConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorDeviceConfigurationRequest&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.masterModuleId, masterModuleId) || other.masterModuleId == masterModuleId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&const DeepCollectionEquality().equals(other.sensors, sensors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coachId,masterModuleId,deviceId,const DeepCollectionEquality().hash(sensors));

@override
String toString() {
  return 'SensorDeviceConfigurationRequest(coachId: $coachId, masterModuleId: $masterModuleId, deviceId: $deviceId, sensors: $sensors)';
}


}

/// @nodoc
abstract mixin class $SensorDeviceConfigurationRequestCopyWith<$Res>  {
  factory $SensorDeviceConfigurationRequestCopyWith(SensorDeviceConfigurationRequest value, $Res Function(SensorDeviceConfigurationRequest) _then) = _$SensorDeviceConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'coach_id') int? coachId,@JsonKey(name: 'master_module_id') int? masterModuleId,@JsonKey(name: 'device_id') String? deviceId,@JsonKey(name: 'sensors') List<SensorRequest>? sensors
});




}
/// @nodoc
class _$SensorDeviceConfigurationRequestCopyWithImpl<$Res>
    implements $SensorDeviceConfigurationRequestCopyWith<$Res> {
  _$SensorDeviceConfigurationRequestCopyWithImpl(this._self, this._then);

  final SensorDeviceConfigurationRequest _self;
  final $Res Function(SensorDeviceConfigurationRequest) _then;

/// Create a copy of SensorDeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coachId = freezed,Object? masterModuleId = freezed,Object? deviceId = freezed,Object? sensors = freezed,}) {
  return _then(_self.copyWith(
coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as int?,masterModuleId: freezed == masterModuleId ? _self.masterModuleId : masterModuleId // ignore: cast_nullable_to_non_nullable
as int?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,sensors: freezed == sensors ? _self.sensors : sensors // ignore: cast_nullable_to_non_nullable
as List<SensorRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorDeviceConfigurationRequest].
extension SensorDeviceConfigurationRequestPatterns on SensorDeviceConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorDeviceConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorDeviceConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorDeviceConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'master_module_id')  int? masterModuleId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'sensors')  List<SensorRequest>? sensors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest() when $default != null:
return $default(_that.coachId,_that.masterModuleId,_that.deviceId,_that.sensors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'master_module_id')  int? masterModuleId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'sensors')  List<SensorRequest>? sensors)  $default,) {final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest():
return $default(_that.coachId,_that.masterModuleId,_that.deviceId,_that.sensors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'master_module_id')  int? masterModuleId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'sensors')  List<SensorRequest>? sensors)?  $default,) {final _that = this;
switch (_that) {
case _SensorDeviceConfigurationRequest() when $default != null:
return $default(_that.coachId,_that.masterModuleId,_that.deviceId,_that.sensors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SensorDeviceConfigurationRequest implements SensorDeviceConfigurationRequest {
  const _SensorDeviceConfigurationRequest({@JsonKey(name: 'coach_id') this.coachId, @JsonKey(name: 'master_module_id') this.masterModuleId, @JsonKey(name: 'device_id') this.deviceId, @JsonKey(name: 'sensors') final  List<SensorRequest>? sensors}): _sensors = sensors;
  factory _SensorDeviceConfigurationRequest.fromJson(Map<String, dynamic> json) => _$SensorDeviceConfigurationRequestFromJson(json);

@override@JsonKey(name: 'coach_id') final  int? coachId;
@override@JsonKey(name: 'master_module_id') final  int? masterModuleId;
@override@JsonKey(name: 'device_id') final  String? deviceId;
 final  List<SensorRequest>? _sensors;
@override@JsonKey(name: 'sensors') List<SensorRequest>? get sensors {
  final value = _sensors;
  if (value == null) return null;
  if (_sensors is EqualUnmodifiableListView) return _sensors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SensorDeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorDeviceConfigurationRequestCopyWith<_SensorDeviceConfigurationRequest> get copyWith => __$SensorDeviceConfigurationRequestCopyWithImpl<_SensorDeviceConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SensorDeviceConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorDeviceConfigurationRequest&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.masterModuleId, masterModuleId) || other.masterModuleId == masterModuleId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&const DeepCollectionEquality().equals(other._sensors, _sensors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coachId,masterModuleId,deviceId,const DeepCollectionEquality().hash(_sensors));

@override
String toString() {
  return 'SensorDeviceConfigurationRequest(coachId: $coachId, masterModuleId: $masterModuleId, deviceId: $deviceId, sensors: $sensors)';
}


}

/// @nodoc
abstract mixin class _$SensorDeviceConfigurationRequestCopyWith<$Res> implements $SensorDeviceConfigurationRequestCopyWith<$Res> {
  factory _$SensorDeviceConfigurationRequestCopyWith(_SensorDeviceConfigurationRequest value, $Res Function(_SensorDeviceConfigurationRequest) _then) = __$SensorDeviceConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'coach_id') int? coachId,@JsonKey(name: 'master_module_id') int? masterModuleId,@JsonKey(name: 'device_id') String? deviceId,@JsonKey(name: 'sensors') List<SensorRequest>? sensors
});




}
/// @nodoc
class __$SensorDeviceConfigurationRequestCopyWithImpl<$Res>
    implements _$SensorDeviceConfigurationRequestCopyWith<$Res> {
  __$SensorDeviceConfigurationRequestCopyWithImpl(this._self, this._then);

  final _SensorDeviceConfigurationRequest _self;
  final $Res Function(_SensorDeviceConfigurationRequest) _then;

/// Create a copy of SensorDeviceConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coachId = freezed,Object? masterModuleId = freezed,Object? deviceId = freezed,Object? sensors = freezed,}) {
  return _then(_SensorDeviceConfigurationRequest(
coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as int?,masterModuleId: freezed == masterModuleId ? _self.masterModuleId : masterModuleId // ignore: cast_nullable_to_non_nullable
as int?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,sensors: freezed == sensors ? _self._sensors : sensors // ignore: cast_nullable_to_non_nullable
as List<SensorRequest>?,
  ));
}


}


/// @nodoc
mixin _$SensorRequest {

@JsonKey(name: 'sensor_id') String? get sensorId;@JsonKey(name: 'sensor_make_id') int? get sensorMakeId;@JsonKey(name: 'install_date') String? get installDate;@JsonKey(name: 'placement') String? get placement;@JsonKey(name: 'location') String? get location;@JsonKey(name: 'remarks') String? get remarks;
/// Create a copy of SensorRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorRequestCopyWith<SensorRequest> get copyWith => _$SensorRequestCopyWithImpl<SensorRequest>(this as SensorRequest, _$identity);

  /// Serializes this SensorRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorRequest&&(identical(other.sensorId, sensorId) || other.sensorId == sensorId)&&(identical(other.sensorMakeId, sensorMakeId) || other.sensorMakeId == sensorMakeId)&&(identical(other.installDate, installDate) || other.installDate == installDate)&&(identical(other.placement, placement) || other.placement == placement)&&(identical(other.location, location) || other.location == location)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sensorId,sensorMakeId,installDate,placement,location,remarks);

@override
String toString() {
  return 'SensorRequest(sensorId: $sensorId, sensorMakeId: $sensorMakeId, installDate: $installDate, placement: $placement, location: $location, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $SensorRequestCopyWith<$Res>  {
  factory $SensorRequestCopyWith(SensorRequest value, $Res Function(SensorRequest) _then) = _$SensorRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sensor_id') String? sensorId,@JsonKey(name: 'sensor_make_id') int? sensorMakeId,@JsonKey(name: 'install_date') String? installDate,@JsonKey(name: 'placement') String? placement,@JsonKey(name: 'location') String? location,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class _$SensorRequestCopyWithImpl<$Res>
    implements $SensorRequestCopyWith<$Res> {
  _$SensorRequestCopyWithImpl(this._self, this._then);

  final SensorRequest _self;
  final $Res Function(SensorRequest) _then;

/// Create a copy of SensorRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sensorId = freezed,Object? sensorMakeId = freezed,Object? installDate = freezed,Object? placement = freezed,Object? location = freezed,Object? remarks = freezed,}) {
  return _then(_self.copyWith(
sensorId: freezed == sensorId ? _self.sensorId : sensorId // ignore: cast_nullable_to_non_nullable
as String?,sensorMakeId: freezed == sensorMakeId ? _self.sensorMakeId : sensorMakeId // ignore: cast_nullable_to_non_nullable
as int?,installDate: freezed == installDate ? _self.installDate : installDate // ignore: cast_nullable_to_non_nullable
as String?,placement: freezed == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorRequest].
extension SensorRequestPatterns on SensorRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorRequest value)  $default,){
final _that = this;
switch (_that) {
case _SensorRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SensorRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'sensor_id')  String? sensorId, @JsonKey(name: 'sensor_make_id')  int? sensorMakeId, @JsonKey(name: 'install_date')  String? installDate, @JsonKey(name: 'placement')  String? placement, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'remarks')  String? remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorRequest() when $default != null:
return $default(_that.sensorId,_that.sensorMakeId,_that.installDate,_that.placement,_that.location,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'sensor_id')  String? sensorId, @JsonKey(name: 'sensor_make_id')  int? sensorMakeId, @JsonKey(name: 'install_date')  String? installDate, @JsonKey(name: 'placement')  String? placement, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'remarks')  String? remarks)  $default,) {final _that = this;
switch (_that) {
case _SensorRequest():
return $default(_that.sensorId,_that.sensorMakeId,_that.installDate,_that.placement,_that.location,_that.remarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'sensor_id')  String? sensorId, @JsonKey(name: 'sensor_make_id')  int? sensorMakeId, @JsonKey(name: 'install_date')  String? installDate, @JsonKey(name: 'placement')  String? placement, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'remarks')  String? remarks)?  $default,) {final _that = this;
switch (_that) {
case _SensorRequest() when $default != null:
return $default(_that.sensorId,_that.sensorMakeId,_that.installDate,_that.placement,_that.location,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SensorRequest implements SensorRequest {
  const _SensorRequest({@JsonKey(name: 'sensor_id') this.sensorId, @JsonKey(name: 'sensor_make_id') this.sensorMakeId, @JsonKey(name: 'install_date') this.installDate, @JsonKey(name: 'placement') this.placement, @JsonKey(name: 'location') this.location, @JsonKey(name: 'remarks') this.remarks});
  factory _SensorRequest.fromJson(Map<String, dynamic> json) => _$SensorRequestFromJson(json);

@override@JsonKey(name: 'sensor_id') final  String? sensorId;
@override@JsonKey(name: 'sensor_make_id') final  int? sensorMakeId;
@override@JsonKey(name: 'install_date') final  String? installDate;
@override@JsonKey(name: 'placement') final  String? placement;
@override@JsonKey(name: 'location') final  String? location;
@override@JsonKey(name: 'remarks') final  String? remarks;

/// Create a copy of SensorRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorRequestCopyWith<_SensorRequest> get copyWith => __$SensorRequestCopyWithImpl<_SensorRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SensorRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorRequest&&(identical(other.sensorId, sensorId) || other.sensorId == sensorId)&&(identical(other.sensorMakeId, sensorMakeId) || other.sensorMakeId == sensorMakeId)&&(identical(other.installDate, installDate) || other.installDate == installDate)&&(identical(other.placement, placement) || other.placement == placement)&&(identical(other.location, location) || other.location == location)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sensorId,sensorMakeId,installDate,placement,location,remarks);

@override
String toString() {
  return 'SensorRequest(sensorId: $sensorId, sensorMakeId: $sensorMakeId, installDate: $installDate, placement: $placement, location: $location, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$SensorRequestCopyWith<$Res> implements $SensorRequestCopyWith<$Res> {
  factory _$SensorRequestCopyWith(_SensorRequest value, $Res Function(_SensorRequest) _then) = __$SensorRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'sensor_id') String? sensorId,@JsonKey(name: 'sensor_make_id') int? sensorMakeId,@JsonKey(name: 'install_date') String? installDate,@JsonKey(name: 'placement') String? placement,@JsonKey(name: 'location') String? location,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class __$SensorRequestCopyWithImpl<$Res>
    implements _$SensorRequestCopyWith<$Res> {
  __$SensorRequestCopyWithImpl(this._self, this._then);

  final _SensorRequest _self;
  final $Res Function(_SensorRequest) _then;

/// Create a copy of SensorRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sensorId = freezed,Object? sensorMakeId = freezed,Object? installDate = freezed,Object? placement = freezed,Object? location = freezed,Object? remarks = freezed,}) {
  return _then(_SensorRequest(
sensorId: freezed == sensorId ? _self.sensorId : sensorId // ignore: cast_nullable_to_non_nullable
as String?,sensorMakeId: freezed == sensorMakeId ? _self.sensorMakeId : sensorMakeId // ignore: cast_nullable_to_non_nullable
as int?,installDate: freezed == installDate ? _self.installDate : installDate // ignore: cast_nullable_to_non_nullable
as String?,placement: freezed == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
