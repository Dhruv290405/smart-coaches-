// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_module_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MasterModuleConfigurationRequest _$MasterModuleConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _MasterModuleConfigurationRequest(
  coachId: (json['coach_id'] as num?)?.toInt(),
  moduleUniqueId: json['module_unique_id'] as String?,
  makeModel: json['make_model'] as String?,
  firmwareVersion: json['firmware_version'] as String?,
  serielNumber: json['seriel_number'] as String?,
  installationDate: json['installation_date'] as String?,
  location: json['location'] as String?,
  placementType: json['placement_type'] as String?,
  simNo: json['sim_no'] as String?,
  rechargeDate: json['recharge_date'] as String?,
  batteryRechargeDate: json['battery_recharge_date'] as String?,
  serviceProviderPrimary: json['service_provider_primary'] as String?,
  serviceProviderSecondary: json['service_provider_secondary'] as String?,
  activationDate: json['activation_date'] as String?,
  simStatus: json['sim_status'] as String?,
  batteryReplacementDate: json['battery_replacement_date'] as String?,
  dualProfileSupported: json['dual_profile_supported'] as bool?,
  loraEnabled: json['lora_enabled'] as bool?,
  esimEnabled: json['esim_enabled'] as bool?,
  batteryCapacity: (json['battery_capacity'] as num?)?.toInt(),
  batteryType: json['battery_type'] as String?,
  deviceIds: (json['device_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MasterModuleConfigurationRequestToJson(
  _MasterModuleConfigurationRequest instance,
) => <String, dynamic>{
  'coach_id': instance.coachId,
  'module_unique_id': instance.moduleUniqueId,
  'make_model': instance.makeModel,
  'firmware_version': instance.firmwareVersion,
  'seriel_number': instance.serielNumber,
  'installation_date': instance.installationDate,
  'location': instance.location,
  'placement_type': instance.placementType,
  'sim_no': instance.simNo,
  'recharge_date': instance.rechargeDate,
  'battery_recharge_date': instance.batteryRechargeDate,
  'service_provider_primary': instance.serviceProviderPrimary,
  'service_provider_secondary': instance.serviceProviderSecondary,
  'activation_date': instance.activationDate,
  'sim_status': instance.simStatus,
  'battery_replacement_date': instance.batteryReplacementDate,
  'dual_profile_supported': instance.dualProfileSupported,
  'lora_enabled': instance.loraEnabled,
  'esim_enabled': instance.esimEnabled,
  'battery_capacity': instance.batteryCapacity,
  'battery_type': instance.batteryType,
  'device_ids': instance.deviceIds,
};
