// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_module_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MasterModuleListResponse _$MasterModuleListResponseFromJson(
  Map<String, dynamic> json,
) => MasterModuleListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => MasterModuleItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MasterModuleListResponseToJson(
  MasterModuleListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

MasterModuleItem _$MasterModuleItemFromJson(Map<String, dynamic> json) =>
    MasterModuleItem(
      moduleId: (json['module_id'] as num?)?.toInt(),
      moduleUniqueId: json['module_unique_id'] as String?,
      makeModel: json['make_model'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
      serialNumber: json['seriel_number'] as String?,
      installationDate: json['installation_date'] as String?,
      location: json['location'] as String?,
      placementType: json['placement_type'] as String?,
      simNo: json['sim_no'] as String?,
      serviceProviderPrimary: json['service_provider_primary'] as String?,
      serviceProviderSecondary: json['service_provider_secondary'] as String?,
      activationDate: json['activation_date'] as String?,
      rechargeDate: json['recharge_date'] as String?,
      batteryRechargeDate: json['battery_recharge_date'] as String?,
      simStatus: json['sim_status'] as String?,
      batteryReplacementDate: json['battery_replacement_date'] as String?,
      dualProfileSupported: json['dual_profile_supported'] as bool?,
      loraEnabled: json['lora_enabled'] as bool?,
      esimEnabled: json['esim_enabled'] as bool?,
      batteryCapacity: (json['battery_capacity'] as num?)?.toInt(),
      batteryType: json['battery_type'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdDate: json['created_date'] as String?,
      updatedBy: (json['updated_by'] as num?)?.toInt(),
      updatedDate: json['updated_date'] as String?,
      coach: json['coach'] == null
          ? null
          : CoachItem.fromJson(json['coach'] as Map<String, dynamic>),
      train: json['train'] == null
          ? null
          : TrainItem.fromJson(json['train'] as Map<String, dynamic>),
      createdByName: json['module_created_by_name'] as String?,
      updatedByName: json['module_updated_by_name'] as String?,
      devices: (json['devices'] as List<dynamic>?)
          ?.map((e) => DeviceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MasterModuleItemToJson(MasterModuleItem instance) =>
    <String, dynamic>{
      'module_id': instance.moduleId,
      'module_unique_id': instance.moduleUniqueId,
      'make_model': instance.makeModel,
      'firmware_version': instance.firmwareVersion,
      'seriel_number': instance.serialNumber,
      'installation_date': instance.installationDate,
      'location': instance.location,
      'placement_type': instance.placementType,
      'sim_no': instance.simNo,
      'service_provider_primary': instance.serviceProviderPrimary,
      'service_provider_secondary': instance.serviceProviderSecondary,
      'activation_date': instance.activationDate,
      'recharge_date': instance.rechargeDate,
      'battery_recharge_date': instance.batteryRechargeDate,
      'sim_status': instance.simStatus,
      'battery_replacement_date': instance.batteryReplacementDate,
      'dual_profile_supported': instance.dualProfileSupported,
      'lora_enabled': instance.loraEnabled,
      'esim_enabled': instance.esimEnabled,
      'battery_capacity': instance.batteryCapacity,
      'battery_type': instance.batteryType,
      'created_by': instance.createdBy,
      'created_date': instance.createdDate,
      'updated_by': instance.updatedBy,
      'updated_date': instance.updatedDate,
      'coach': instance.coach?.toJson(),
      'train': instance.train?.toJson(),
      'module_created_by_name': instance.createdByName,
      'module_updated_by_name': instance.updatedByName,
      'devices': instance.devices?.map((e) => e.toJson()).toList(),
    };
