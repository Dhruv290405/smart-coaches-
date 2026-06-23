// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_message_template_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertMessageTemplateRequest {

 String? get title; String? get body; String? get level;
/// Create a copy of AlertMessageTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertMessageTemplateRequestCopyWith<AlertMessageTemplateRequest> get copyWith => _$AlertMessageTemplateRequestCopyWithImpl<AlertMessageTemplateRequest>(this as AlertMessageTemplateRequest, _$identity);

  /// Serializes this AlertMessageTemplateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertMessageTemplateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,level);

@override
String toString() {
  return 'AlertMessageTemplateRequest(title: $title, body: $body, level: $level)';
}


}

/// @nodoc
abstract mixin class $AlertMessageTemplateRequestCopyWith<$Res>  {
  factory $AlertMessageTemplateRequestCopyWith(AlertMessageTemplateRequest value, $Res Function(AlertMessageTemplateRequest) _then) = _$AlertMessageTemplateRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? body, String? level
});




}
/// @nodoc
class _$AlertMessageTemplateRequestCopyWithImpl<$Res>
    implements $AlertMessageTemplateRequestCopyWith<$Res> {
  _$AlertMessageTemplateRequestCopyWithImpl(this._self, this._then);

  final AlertMessageTemplateRequest _self;
  final $Res Function(AlertMessageTemplateRequest) _then;

/// Create a copy of AlertMessageTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? body = freezed,Object? level = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertMessageTemplateRequest].
extension AlertMessageTemplateRequestPatterns on AlertMessageTemplateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertMessageTemplateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertMessageTemplateRequest value)  $default,){
final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertMessageTemplateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? body,  String? level)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest() when $default != null:
return $default(_that.title,_that.body,_that.level);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? body,  String? level)  $default,) {final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest():
return $default(_that.title,_that.body,_that.level);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? body,  String? level)?  $default,) {final _that = this;
switch (_that) {
case _AlertMessageTemplateRequest() when $default != null:
return $default(_that.title,_that.body,_that.level);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertMessageTemplateRequest implements AlertMessageTemplateRequest {
  const _AlertMessageTemplateRequest({this.title, this.body, this.level});
  factory _AlertMessageTemplateRequest.fromJson(Map<String, dynamic> json) => _$AlertMessageTemplateRequestFromJson(json);

@override final  String? title;
@override final  String? body;
@override final  String? level;

/// Create a copy of AlertMessageTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertMessageTemplateRequestCopyWith<_AlertMessageTemplateRequest> get copyWith => __$AlertMessageTemplateRequestCopyWithImpl<_AlertMessageTemplateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertMessageTemplateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertMessageTemplateRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,level);

@override
String toString() {
  return 'AlertMessageTemplateRequest(title: $title, body: $body, level: $level)';
}


}

/// @nodoc
abstract mixin class _$AlertMessageTemplateRequestCopyWith<$Res> implements $AlertMessageTemplateRequestCopyWith<$Res> {
  factory _$AlertMessageTemplateRequestCopyWith(_AlertMessageTemplateRequest value, $Res Function(_AlertMessageTemplateRequest) _then) = __$AlertMessageTemplateRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? body, String? level
});




}
/// @nodoc
class __$AlertMessageTemplateRequestCopyWithImpl<$Res>
    implements _$AlertMessageTemplateRequestCopyWith<$Res> {
  __$AlertMessageTemplateRequestCopyWithImpl(this._self, this._then);

  final _AlertMessageTemplateRequest _self;
  final $Res Function(_AlertMessageTemplateRequest) _then;

/// Create a copy of AlertMessageTemplateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? body = freezed,Object? level = freezed,}) {
  return _then(_AlertMessageTemplateRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
