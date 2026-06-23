// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'condition_block_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConditionBlockRequest {

@JsonKey(name: 'value_type_id') int? get valueTypeId;@JsonKey(name: 'value_format') String? get valueFormat;@JsonKey(name: 'si_unit_id') int? get siUnitId;@JsonKey(name: 'alert_type_id') int? get alertTypeId;@JsonKey(name: 'alert_message_template') AlertMessageTemplateRequest? get alertMessageTemplate;@JsonKey(name: 'connector') String? get connector;@JsonKey(name: 'sub_conditions') List<SubConditionRequest>? get subConditions;
/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionBlockRequestCopyWith<ConditionBlockRequest> get copyWith => _$ConditionBlockRequestCopyWithImpl<ConditionBlockRequest>(this as ConditionBlockRequest, _$identity);

  /// Serializes this ConditionBlockRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionBlockRequest&&(identical(other.valueTypeId, valueTypeId) || other.valueTypeId == valueTypeId)&&(identical(other.valueFormat, valueFormat) || other.valueFormat == valueFormat)&&(identical(other.siUnitId, siUnitId) || other.siUnitId == siUnitId)&&(identical(other.alertTypeId, alertTypeId) || other.alertTypeId == alertTypeId)&&(identical(other.alertMessageTemplate, alertMessageTemplate) || other.alertMessageTemplate == alertMessageTemplate)&&(identical(other.connector, connector) || other.connector == connector)&&const DeepCollectionEquality().equals(other.subConditions, subConditions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valueTypeId,valueFormat,siUnitId,alertTypeId,alertMessageTemplate,connector,const DeepCollectionEquality().hash(subConditions));

@override
String toString() {
  return 'ConditionBlockRequest(valueTypeId: $valueTypeId, valueFormat: $valueFormat, siUnitId: $siUnitId, alertTypeId: $alertTypeId, alertMessageTemplate: $alertMessageTemplate, connector: $connector, subConditions: $subConditions)';
}


}

/// @nodoc
abstract mixin class $ConditionBlockRequestCopyWith<$Res>  {
  factory $ConditionBlockRequestCopyWith(ConditionBlockRequest value, $Res Function(ConditionBlockRequest) _then) = _$ConditionBlockRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'value_type_id') int? valueTypeId,@JsonKey(name: 'value_format') String? valueFormat,@JsonKey(name: 'si_unit_id') int? siUnitId,@JsonKey(name: 'alert_type_id') int? alertTypeId,@JsonKey(name: 'alert_message_template') AlertMessageTemplateRequest? alertMessageTemplate,@JsonKey(name: 'connector') String? connector,@JsonKey(name: 'sub_conditions') List<SubConditionRequest>? subConditions
});


$AlertMessageTemplateRequestCopyWith<$Res>? get alertMessageTemplate;

}
/// @nodoc
class _$ConditionBlockRequestCopyWithImpl<$Res>
    implements $ConditionBlockRequestCopyWith<$Res> {
  _$ConditionBlockRequestCopyWithImpl(this._self, this._then);

  final ConditionBlockRequest _self;
  final $Res Function(ConditionBlockRequest) _then;

/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valueTypeId = freezed,Object? valueFormat = freezed,Object? siUnitId = freezed,Object? alertTypeId = freezed,Object? alertMessageTemplate = freezed,Object? connector = freezed,Object? subConditions = freezed,}) {
  return _then(_self.copyWith(
valueTypeId: freezed == valueTypeId ? _self.valueTypeId : valueTypeId // ignore: cast_nullable_to_non_nullable
as int?,valueFormat: freezed == valueFormat ? _self.valueFormat : valueFormat // ignore: cast_nullable_to_non_nullable
as String?,siUnitId: freezed == siUnitId ? _self.siUnitId : siUnitId // ignore: cast_nullable_to_non_nullable
as int?,alertTypeId: freezed == alertTypeId ? _self.alertTypeId : alertTypeId // ignore: cast_nullable_to_non_nullable
as int?,alertMessageTemplate: freezed == alertMessageTemplate ? _self.alertMessageTemplate : alertMessageTemplate // ignore: cast_nullable_to_non_nullable
as AlertMessageTemplateRequest?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,subConditions: freezed == subConditions ? _self.subConditions : subConditions // ignore: cast_nullable_to_non_nullable
as List<SubConditionRequest>?,
  ));
}
/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertMessageTemplateRequestCopyWith<$Res>? get alertMessageTemplate {
    if (_self.alertMessageTemplate == null) {
    return null;
  }

  return $AlertMessageTemplateRequestCopyWith<$Res>(_self.alertMessageTemplate!, (value) {
    return _then(_self.copyWith(alertMessageTemplate: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConditionBlockRequest].
extension ConditionBlockRequestPatterns on ConditionBlockRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConditionBlockRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConditionBlockRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConditionBlockRequest value)  $default,){
final _that = this;
switch (_that) {
case _ConditionBlockRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConditionBlockRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ConditionBlockRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'value_type_id')  int? valueTypeId, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'si_unit_id')  int? siUnitId, @JsonKey(name: 'alert_type_id')  int? alertTypeId, @JsonKey(name: 'alert_message_template')  AlertMessageTemplateRequest? alertMessageTemplate, @JsonKey(name: 'connector')  String? connector, @JsonKey(name: 'sub_conditions')  List<SubConditionRequest>? subConditions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConditionBlockRequest() when $default != null:
return $default(_that.valueTypeId,_that.valueFormat,_that.siUnitId,_that.alertTypeId,_that.alertMessageTemplate,_that.connector,_that.subConditions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'value_type_id')  int? valueTypeId, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'si_unit_id')  int? siUnitId, @JsonKey(name: 'alert_type_id')  int? alertTypeId, @JsonKey(name: 'alert_message_template')  AlertMessageTemplateRequest? alertMessageTemplate, @JsonKey(name: 'connector')  String? connector, @JsonKey(name: 'sub_conditions')  List<SubConditionRequest>? subConditions)  $default,) {final _that = this;
switch (_that) {
case _ConditionBlockRequest():
return $default(_that.valueTypeId,_that.valueFormat,_that.siUnitId,_that.alertTypeId,_that.alertMessageTemplate,_that.connector,_that.subConditions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'value_type_id')  int? valueTypeId, @JsonKey(name: 'value_format')  String? valueFormat, @JsonKey(name: 'si_unit_id')  int? siUnitId, @JsonKey(name: 'alert_type_id')  int? alertTypeId, @JsonKey(name: 'alert_message_template')  AlertMessageTemplateRequest? alertMessageTemplate, @JsonKey(name: 'connector')  String? connector, @JsonKey(name: 'sub_conditions')  List<SubConditionRequest>? subConditions)?  $default,) {final _that = this;
switch (_that) {
case _ConditionBlockRequest() when $default != null:
return $default(_that.valueTypeId,_that.valueFormat,_that.siUnitId,_that.alertTypeId,_that.alertMessageTemplate,_that.connector,_that.subConditions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConditionBlockRequest implements ConditionBlockRequest {
  const _ConditionBlockRequest({@JsonKey(name: 'value_type_id') this.valueTypeId, @JsonKey(name: 'value_format') this.valueFormat, @JsonKey(name: 'si_unit_id') this.siUnitId, @JsonKey(name: 'alert_type_id') this.alertTypeId, @JsonKey(name: 'alert_message_template') this.alertMessageTemplate, @JsonKey(name: 'connector') this.connector, @JsonKey(name: 'sub_conditions') final  List<SubConditionRequest>? subConditions}): _subConditions = subConditions;
  factory _ConditionBlockRequest.fromJson(Map<String, dynamic> json) => _$ConditionBlockRequestFromJson(json);

@override@JsonKey(name: 'value_type_id') final  int? valueTypeId;
@override@JsonKey(name: 'value_format') final  String? valueFormat;
@override@JsonKey(name: 'si_unit_id') final  int? siUnitId;
@override@JsonKey(name: 'alert_type_id') final  int? alertTypeId;
@override@JsonKey(name: 'alert_message_template') final  AlertMessageTemplateRequest? alertMessageTemplate;
@override@JsonKey(name: 'connector') final  String? connector;
 final  List<SubConditionRequest>? _subConditions;
@override@JsonKey(name: 'sub_conditions') List<SubConditionRequest>? get subConditions {
  final value = _subConditions;
  if (value == null) return null;
  if (_subConditions is EqualUnmodifiableListView) return _subConditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConditionBlockRequestCopyWith<_ConditionBlockRequest> get copyWith => __$ConditionBlockRequestCopyWithImpl<_ConditionBlockRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConditionBlockRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConditionBlockRequest&&(identical(other.valueTypeId, valueTypeId) || other.valueTypeId == valueTypeId)&&(identical(other.valueFormat, valueFormat) || other.valueFormat == valueFormat)&&(identical(other.siUnitId, siUnitId) || other.siUnitId == siUnitId)&&(identical(other.alertTypeId, alertTypeId) || other.alertTypeId == alertTypeId)&&(identical(other.alertMessageTemplate, alertMessageTemplate) || other.alertMessageTemplate == alertMessageTemplate)&&(identical(other.connector, connector) || other.connector == connector)&&const DeepCollectionEquality().equals(other._subConditions, _subConditions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,valueTypeId,valueFormat,siUnitId,alertTypeId,alertMessageTemplate,connector,const DeepCollectionEquality().hash(_subConditions));

@override
String toString() {
  return 'ConditionBlockRequest(valueTypeId: $valueTypeId, valueFormat: $valueFormat, siUnitId: $siUnitId, alertTypeId: $alertTypeId, alertMessageTemplate: $alertMessageTemplate, connector: $connector, subConditions: $subConditions)';
}


}

/// @nodoc
abstract mixin class _$ConditionBlockRequestCopyWith<$Res> implements $ConditionBlockRequestCopyWith<$Res> {
  factory _$ConditionBlockRequestCopyWith(_ConditionBlockRequest value, $Res Function(_ConditionBlockRequest) _then) = __$ConditionBlockRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'value_type_id') int? valueTypeId,@JsonKey(name: 'value_format') String? valueFormat,@JsonKey(name: 'si_unit_id') int? siUnitId,@JsonKey(name: 'alert_type_id') int? alertTypeId,@JsonKey(name: 'alert_message_template') AlertMessageTemplateRequest? alertMessageTemplate,@JsonKey(name: 'connector') String? connector,@JsonKey(name: 'sub_conditions') List<SubConditionRequest>? subConditions
});


@override $AlertMessageTemplateRequestCopyWith<$Res>? get alertMessageTemplate;

}
/// @nodoc
class __$ConditionBlockRequestCopyWithImpl<$Res>
    implements _$ConditionBlockRequestCopyWith<$Res> {
  __$ConditionBlockRequestCopyWithImpl(this._self, this._then);

  final _ConditionBlockRequest _self;
  final $Res Function(_ConditionBlockRequest) _then;

/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valueTypeId = freezed,Object? valueFormat = freezed,Object? siUnitId = freezed,Object? alertTypeId = freezed,Object? alertMessageTemplate = freezed,Object? connector = freezed,Object? subConditions = freezed,}) {
  return _then(_ConditionBlockRequest(
valueTypeId: freezed == valueTypeId ? _self.valueTypeId : valueTypeId // ignore: cast_nullable_to_non_nullable
as int?,valueFormat: freezed == valueFormat ? _self.valueFormat : valueFormat // ignore: cast_nullable_to_non_nullable
as String?,siUnitId: freezed == siUnitId ? _self.siUnitId : siUnitId // ignore: cast_nullable_to_non_nullable
as int?,alertTypeId: freezed == alertTypeId ? _self.alertTypeId : alertTypeId // ignore: cast_nullable_to_non_nullable
as int?,alertMessageTemplate: freezed == alertMessageTemplate ? _self.alertMessageTemplate : alertMessageTemplate // ignore: cast_nullable_to_non_nullable
as AlertMessageTemplateRequest?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,subConditions: freezed == subConditions ? _self._subConditions : subConditions // ignore: cast_nullable_to_non_nullable
as List<SubConditionRequest>?,
  ));
}

/// Create a copy of ConditionBlockRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlertMessageTemplateRequestCopyWith<$Res>? get alertMessageTemplate {
    if (_self.alertMessageTemplate == null) {
    return null;
  }

  return $AlertMessageTemplateRequestCopyWith<$Res>(_self.alertMessageTemplate!, (value) {
    return _then(_self.copyWith(alertMessageTemplate: value));
  });
}
}

// dart format on
