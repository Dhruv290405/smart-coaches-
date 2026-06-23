// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RuleConfigurationRequest {

@JsonKey(name: 'rule_name') String? get ruleName;@JsonKey(name: 'evaluation_frequency') String? get evaluationFrequency;@JsonKey(name: 'evaluation_unit') String? get evaluationUnit;@JsonKey(name: 'is_active') bool? get isActive;@JsonKey(name: 'device_ids') List<String>? get deviceIds;@JsonKey(name: 'sensor_type_ids') List<int>? get sensorTypeIds;@JsonKey(name: 'conditions') List<ConditionBlockRequest>? get conditions;
/// Create a copy of RuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleConfigurationRequestCopyWith<RuleConfigurationRequest> get copyWith => _$RuleConfigurationRequestCopyWithImpl<RuleConfigurationRequest>(this as RuleConfigurationRequest, _$identity);

  /// Serializes this RuleConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleConfigurationRequest&&(identical(other.ruleName, ruleName) || other.ruleName == ruleName)&&(identical(other.evaluationFrequency, evaluationFrequency) || other.evaluationFrequency == evaluationFrequency)&&(identical(other.evaluationUnit, evaluationUnit) || other.evaluationUnit == evaluationUnit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.deviceIds, deviceIds)&&const DeepCollectionEquality().equals(other.sensorTypeIds, sensorTypeIds)&&const DeepCollectionEquality().equals(other.conditions, conditions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ruleName,evaluationFrequency,evaluationUnit,isActive,const DeepCollectionEquality().hash(deviceIds),const DeepCollectionEquality().hash(sensorTypeIds),const DeepCollectionEquality().hash(conditions));

@override
String toString() {
  return 'RuleConfigurationRequest(ruleName: $ruleName, evaluationFrequency: $evaluationFrequency, evaluationUnit: $evaluationUnit, isActive: $isActive, deviceIds: $deviceIds, sensorTypeIds: $sensorTypeIds, conditions: $conditions)';
}


}

/// @nodoc
abstract mixin class $RuleConfigurationRequestCopyWith<$Res>  {
  factory $RuleConfigurationRequestCopyWith(RuleConfigurationRequest value, $Res Function(RuleConfigurationRequest) _then) = _$RuleConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'rule_name') String? ruleName,@JsonKey(name: 'evaluation_frequency') String? evaluationFrequency,@JsonKey(name: 'evaluation_unit') String? evaluationUnit,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'device_ids') List<String>? deviceIds,@JsonKey(name: 'sensor_type_ids') List<int>? sensorTypeIds,@JsonKey(name: 'conditions') List<ConditionBlockRequest>? conditions
});




}
/// @nodoc
class _$RuleConfigurationRequestCopyWithImpl<$Res>
    implements $RuleConfigurationRequestCopyWith<$Res> {
  _$RuleConfigurationRequestCopyWithImpl(this._self, this._then);

  final RuleConfigurationRequest _self;
  final $Res Function(RuleConfigurationRequest) _then;

/// Create a copy of RuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ruleName = freezed,Object? evaluationFrequency = freezed,Object? evaluationUnit = freezed,Object? isActive = freezed,Object? deviceIds = freezed,Object? sensorTypeIds = freezed,Object? conditions = freezed,}) {
  return _then(_self.copyWith(
ruleName: freezed == ruleName ? _self.ruleName : ruleName // ignore: cast_nullable_to_non_nullable
as String?,evaluationFrequency: freezed == evaluationFrequency ? _self.evaluationFrequency : evaluationFrequency // ignore: cast_nullable_to_non_nullable
as String?,evaluationUnit: freezed == evaluationUnit ? _self.evaluationUnit : evaluationUnit // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,deviceIds: freezed == deviceIds ? _self.deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,sensorTypeIds: freezed == sensorTypeIds ? _self.sensorTypeIds : sensorTypeIds // ignore: cast_nullable_to_non_nullable
as List<int>?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ConditionBlockRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleConfigurationRequest].
extension RuleConfigurationRequestPatterns on RuleConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _RuleConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RuleConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'rule_name')  String? ruleName, @JsonKey(name: 'evaluation_frequency')  String? evaluationFrequency, @JsonKey(name: 'evaluation_unit')  String? evaluationUnit, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'device_ids')  List<String>? deviceIds, @JsonKey(name: 'sensor_type_ids')  List<int>? sensorTypeIds, @JsonKey(name: 'conditions')  List<ConditionBlockRequest>? conditions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleConfigurationRequest() when $default != null:
return $default(_that.ruleName,_that.evaluationFrequency,_that.evaluationUnit,_that.isActive,_that.deviceIds,_that.sensorTypeIds,_that.conditions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'rule_name')  String? ruleName, @JsonKey(name: 'evaluation_frequency')  String? evaluationFrequency, @JsonKey(name: 'evaluation_unit')  String? evaluationUnit, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'device_ids')  List<String>? deviceIds, @JsonKey(name: 'sensor_type_ids')  List<int>? sensorTypeIds, @JsonKey(name: 'conditions')  List<ConditionBlockRequest>? conditions)  $default,) {final _that = this;
switch (_that) {
case _RuleConfigurationRequest():
return $default(_that.ruleName,_that.evaluationFrequency,_that.evaluationUnit,_that.isActive,_that.deviceIds,_that.sensorTypeIds,_that.conditions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'rule_name')  String? ruleName, @JsonKey(name: 'evaluation_frequency')  String? evaluationFrequency, @JsonKey(name: 'evaluation_unit')  String? evaluationUnit, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'device_ids')  List<String>? deviceIds, @JsonKey(name: 'sensor_type_ids')  List<int>? sensorTypeIds, @JsonKey(name: 'conditions')  List<ConditionBlockRequest>? conditions)?  $default,) {final _that = this;
switch (_that) {
case _RuleConfigurationRequest() when $default != null:
return $default(_that.ruleName,_that.evaluationFrequency,_that.evaluationUnit,_that.isActive,_that.deviceIds,_that.sensorTypeIds,_that.conditions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleConfigurationRequest implements RuleConfigurationRequest {
  const _RuleConfigurationRequest({@JsonKey(name: 'rule_name') this.ruleName, @JsonKey(name: 'evaluation_frequency') this.evaluationFrequency, @JsonKey(name: 'evaluation_unit') this.evaluationUnit, @JsonKey(name: 'is_active') this.isActive, @JsonKey(name: 'device_ids') final  List<String>? deviceIds, @JsonKey(name: 'sensor_type_ids') final  List<int>? sensorTypeIds, @JsonKey(name: 'conditions') final  List<ConditionBlockRequest>? conditions}): _deviceIds = deviceIds,_sensorTypeIds = sensorTypeIds,_conditions = conditions;
  factory _RuleConfigurationRequest.fromJson(Map<String, dynamic> json) => _$RuleConfigurationRequestFromJson(json);

@override@JsonKey(name: 'rule_name') final  String? ruleName;
@override@JsonKey(name: 'evaluation_frequency') final  String? evaluationFrequency;
@override@JsonKey(name: 'evaluation_unit') final  String? evaluationUnit;
@override@JsonKey(name: 'is_active') final  bool? isActive;
 final  List<String>? _deviceIds;
@override@JsonKey(name: 'device_ids') List<String>? get deviceIds {
  final value = _deviceIds;
  if (value == null) return null;
  if (_deviceIds is EqualUnmodifiableListView) return _deviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int>? _sensorTypeIds;
@override@JsonKey(name: 'sensor_type_ids') List<int>? get sensorTypeIds {
  final value = _sensorTypeIds;
  if (value == null) return null;
  if (_sensorTypeIds is EqualUnmodifiableListView) return _sensorTypeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ConditionBlockRequest>? _conditions;
@override@JsonKey(name: 'conditions') List<ConditionBlockRequest>? get conditions {
  final value = _conditions;
  if (value == null) return null;
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleConfigurationRequestCopyWith<_RuleConfigurationRequest> get copyWith => __$RuleConfigurationRequestCopyWithImpl<_RuleConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleConfigurationRequest&&(identical(other.ruleName, ruleName) || other.ruleName == ruleName)&&(identical(other.evaluationFrequency, evaluationFrequency) || other.evaluationFrequency == evaluationFrequency)&&(identical(other.evaluationUnit, evaluationUnit) || other.evaluationUnit == evaluationUnit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._deviceIds, _deviceIds)&&const DeepCollectionEquality().equals(other._sensorTypeIds, _sensorTypeIds)&&const DeepCollectionEquality().equals(other._conditions, _conditions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ruleName,evaluationFrequency,evaluationUnit,isActive,const DeepCollectionEquality().hash(_deviceIds),const DeepCollectionEquality().hash(_sensorTypeIds),const DeepCollectionEquality().hash(_conditions));

@override
String toString() {
  return 'RuleConfigurationRequest(ruleName: $ruleName, evaluationFrequency: $evaluationFrequency, evaluationUnit: $evaluationUnit, isActive: $isActive, deviceIds: $deviceIds, sensorTypeIds: $sensorTypeIds, conditions: $conditions)';
}


}

/// @nodoc
abstract mixin class _$RuleConfigurationRequestCopyWith<$Res> implements $RuleConfigurationRequestCopyWith<$Res> {
  factory _$RuleConfigurationRequestCopyWith(_RuleConfigurationRequest value, $Res Function(_RuleConfigurationRequest) _then) = __$RuleConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'rule_name') String? ruleName,@JsonKey(name: 'evaluation_frequency') String? evaluationFrequency,@JsonKey(name: 'evaluation_unit') String? evaluationUnit,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'device_ids') List<String>? deviceIds,@JsonKey(name: 'sensor_type_ids') List<int>? sensorTypeIds,@JsonKey(name: 'conditions') List<ConditionBlockRequest>? conditions
});




}
/// @nodoc
class __$RuleConfigurationRequestCopyWithImpl<$Res>
    implements _$RuleConfigurationRequestCopyWith<$Res> {
  __$RuleConfigurationRequestCopyWithImpl(this._self, this._then);

  final _RuleConfigurationRequest _self;
  final $Res Function(_RuleConfigurationRequest) _then;

/// Create a copy of RuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ruleName = freezed,Object? evaluationFrequency = freezed,Object? evaluationUnit = freezed,Object? isActive = freezed,Object? deviceIds = freezed,Object? sensorTypeIds = freezed,Object? conditions = freezed,}) {
  return _then(_RuleConfigurationRequest(
ruleName: freezed == ruleName ? _self.ruleName : ruleName // ignore: cast_nullable_to_non_nullable
as String?,evaluationFrequency: freezed == evaluationFrequency ? _self.evaluationFrequency : evaluationFrequency // ignore: cast_nullable_to_non_nullable
as String?,evaluationUnit: freezed == evaluationUnit ? _self.evaluationUnit : evaluationUnit // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,deviceIds: freezed == deviceIds ? _self._deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,sensorTypeIds: freezed == sensorTypeIds ? _self._sensorTypeIds : sensorTypeIds // ignore: cast_nullable_to_non_nullable
as List<int>?,conditions: freezed == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ConditionBlockRequest>?,
  ));
}


}

// dart format on
