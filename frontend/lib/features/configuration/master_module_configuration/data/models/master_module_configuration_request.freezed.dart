// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_module_configuration_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MasterModuleConfigurationRequest {

@JsonKey(name: 'coach_id') int? get coachId;@JsonKey(name: 'module_unique_id') String? get moduleUniqueId;@JsonKey(name: 'make_model') String? get makeModel;@JsonKey(name: 'firmware_version') String? get firmwareVersion;@JsonKey(name: 'seriel_number') String? get serielNumber;@JsonKey(name: 'installation_date') String? get installationDate;@JsonKey(name: 'location') String? get location;@JsonKey(name: 'placement_type') String? get placementType;@JsonKey(name: 'sim_no') String? get simNo;@JsonKey(name: 'recharge_date') String? get rechargeDate;@JsonKey(name: 'battery_recharge_date') String? get batteryRechargeDate;@JsonKey(name: 'service_provider_primary') String? get serviceProviderPrimary;@JsonKey(name: 'service_provider_secondary') String? get serviceProviderSecondary;@JsonKey(name: 'activation_date') String? get activationDate;@JsonKey(name: 'sim_status') String? get simStatus;@JsonKey(name: 'battery_replacement_date') String? get batteryReplacementDate;@JsonKey(name: 'dual_profile_supported') bool? get dualProfileSupported;@JsonKey(name: 'lora_enabled') bool? get loraEnabled;@JsonKey(name: 'esim_enabled') bool? get esimEnabled;@JsonKey(name: 'battery_capacity') int? get batteryCapacity;@JsonKey(name: 'battery_type') String? get batteryType;@JsonKey(name: 'device_ids') List<String>? get deviceIds;
/// Create a copy of MasterModuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasterModuleConfigurationRequestCopyWith<MasterModuleConfigurationRequest> get copyWith => _$MasterModuleConfigurationRequestCopyWithImpl<MasterModuleConfigurationRequest>(this as MasterModuleConfigurationRequest, _$identity);

  /// Serializes this MasterModuleConfigurationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MasterModuleConfigurationRequest&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.moduleUniqueId, moduleUniqueId) || other.moduleUniqueId == moduleUniqueId)&&(identical(other.makeModel, makeModel) || other.makeModel == makeModel)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.serielNumber, serielNumber) || other.serielNumber == serielNumber)&&(identical(other.installationDate, installationDate) || other.installationDate == installationDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.placementType, placementType) || other.placementType == placementType)&&(identical(other.simNo, simNo) || other.simNo == simNo)&&(identical(other.rechargeDate, rechargeDate) || other.rechargeDate == rechargeDate)&&(identical(other.batteryRechargeDate, batteryRechargeDate) || other.batteryRechargeDate == batteryRechargeDate)&&(identical(other.serviceProviderPrimary, serviceProviderPrimary) || other.serviceProviderPrimary == serviceProviderPrimary)&&(identical(other.serviceProviderSecondary, serviceProviderSecondary) || other.serviceProviderSecondary == serviceProviderSecondary)&&(identical(other.activationDate, activationDate) || other.activationDate == activationDate)&&(identical(other.simStatus, simStatus) || other.simStatus == simStatus)&&(identical(other.batteryReplacementDate, batteryReplacementDate) || other.batteryReplacementDate == batteryReplacementDate)&&(identical(other.dualProfileSupported, dualProfileSupported) || other.dualProfileSupported == dualProfileSupported)&&(identical(other.loraEnabled, loraEnabled) || other.loraEnabled == loraEnabled)&&(identical(other.esimEnabled, esimEnabled) || other.esimEnabled == esimEnabled)&&(identical(other.batteryCapacity, batteryCapacity) || other.batteryCapacity == batteryCapacity)&&(identical(other.batteryType, batteryType) || other.batteryType == batteryType)&&const DeepCollectionEquality().equals(other.deviceIds, deviceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coachId,moduleUniqueId,makeModel,firmwareVersion,serielNumber,installationDate,location,placementType,simNo,rechargeDate,batteryRechargeDate,serviceProviderPrimary,serviceProviderSecondary,activationDate,simStatus,batteryReplacementDate,dualProfileSupported,loraEnabled,esimEnabled,batteryCapacity,batteryType,const DeepCollectionEquality().hash(deviceIds)]);

@override
String toString() {
  return 'MasterModuleConfigurationRequest(coachId: $coachId, moduleUniqueId: $moduleUniqueId, makeModel: $makeModel, firmwareVersion: $firmwareVersion, serielNumber: $serielNumber, installationDate: $installationDate, location: $location, placementType: $placementType, simNo: $simNo, rechargeDate: $rechargeDate, batteryRechargeDate: $batteryRechargeDate, serviceProviderPrimary: $serviceProviderPrimary, serviceProviderSecondary: $serviceProviderSecondary, activationDate: $activationDate, simStatus: $simStatus, batteryReplacementDate: $batteryReplacementDate, dualProfileSupported: $dualProfileSupported, loraEnabled: $loraEnabled, esimEnabled: $esimEnabled, batteryCapacity: $batteryCapacity, batteryType: $batteryType, deviceIds: $deviceIds)';
}


}

/// @nodoc
abstract mixin class $MasterModuleConfigurationRequestCopyWith<$Res>  {
  factory $MasterModuleConfigurationRequestCopyWith(MasterModuleConfigurationRequest value, $Res Function(MasterModuleConfigurationRequest) _then) = _$MasterModuleConfigurationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'coach_id') int? coachId,@JsonKey(name: 'module_unique_id') String? moduleUniqueId,@JsonKey(name: 'make_model') String? makeModel,@JsonKey(name: 'firmware_version') String? firmwareVersion,@JsonKey(name: 'seriel_number') String? serielNumber,@JsonKey(name: 'installation_date') String? installationDate,@JsonKey(name: 'location') String? location,@JsonKey(name: 'placement_type') String? placementType,@JsonKey(name: 'sim_no') String? simNo,@JsonKey(name: 'recharge_date') String? rechargeDate,@JsonKey(name: 'battery_recharge_date') String? batteryRechargeDate,@JsonKey(name: 'service_provider_primary') String? serviceProviderPrimary,@JsonKey(name: 'service_provider_secondary') String? serviceProviderSecondary,@JsonKey(name: 'activation_date') String? activationDate,@JsonKey(name: 'sim_status') String? simStatus,@JsonKey(name: 'battery_replacement_date') String? batteryReplacementDate,@JsonKey(name: 'dual_profile_supported') bool? dualProfileSupported,@JsonKey(name: 'lora_enabled') bool? loraEnabled,@JsonKey(name: 'esim_enabled') bool? esimEnabled,@JsonKey(name: 'battery_capacity') int? batteryCapacity,@JsonKey(name: 'battery_type') String? batteryType,@JsonKey(name: 'device_ids') List<String>? deviceIds
});




}
/// @nodoc
class _$MasterModuleConfigurationRequestCopyWithImpl<$Res>
    implements $MasterModuleConfigurationRequestCopyWith<$Res> {
  _$MasterModuleConfigurationRequestCopyWithImpl(this._self, this._then);

  final MasterModuleConfigurationRequest _self;
  final $Res Function(MasterModuleConfigurationRequest) _then;

/// Create a copy of MasterModuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coachId = freezed,Object? moduleUniqueId = freezed,Object? makeModel = freezed,Object? firmwareVersion = freezed,Object? serielNumber = freezed,Object? installationDate = freezed,Object? location = freezed,Object? placementType = freezed,Object? simNo = freezed,Object? rechargeDate = freezed,Object? batteryRechargeDate = freezed,Object? serviceProviderPrimary = freezed,Object? serviceProviderSecondary = freezed,Object? activationDate = freezed,Object? simStatus = freezed,Object? batteryReplacementDate = freezed,Object? dualProfileSupported = freezed,Object? loraEnabled = freezed,Object? esimEnabled = freezed,Object? batteryCapacity = freezed,Object? batteryType = freezed,Object? deviceIds = freezed,}) {
  return _then(_self.copyWith(
coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as int?,moduleUniqueId: freezed == moduleUniqueId ? _self.moduleUniqueId : moduleUniqueId // ignore: cast_nullable_to_non_nullable
as String?,makeModel: freezed == makeModel ? _self.makeModel : makeModel // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,serielNumber: freezed == serielNumber ? _self.serielNumber : serielNumber // ignore: cast_nullable_to_non_nullable
as String?,installationDate: freezed == installationDate ? _self.installationDate : installationDate // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,placementType: freezed == placementType ? _self.placementType : placementType // ignore: cast_nullable_to_non_nullable
as String?,simNo: freezed == simNo ? _self.simNo : simNo // ignore: cast_nullable_to_non_nullable
as String?,rechargeDate: freezed == rechargeDate ? _self.rechargeDate : rechargeDate // ignore: cast_nullable_to_non_nullable
as String?,batteryRechargeDate: freezed == batteryRechargeDate ? _self.batteryRechargeDate : batteryRechargeDate // ignore: cast_nullable_to_non_nullable
as String?,serviceProviderPrimary: freezed == serviceProviderPrimary ? _self.serviceProviderPrimary : serviceProviderPrimary // ignore: cast_nullable_to_non_nullable
as String?,serviceProviderSecondary: freezed == serviceProviderSecondary ? _self.serviceProviderSecondary : serviceProviderSecondary // ignore: cast_nullable_to_non_nullable
as String?,activationDate: freezed == activationDate ? _self.activationDate : activationDate // ignore: cast_nullable_to_non_nullable
as String?,simStatus: freezed == simStatus ? _self.simStatus : simStatus // ignore: cast_nullable_to_non_nullable
as String?,batteryReplacementDate: freezed == batteryReplacementDate ? _self.batteryReplacementDate : batteryReplacementDate // ignore: cast_nullable_to_non_nullable
as String?,dualProfileSupported: freezed == dualProfileSupported ? _self.dualProfileSupported : dualProfileSupported // ignore: cast_nullable_to_non_nullable
as bool?,loraEnabled: freezed == loraEnabled ? _self.loraEnabled : loraEnabled // ignore: cast_nullable_to_non_nullable
as bool?,esimEnabled: freezed == esimEnabled ? _self.esimEnabled : esimEnabled // ignore: cast_nullable_to_non_nullable
as bool?,batteryCapacity: freezed == batteryCapacity ? _self.batteryCapacity : batteryCapacity // ignore: cast_nullable_to_non_nullable
as int?,batteryType: freezed == batteryType ? _self.batteryType : batteryType // ignore: cast_nullable_to_non_nullable
as String?,deviceIds: freezed == deviceIds ? _self.deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MasterModuleConfigurationRequest].
extension MasterModuleConfigurationRequestPatterns on MasterModuleConfigurationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MasterModuleConfigurationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MasterModuleConfigurationRequest value)  $default,){
final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MasterModuleConfigurationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'module_unique_id')  String? moduleUniqueId, @JsonKey(name: 'make_model')  String? makeModel, @JsonKey(name: 'firmware_version')  String? firmwareVersion, @JsonKey(name: 'seriel_number')  String? serielNumber, @JsonKey(name: 'installation_date')  String? installationDate, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'placement_type')  String? placementType, @JsonKey(name: 'sim_no')  String? simNo, @JsonKey(name: 'recharge_date')  String? rechargeDate, @JsonKey(name: 'battery_recharge_date')  String? batteryRechargeDate, @JsonKey(name: 'service_provider_primary')  String? serviceProviderPrimary, @JsonKey(name: 'service_provider_secondary')  String? serviceProviderSecondary, @JsonKey(name: 'activation_date')  String? activationDate, @JsonKey(name: 'sim_status')  String? simStatus, @JsonKey(name: 'battery_replacement_date')  String? batteryReplacementDate, @JsonKey(name: 'dual_profile_supported')  bool? dualProfileSupported, @JsonKey(name: 'lora_enabled')  bool? loraEnabled, @JsonKey(name: 'esim_enabled')  bool? esimEnabled, @JsonKey(name: 'battery_capacity')  int? batteryCapacity, @JsonKey(name: 'battery_type')  String? batteryType, @JsonKey(name: 'device_ids')  List<String>? deviceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest() when $default != null:
return $default(_that.coachId,_that.moduleUniqueId,_that.makeModel,_that.firmwareVersion,_that.serielNumber,_that.installationDate,_that.location,_that.placementType,_that.simNo,_that.rechargeDate,_that.batteryRechargeDate,_that.serviceProviderPrimary,_that.serviceProviderSecondary,_that.activationDate,_that.simStatus,_that.batteryReplacementDate,_that.dualProfileSupported,_that.loraEnabled,_that.esimEnabled,_that.batteryCapacity,_that.batteryType,_that.deviceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'module_unique_id')  String? moduleUniqueId, @JsonKey(name: 'make_model')  String? makeModel, @JsonKey(name: 'firmware_version')  String? firmwareVersion, @JsonKey(name: 'seriel_number')  String? serielNumber, @JsonKey(name: 'installation_date')  String? installationDate, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'placement_type')  String? placementType, @JsonKey(name: 'sim_no')  String? simNo, @JsonKey(name: 'recharge_date')  String? rechargeDate, @JsonKey(name: 'battery_recharge_date')  String? batteryRechargeDate, @JsonKey(name: 'service_provider_primary')  String? serviceProviderPrimary, @JsonKey(name: 'service_provider_secondary')  String? serviceProviderSecondary, @JsonKey(name: 'activation_date')  String? activationDate, @JsonKey(name: 'sim_status')  String? simStatus, @JsonKey(name: 'battery_replacement_date')  String? batteryReplacementDate, @JsonKey(name: 'dual_profile_supported')  bool? dualProfileSupported, @JsonKey(name: 'lora_enabled')  bool? loraEnabled, @JsonKey(name: 'esim_enabled')  bool? esimEnabled, @JsonKey(name: 'battery_capacity')  int? batteryCapacity, @JsonKey(name: 'battery_type')  String? batteryType, @JsonKey(name: 'device_ids')  List<String>? deviceIds)  $default,) {final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest():
return $default(_that.coachId,_that.moduleUniqueId,_that.makeModel,_that.firmwareVersion,_that.serielNumber,_that.installationDate,_that.location,_that.placementType,_that.simNo,_that.rechargeDate,_that.batteryRechargeDate,_that.serviceProviderPrimary,_that.serviceProviderSecondary,_that.activationDate,_that.simStatus,_that.batteryReplacementDate,_that.dualProfileSupported,_that.loraEnabled,_that.esimEnabled,_that.batteryCapacity,_that.batteryType,_that.deviceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'coach_id')  int? coachId, @JsonKey(name: 'module_unique_id')  String? moduleUniqueId, @JsonKey(name: 'make_model')  String? makeModel, @JsonKey(name: 'firmware_version')  String? firmwareVersion, @JsonKey(name: 'seriel_number')  String? serielNumber, @JsonKey(name: 'installation_date')  String? installationDate, @JsonKey(name: 'location')  String? location, @JsonKey(name: 'placement_type')  String? placementType, @JsonKey(name: 'sim_no')  String? simNo, @JsonKey(name: 'recharge_date')  String? rechargeDate, @JsonKey(name: 'battery_recharge_date')  String? batteryRechargeDate, @JsonKey(name: 'service_provider_primary')  String? serviceProviderPrimary, @JsonKey(name: 'service_provider_secondary')  String? serviceProviderSecondary, @JsonKey(name: 'activation_date')  String? activationDate, @JsonKey(name: 'sim_status')  String? simStatus, @JsonKey(name: 'battery_replacement_date')  String? batteryReplacementDate, @JsonKey(name: 'dual_profile_supported')  bool? dualProfileSupported, @JsonKey(name: 'lora_enabled')  bool? loraEnabled, @JsonKey(name: 'esim_enabled')  bool? esimEnabled, @JsonKey(name: 'battery_capacity')  int? batteryCapacity, @JsonKey(name: 'battery_type')  String? batteryType, @JsonKey(name: 'device_ids')  List<String>? deviceIds)?  $default,) {final _that = this;
switch (_that) {
case _MasterModuleConfigurationRequest() when $default != null:
return $default(_that.coachId,_that.moduleUniqueId,_that.makeModel,_that.firmwareVersion,_that.serielNumber,_that.installationDate,_that.location,_that.placementType,_that.simNo,_that.rechargeDate,_that.batteryRechargeDate,_that.serviceProviderPrimary,_that.serviceProviderSecondary,_that.activationDate,_that.simStatus,_that.batteryReplacementDate,_that.dualProfileSupported,_that.loraEnabled,_that.esimEnabled,_that.batteryCapacity,_that.batteryType,_that.deviceIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MasterModuleConfigurationRequest implements MasterModuleConfigurationRequest {
  const _MasterModuleConfigurationRequest({@JsonKey(name: 'coach_id') this.coachId, @JsonKey(name: 'module_unique_id') this.moduleUniqueId, @JsonKey(name: 'make_model') this.makeModel, @JsonKey(name: 'firmware_version') this.firmwareVersion, @JsonKey(name: 'seriel_number') this.serielNumber, @JsonKey(name: 'installation_date') this.installationDate, @JsonKey(name: 'location') this.location, @JsonKey(name: 'placement_type') this.placementType, @JsonKey(name: 'sim_no') this.simNo, @JsonKey(name: 'recharge_date') this.rechargeDate, @JsonKey(name: 'battery_recharge_date') this.batteryRechargeDate, @JsonKey(name: 'service_provider_primary') this.serviceProviderPrimary, @JsonKey(name: 'service_provider_secondary') this.serviceProviderSecondary, @JsonKey(name: 'activation_date') this.activationDate, @JsonKey(name: 'sim_status') this.simStatus, @JsonKey(name: 'battery_replacement_date') this.batteryReplacementDate, @JsonKey(name: 'dual_profile_supported') this.dualProfileSupported, @JsonKey(name: 'lora_enabled') this.loraEnabled, @JsonKey(name: 'esim_enabled') this.esimEnabled, @JsonKey(name: 'battery_capacity') this.batteryCapacity, @JsonKey(name: 'battery_type') this.batteryType, @JsonKey(name: 'device_ids') final  List<String>? deviceIds}): _deviceIds = deviceIds;
  factory _MasterModuleConfigurationRequest.fromJson(Map<String, dynamic> json) => _$MasterModuleConfigurationRequestFromJson(json);

@override@JsonKey(name: 'coach_id') final  int? coachId;
@override@JsonKey(name: 'module_unique_id') final  String? moduleUniqueId;
@override@JsonKey(name: 'make_model') final  String? makeModel;
@override@JsonKey(name: 'firmware_version') final  String? firmwareVersion;
@override@JsonKey(name: 'seriel_number') final  String? serielNumber;
@override@JsonKey(name: 'installation_date') final  String? installationDate;
@override@JsonKey(name: 'location') final  String? location;
@override@JsonKey(name: 'placement_type') final  String? placementType;
@override@JsonKey(name: 'sim_no') final  String? simNo;
@override@JsonKey(name: 'recharge_date') final  String? rechargeDate;
@override@JsonKey(name: 'battery_recharge_date') final  String? batteryRechargeDate;
@override@JsonKey(name: 'service_provider_primary') final  String? serviceProviderPrimary;
@override@JsonKey(name: 'service_provider_secondary') final  String? serviceProviderSecondary;
@override@JsonKey(name: 'activation_date') final  String? activationDate;
@override@JsonKey(name: 'sim_status') final  String? simStatus;
@override@JsonKey(name: 'battery_replacement_date') final  String? batteryReplacementDate;
@override@JsonKey(name: 'dual_profile_supported') final  bool? dualProfileSupported;
@override@JsonKey(name: 'lora_enabled') final  bool? loraEnabled;
@override@JsonKey(name: 'esim_enabled') final  bool? esimEnabled;
@override@JsonKey(name: 'battery_capacity') final  int? batteryCapacity;
@override@JsonKey(name: 'battery_type') final  String? batteryType;
 final  List<String>? _deviceIds;
@override@JsonKey(name: 'device_ids') List<String>? get deviceIds {
  final value = _deviceIds;
  if (value == null) return null;
  if (_deviceIds is EqualUnmodifiableListView) return _deviceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MasterModuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasterModuleConfigurationRequestCopyWith<_MasterModuleConfigurationRequest> get copyWith => __$MasterModuleConfigurationRequestCopyWithImpl<_MasterModuleConfigurationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MasterModuleConfigurationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MasterModuleConfigurationRequest&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.moduleUniqueId, moduleUniqueId) || other.moduleUniqueId == moduleUniqueId)&&(identical(other.makeModel, makeModel) || other.makeModel == makeModel)&&(identical(other.firmwareVersion, firmwareVersion) || other.firmwareVersion == firmwareVersion)&&(identical(other.serielNumber, serielNumber) || other.serielNumber == serielNumber)&&(identical(other.installationDate, installationDate) || other.installationDate == installationDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.placementType, placementType) || other.placementType == placementType)&&(identical(other.simNo, simNo) || other.simNo == simNo)&&(identical(other.rechargeDate, rechargeDate) || other.rechargeDate == rechargeDate)&&(identical(other.batteryRechargeDate, batteryRechargeDate) || other.batteryRechargeDate == batteryRechargeDate)&&(identical(other.serviceProviderPrimary, serviceProviderPrimary) || other.serviceProviderPrimary == serviceProviderPrimary)&&(identical(other.serviceProviderSecondary, serviceProviderSecondary) || other.serviceProviderSecondary == serviceProviderSecondary)&&(identical(other.activationDate, activationDate) || other.activationDate == activationDate)&&(identical(other.simStatus, simStatus) || other.simStatus == simStatus)&&(identical(other.batteryReplacementDate, batteryReplacementDate) || other.batteryReplacementDate == batteryReplacementDate)&&(identical(other.dualProfileSupported, dualProfileSupported) || other.dualProfileSupported == dualProfileSupported)&&(identical(other.loraEnabled, loraEnabled) || other.loraEnabled == loraEnabled)&&(identical(other.esimEnabled, esimEnabled) || other.esimEnabled == esimEnabled)&&(identical(other.batteryCapacity, batteryCapacity) || other.batteryCapacity == batteryCapacity)&&(identical(other.batteryType, batteryType) || other.batteryType == batteryType)&&const DeepCollectionEquality().equals(other._deviceIds, _deviceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,coachId,moduleUniqueId,makeModel,firmwareVersion,serielNumber,installationDate,location,placementType,simNo,rechargeDate,batteryRechargeDate,serviceProviderPrimary,serviceProviderSecondary,activationDate,simStatus,batteryReplacementDate,dualProfileSupported,loraEnabled,esimEnabled,batteryCapacity,batteryType,const DeepCollectionEquality().hash(_deviceIds)]);

@override
String toString() {
  return 'MasterModuleConfigurationRequest(coachId: $coachId, moduleUniqueId: $moduleUniqueId, makeModel: $makeModel, firmwareVersion: $firmwareVersion, serielNumber: $serielNumber, installationDate: $installationDate, location: $location, placementType: $placementType, simNo: $simNo, rechargeDate: $rechargeDate, batteryRechargeDate: $batteryRechargeDate, serviceProviderPrimary: $serviceProviderPrimary, serviceProviderSecondary: $serviceProviderSecondary, activationDate: $activationDate, simStatus: $simStatus, batteryReplacementDate: $batteryReplacementDate, dualProfileSupported: $dualProfileSupported, loraEnabled: $loraEnabled, esimEnabled: $esimEnabled, batteryCapacity: $batteryCapacity, batteryType: $batteryType, deviceIds: $deviceIds)';
}


}

/// @nodoc
abstract mixin class _$MasterModuleConfigurationRequestCopyWith<$Res> implements $MasterModuleConfigurationRequestCopyWith<$Res> {
  factory _$MasterModuleConfigurationRequestCopyWith(_MasterModuleConfigurationRequest value, $Res Function(_MasterModuleConfigurationRequest) _then) = __$MasterModuleConfigurationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'coach_id') int? coachId,@JsonKey(name: 'module_unique_id') String? moduleUniqueId,@JsonKey(name: 'make_model') String? makeModel,@JsonKey(name: 'firmware_version') String? firmwareVersion,@JsonKey(name: 'seriel_number') String? serielNumber,@JsonKey(name: 'installation_date') String? installationDate,@JsonKey(name: 'location') String? location,@JsonKey(name: 'placement_type') String? placementType,@JsonKey(name: 'sim_no') String? simNo,@JsonKey(name: 'recharge_date') String? rechargeDate,@JsonKey(name: 'battery_recharge_date') String? batteryRechargeDate,@JsonKey(name: 'service_provider_primary') String? serviceProviderPrimary,@JsonKey(name: 'service_provider_secondary') String? serviceProviderSecondary,@JsonKey(name: 'activation_date') String? activationDate,@JsonKey(name: 'sim_status') String? simStatus,@JsonKey(name: 'battery_replacement_date') String? batteryReplacementDate,@JsonKey(name: 'dual_profile_supported') bool? dualProfileSupported,@JsonKey(name: 'lora_enabled') bool? loraEnabled,@JsonKey(name: 'esim_enabled') bool? esimEnabled,@JsonKey(name: 'battery_capacity') int? batteryCapacity,@JsonKey(name: 'battery_type') String? batteryType,@JsonKey(name: 'device_ids') List<String>? deviceIds
});




}
/// @nodoc
class __$MasterModuleConfigurationRequestCopyWithImpl<$Res>
    implements _$MasterModuleConfigurationRequestCopyWith<$Res> {
  __$MasterModuleConfigurationRequestCopyWithImpl(this._self, this._then);

  final _MasterModuleConfigurationRequest _self;
  final $Res Function(_MasterModuleConfigurationRequest) _then;

/// Create a copy of MasterModuleConfigurationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coachId = freezed,Object? moduleUniqueId = freezed,Object? makeModel = freezed,Object? firmwareVersion = freezed,Object? serielNumber = freezed,Object? installationDate = freezed,Object? location = freezed,Object? placementType = freezed,Object? simNo = freezed,Object? rechargeDate = freezed,Object? batteryRechargeDate = freezed,Object? serviceProviderPrimary = freezed,Object? serviceProviderSecondary = freezed,Object? activationDate = freezed,Object? simStatus = freezed,Object? batteryReplacementDate = freezed,Object? dualProfileSupported = freezed,Object? loraEnabled = freezed,Object? esimEnabled = freezed,Object? batteryCapacity = freezed,Object? batteryType = freezed,Object? deviceIds = freezed,}) {
  return _then(_MasterModuleConfigurationRequest(
coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as int?,moduleUniqueId: freezed == moduleUniqueId ? _self.moduleUniqueId : moduleUniqueId // ignore: cast_nullable_to_non_nullable
as String?,makeModel: freezed == makeModel ? _self.makeModel : makeModel // ignore: cast_nullable_to_non_nullable
as String?,firmwareVersion: freezed == firmwareVersion ? _self.firmwareVersion : firmwareVersion // ignore: cast_nullable_to_non_nullable
as String?,serielNumber: freezed == serielNumber ? _self.serielNumber : serielNumber // ignore: cast_nullable_to_non_nullable
as String?,installationDate: freezed == installationDate ? _self.installationDate : installationDate // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,placementType: freezed == placementType ? _self.placementType : placementType // ignore: cast_nullable_to_non_nullable
as String?,simNo: freezed == simNo ? _self.simNo : simNo // ignore: cast_nullable_to_non_nullable
as String?,rechargeDate: freezed == rechargeDate ? _self.rechargeDate : rechargeDate // ignore: cast_nullable_to_non_nullable
as String?,batteryRechargeDate: freezed == batteryRechargeDate ? _self.batteryRechargeDate : batteryRechargeDate // ignore: cast_nullable_to_non_nullable
as String?,serviceProviderPrimary: freezed == serviceProviderPrimary ? _self.serviceProviderPrimary : serviceProviderPrimary // ignore: cast_nullable_to_non_nullable
as String?,serviceProviderSecondary: freezed == serviceProviderSecondary ? _self.serviceProviderSecondary : serviceProviderSecondary // ignore: cast_nullable_to_non_nullable
as String?,activationDate: freezed == activationDate ? _self.activationDate : activationDate // ignore: cast_nullable_to_non_nullable
as String?,simStatus: freezed == simStatus ? _self.simStatus : simStatus // ignore: cast_nullable_to_non_nullable
as String?,batteryReplacementDate: freezed == batteryReplacementDate ? _self.batteryReplacementDate : batteryReplacementDate // ignore: cast_nullable_to_non_nullable
as String?,dualProfileSupported: freezed == dualProfileSupported ? _self.dualProfileSupported : dualProfileSupported // ignore: cast_nullable_to_non_nullable
as bool?,loraEnabled: freezed == loraEnabled ? _self.loraEnabled : loraEnabled // ignore: cast_nullable_to_non_nullable
as bool?,esimEnabled: freezed == esimEnabled ? _self.esimEnabled : esimEnabled // ignore: cast_nullable_to_non_nullable
as bool?,batteryCapacity: freezed == batteryCapacity ? _self.batteryCapacity : batteryCapacity // ignore: cast_nullable_to_non_nullable
as int?,batteryType: freezed == batteryType ? _self.batteryType : batteryType // ignore: cast_nullable_to_non_nullable
as String?,deviceIds: freezed == deviceIds ? _self._deviceIds : deviceIds // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
