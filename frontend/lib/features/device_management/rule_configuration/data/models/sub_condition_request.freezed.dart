// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_condition_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubConditionRequest {

 String? get operator;@JsonKey(name: 'threshold_value') num? get thresholdValue; String? get connector;@JsonKey(name: 'sort_order') int? get sortOrder;
/// Create a copy of SubConditionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubConditionRequestCopyWith<SubConditionRequest> get copyWith => _$SubConditionRequestCopyWithImpl<SubConditionRequest>(this as SubConditionRequest, _$identity);

  /// Serializes this SubConditionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubConditionRequest&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.thresholdValue, thresholdValue) || other.thresholdValue == thresholdValue)&&(identical(other.connector, connector) || other.connector == connector)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,operator,thresholdValue,connector,sortOrder);

@override
String toString() {
  return 'SubConditionRequest(operator: $operator, thresholdValue: $thresholdValue, connector: $connector, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $SubConditionRequestCopyWith<$Res>  {
  factory $SubConditionRequestCopyWith(SubConditionRequest value, $Res Function(SubConditionRequest) _then) = _$SubConditionRequestCopyWithImpl;
@useResult
$Res call({
 String? operator,@JsonKey(name: 'threshold_value') num? thresholdValue, String? connector,@JsonKey(name: 'sort_order') int? sortOrder
});




}
/// @nodoc
class _$SubConditionRequestCopyWithImpl<$Res>
    implements $SubConditionRequestCopyWith<$Res> {
  _$SubConditionRequestCopyWithImpl(this._self, this._then);

  final SubConditionRequest _self;
  final $Res Function(SubConditionRequest) _then;

/// Create a copy of SubConditionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? operator = freezed,Object? thresholdValue = freezed,Object? connector = freezed,Object? sortOrder = freezed,}) {
  return _then(_self.copyWith(
operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,thresholdValue: freezed == thresholdValue ? _self.thresholdValue : thresholdValue // ignore: cast_nullable_to_non_nullable
as num?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubConditionRequest].
extension SubConditionRequestPatterns on SubConditionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubConditionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubConditionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubConditionRequest value)  $default,){
final _that = this;
switch (_that) {
case _SubConditionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubConditionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SubConditionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? operator, @JsonKey(name: 'threshold_value')  num? thresholdValue,  String? connector, @JsonKey(name: 'sort_order')  int? sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubConditionRequest() when $default != null:
return $default(_that.operator,_that.thresholdValue,_that.connector,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? operator, @JsonKey(name: 'threshold_value')  num? thresholdValue,  String? connector, @JsonKey(name: 'sort_order')  int? sortOrder)  $default,) {final _that = this;
switch (_that) {
case _SubConditionRequest():
return $default(_that.operator,_that.thresholdValue,_that.connector,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? operator, @JsonKey(name: 'threshold_value')  num? thresholdValue,  String? connector, @JsonKey(name: 'sort_order')  int? sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _SubConditionRequest() when $default != null:
return $default(_that.operator,_that.thresholdValue,_that.connector,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubConditionRequest implements SubConditionRequest {
  const _SubConditionRequest({this.operator, @JsonKey(name: 'threshold_value') this.thresholdValue, this.connector, @JsonKey(name: 'sort_order') this.sortOrder});
  factory _SubConditionRequest.fromJson(Map<String, dynamic> json) => _$SubConditionRequestFromJson(json);

@override final  String? operator;
@override@JsonKey(name: 'threshold_value') final  num? thresholdValue;
@override final  String? connector;
@override@JsonKey(name: 'sort_order') final  int? sortOrder;

/// Create a copy of SubConditionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubConditionRequestCopyWith<_SubConditionRequest> get copyWith => __$SubConditionRequestCopyWithImpl<_SubConditionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubConditionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubConditionRequest&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.thresholdValue, thresholdValue) || other.thresholdValue == thresholdValue)&&(identical(other.connector, connector) || other.connector == connector)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,operator,thresholdValue,connector,sortOrder);

@override
String toString() {
  return 'SubConditionRequest(operator: $operator, thresholdValue: $thresholdValue, connector: $connector, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$SubConditionRequestCopyWith<$Res> implements $SubConditionRequestCopyWith<$Res> {
  factory _$SubConditionRequestCopyWith(_SubConditionRequest value, $Res Function(_SubConditionRequest) _then) = __$SubConditionRequestCopyWithImpl;
@override @useResult
$Res call({
 String? operator,@JsonKey(name: 'threshold_value') num? thresholdValue, String? connector,@JsonKey(name: 'sort_order') int? sortOrder
});




}
/// @nodoc
class __$SubConditionRequestCopyWithImpl<$Res>
    implements _$SubConditionRequestCopyWith<$Res> {
  __$SubConditionRequestCopyWithImpl(this._self, this._then);

  final _SubConditionRequest _self;
  final $Res Function(_SubConditionRequest) _then;

/// Create a copy of SubConditionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? operator = freezed,Object? thresholdValue = freezed,Object? connector = freezed,Object? sortOrder = freezed,}) {
  return _then(_SubConditionRequest(
operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,thresholdValue: freezed == thresholdValue ? _self.thresholdValue : thresholdValue // ignore: cast_nullable_to_non_nullable
as num?,connector: freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: freezed == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
