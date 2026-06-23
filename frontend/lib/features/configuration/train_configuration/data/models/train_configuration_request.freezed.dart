// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'train_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainConfigurationRequest {

@JsonKey(name: 'train_number') int? get trainNumber;@JsonKey(name: 'train_name') String? get trainName;@JsonKey(name: 'origination_region_id') int? get originationRegionId;@JsonKey(name: 'region_id') int? get regionId;@JsonKey(name: 'departure_station_id') int? get departureStationId;@JsonKey(name: 'destination_station_id') int? get destinationStationId;@JsonKey(name: 'no_of_coaches') int? get numberOfCoaches;@JsonKey(name: 'line') String? get line;@JsonKey(name: 'train_operator') String? get trainOperator;@JsonKey(name: 'engine_number') String? get engineNumber;@JsonKey(name: 'coaches') List<CoachConfigurationRequest>? get coaches;
/// Create a copy of TrainConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainConfigurationRequestCopyWith<TrainConfigurationRequest> get copyWith => _$TrainConfigurationRequestCopyWithImpl<TrainConfigurationRequest>(this as TrainConfigurationRequest, _$identity);

  /// Serializes this TrainConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainConfigurationRequest&&(identical(other.trainNumber, trainNumber) || other.trainNumber == trainNumber)&&(identical(other.trainName, trainName) || other.trainName == trainName)&&(identical(other.originationRegionId, originationRegionId) || other.originationRegionId == originationRegionId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.departureStationId, departureStationId) || other.departureStationId == departureStationId)&&(identical(other.destinationStationId, destinationStationId) || other.destinationStationId == destinationStationId)&&(identical(other.numberOfCoaches, numberOfCoaches) || other.numberOfCoaches == numberOfCoaches)&&(identical(other.line, line) || other.line == line)&&(identical(other.trainOperator, trainOperator) || other.trainOperator == trainOperator)&&(identical(other.engineNumber, engineNumber) || other.engineNumber == engineNumber)&&const DeepCollectionEquality().equals(other.coaches, coaches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trainNumber,trainName,originationRegionId,regionId,departureStationId,destinationStationId,numberOfCoaches,line,trainOperator,engineNumber,const DeepCollectionEquality().hash(coaches));

@override
String toString() {
  return 'TrainConfigurationRequest(trainNumber: $trainNumber, trainName: $trainName, originationRegionId: $originationRegionId, regionId: $regionId, departureStationId: $departureStationId, destinationStationId: $destinationStationId, numberOfCoaches: $numberOfCoaches, line: $line, trainOperator: $trainOperator, engineNumber: $engineNumber, coaches: $coaches)';
}


}

/// @nodoc
abstract mixin class $TrainConfigurationRequestCopyWith<$Res>  {
  factory $TrainConfigurationRequestCopyWith(TrainConfigurationRequest value, $Res Function(TrainConfigurationRequest) _then) = _$TrainConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'train_number') int? trainNumber,@JsonKey(name: 'train_name') String? trainName,@JsonKey(name: 'origination_region_id') int? originationRegionId,@JsonKey(name: 'region_id') int? regionId,@JsonKey(name: 'departure_station_id') int? departureStationId,@JsonKey(name: 'destination_station_id') int? destinationStationId,@JsonKey(name: 'no_of_coaches') int? numberOfCoaches,@JsonKey(name: 'line') String? line,@JsonKey(name: 'train_operator') String? trainOperator,@JsonKey(name: 'engine_number') String? engineNumber,@JsonKey(name: 'coaches') List<CoachConfigurationRequest>? coaches
});




}
/// @nodoc
class _$TrainConfigurationRequestCopyWithImpl<$Res>
    implements $TrainConfigurationRequestCopyWith<$Res> {
  _$TrainConfigurationRequestCopyWithImpl(this._self, this._then);

  final TrainConfigurationRequest _self;
  final $Res Function(TrainConfigurationRequest) _then;

/// Create a copy of TrainConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trainNumber = freezed,Object? trainName = freezed,Object? originationRegionId = freezed,Object? regionId = freezed,Object? departureStationId = freezed,Object? destinationStationId = freezed,Object? numberOfCoaches = freezed,Object? line = freezed,Object? trainOperator = freezed,Object? engineNumber = freezed,Object? coaches = freezed,}) {
  return _then(_self.copyWith(
trainNumber: freezed == trainNumber ? _self.trainNumber : trainNumber // ignore: cast_nullable_to_non_nullable
as int?,trainName: freezed == trainName ? _self.trainName : trainName // ignore: cast_nullable_to_non_nullable
as String?,originationRegionId: freezed == originationRegionId ? _self.originationRegionId : originationRegionId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,departureStationId: freezed == departureStationId ? _self.departureStationId : departureStationId // ignore: cast_nullable_to_non_nullable
as int?,destinationStationId: freezed == destinationStationId ? _self.destinationStationId : destinationStationId // ignore: cast_nullable_to_non_nullable
as int?,numberOfCoaches: freezed == numberOfCoaches ? _self.numberOfCoaches : numberOfCoaches // ignore: cast_nullable_to_non_nullable
as int?,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String?,trainOperator: freezed == trainOperator ? _self.trainOperator : trainOperator // ignore: cast_nullable_to_non_nullable
as String?,engineNumber: freezed == engineNumber ? _self.engineNumber : engineNumber // ignore: cast_nullable_to_non_nullable
as String?,coaches: freezed == coaches ? _self.coaches : coaches // ignore: cast_nullable_to_non_nullable
as List<CoachConfigurationRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainConfigurationRequest].
extension TrainConfigurationRequestPatterns on TrainConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _TrainConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TrainConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'train_number')  int? trainNumber, @JsonKey(name: 'train_name')  String? trainName, @JsonKey(name: 'origination_region_id')  int? originationRegionId, @JsonKey(name: 'region_id')  int? regionId, @JsonKey(name: 'departure_station_id')  int? departureStationId, @JsonKey(name: 'destination_station_id')  int? destinationStationId, @JsonKey(name: 'no_of_coaches')  int? numberOfCoaches, @JsonKey(name: 'line')  String? line, @JsonKey(name: 'train_operator')  String? trainOperator, @JsonKey(name: 'engine_number')  String? engineNumber, @JsonKey(name: 'coaches')  List<CoachConfigurationRequest>? coaches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainConfigurationRequest() when $default != null:
return $default(_that.trainNumber,_that.trainName,_that.originationRegionId,_that.regionId,_that.departureStationId,_that.destinationStationId,_that.numberOfCoaches,_that.line,_that.trainOperator,_that.engineNumber,_that.coaches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'train_number')  int? trainNumber, @JsonKey(name: 'train_name')  String? trainName, @JsonKey(name: 'origination_region_id')  int? originationRegionId, @JsonKey(name: 'region_id')  int? regionId, @JsonKey(name: 'departure_station_id')  int? departureStationId, @JsonKey(name: 'destination_station_id')  int? destinationStationId, @JsonKey(name: 'no_of_coaches')  int? numberOfCoaches, @JsonKey(name: 'line')  String? line, @JsonKey(name: 'train_operator')  String? trainOperator, @JsonKey(name: 'engine_number')  String? engineNumber, @JsonKey(name: 'coaches')  List<CoachConfigurationRequest>? coaches)  $default,) {final _that = this;
switch (_that) {
case _TrainConfigurationRequest():
return $default(_that.trainNumber,_that.trainName,_that.originationRegionId,_that.regionId,_that.departureStationId,_that.destinationStationId,_that.numberOfCoaches,_that.line,_that.trainOperator,_that.engineNumber,_that.coaches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'train_number')  int? trainNumber, @JsonKey(name: 'train_name')  String? trainName, @JsonKey(name: 'origination_region_id')  int? originationRegionId, @JsonKey(name: 'region_id')  int? regionId, @JsonKey(name: 'departure_station_id')  int? departureStationId, @JsonKey(name: 'destination_station_id')  int? destinationStationId, @JsonKey(name: 'no_of_coaches')  int? numberOfCoaches, @JsonKey(name: 'line')  String? line, @JsonKey(name: 'train_operator')  String? trainOperator, @JsonKey(name: 'engine_number')  String? engineNumber, @JsonKey(name: 'coaches')  List<CoachConfigurationRequest>? coaches)?  $default,) {final _that = this;
switch (_that) {
case _TrainConfigurationRequest() when $default != null:
return $default(_that.trainNumber,_that.trainName,_that.originationRegionId,_that.regionId,_that.departureStationId,_that.destinationStationId,_that.numberOfCoaches,_that.line,_that.trainOperator,_that.engineNumber,_that.coaches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainConfigurationRequest implements TrainConfigurationRequest {
  const _TrainConfigurationRequest({@JsonKey(name: 'train_number') this.trainNumber, @JsonKey(name: 'train_name') this.trainName, @JsonKey(name: 'origination_region_id') this.originationRegionId, @JsonKey(name: 'region_id') this.regionId, @JsonKey(name: 'departure_station_id') this.departureStationId, @JsonKey(name: 'destination_station_id') this.destinationStationId, @JsonKey(name: 'no_of_coaches') this.numberOfCoaches, @JsonKey(name: 'line') this.line, @JsonKey(name: 'train_operator') this.trainOperator, @JsonKey(name: 'engine_number') this.engineNumber, @JsonKey(name: 'coaches') final  List<CoachConfigurationRequest>? coaches}): _coaches = coaches;
  factory _TrainConfigurationRequest.fromJson(Map<String, dynamic> json) => _$TrainConfigurationRequestFromJson(json);

@override@JsonKey(name: 'train_number') final  int? trainNumber;
@override@JsonKey(name: 'train_name') final  String? trainName;
@override@JsonKey(name: 'origination_region_id') final  int? originationRegionId;
@override@JsonKey(name: 'region_id') final  int? regionId;
@override@JsonKey(name: 'departure_station_id') final  int? departureStationId;
@override@JsonKey(name: 'destination_station_id') final  int? destinationStationId;
@override@JsonKey(name: 'no_of_coaches') final  int? numberOfCoaches;
@override@JsonKey(name: 'line') final  String? line;
@override@JsonKey(name: 'train_operator') final  String? trainOperator;
@override@JsonKey(name: 'engine_number') final  String? engineNumber;
 final  List<CoachConfigurationRequest>? _coaches;
@override@JsonKey(name: 'coaches') List<CoachConfigurationRequest>? get coaches {
  final value = _coaches;
  if (value == null) return null;
  if (_coaches is EqualUnmodifiableListView) return _coaches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of TrainConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainConfigurationRequestCopyWith<_TrainConfigurationRequest> get copyWith => __$TrainConfigurationRequestCopyWithImpl<_TrainConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainConfigurationRequest&&(identical(other.trainNumber, trainNumber) || other.trainNumber == trainNumber)&&(identical(other.trainName, trainName) || other.trainName == trainName)&&(identical(other.originationRegionId, originationRegionId) || other.originationRegionId == originationRegionId)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.departureStationId, departureStationId) || other.departureStationId == departureStationId)&&(identical(other.destinationStationId, destinationStationId) || other.destinationStationId == destinationStationId)&&(identical(other.numberOfCoaches, numberOfCoaches) || other.numberOfCoaches == numberOfCoaches)&&(identical(other.line, line) || other.line == line)&&(identical(other.trainOperator, trainOperator) || other.trainOperator == trainOperator)&&(identical(other.engineNumber, engineNumber) || other.engineNumber == engineNumber)&&const DeepCollectionEquality().equals(other._coaches, _coaches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trainNumber,trainName,originationRegionId,regionId,departureStationId,destinationStationId,numberOfCoaches,line,trainOperator,engineNumber,const DeepCollectionEquality().hash(_coaches));

@override
String toString() {
  return 'TrainConfigurationRequest(trainNumber: $trainNumber, trainName: $trainName, originationRegionId: $originationRegionId, regionId: $regionId, departureStationId: $departureStationId, destinationStationId: $destinationStationId, numberOfCoaches: $numberOfCoaches, line: $line, trainOperator: $trainOperator, engineNumber: $engineNumber, coaches: $coaches)';
}


}

/// @nodoc
abstract mixin class _$TrainConfigurationRequestCopyWith<$Res> implements $TrainConfigurationRequestCopyWith<$Res> {
  factory _$TrainConfigurationRequestCopyWith(_TrainConfigurationRequest value, $Res Function(_TrainConfigurationRequest) _then) = __$TrainConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'train_number') int? trainNumber,@JsonKey(name: 'train_name') String? trainName,@JsonKey(name: 'origination_region_id') int? originationRegionId,@JsonKey(name: 'region_id') int? regionId,@JsonKey(name: 'departure_station_id') int? departureStationId,@JsonKey(name: 'destination_station_id') int? destinationStationId,@JsonKey(name: 'no_of_coaches') int? numberOfCoaches,@JsonKey(name: 'line') String? line,@JsonKey(name: 'train_operator') String? trainOperator,@JsonKey(name: 'engine_number') String? engineNumber,@JsonKey(name: 'coaches') List<CoachConfigurationRequest>? coaches
});




}
/// @nodoc
class __$TrainConfigurationRequestCopyWithImpl<$Res>
    implements _$TrainConfigurationRequestCopyWith<$Res> {
  __$TrainConfigurationRequestCopyWithImpl(this._self, this._then);

  final _TrainConfigurationRequest _self;
  final $Res Function(_TrainConfigurationRequest) _then;

/// Create a copy of TrainConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trainNumber = freezed,Object? trainName = freezed,Object? originationRegionId = freezed,Object? regionId = freezed,Object? departureStationId = freezed,Object? destinationStationId = freezed,Object? numberOfCoaches = freezed,Object? line = freezed,Object? trainOperator = freezed,Object? engineNumber = freezed,Object? coaches = freezed,}) {
  return _then(_TrainConfigurationRequest(
trainNumber: freezed == trainNumber ? _self.trainNumber : trainNumber // ignore: cast_nullable_to_non_nullable
as int?,trainName: freezed == trainName ? _self.trainName : trainName // ignore: cast_nullable_to_non_nullable
as String?,originationRegionId: freezed == originationRegionId ? _self.originationRegionId : originationRegionId // ignore: cast_nullable_to_non_nullable
as int?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,departureStationId: freezed == departureStationId ? _self.departureStationId : departureStationId // ignore: cast_nullable_to_non_nullable
as int?,destinationStationId: freezed == destinationStationId ? _self.destinationStationId : destinationStationId // ignore: cast_nullable_to_non_nullable
as int?,numberOfCoaches: freezed == numberOfCoaches ? _self.numberOfCoaches : numberOfCoaches // ignore: cast_nullable_to_non_nullable
as int?,line: freezed == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String?,trainOperator: freezed == trainOperator ? _self.trainOperator : trainOperator // ignore: cast_nullable_to_non_nullable
as String?,engineNumber: freezed == engineNumber ? _self.engineNumber : engineNumber // ignore: cast_nullable_to_non_nullable
as String?,coaches: freezed == coaches ? _self._coaches : coaches // ignore: cast_nullable_to_non_nullable
as List<CoachConfigurationRequest>?,
  ));
}


}

// dart format on
