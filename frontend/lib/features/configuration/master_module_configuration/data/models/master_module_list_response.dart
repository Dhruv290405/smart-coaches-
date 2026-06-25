import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';

part 'master_module_list_response.g.dart';

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable(explicitToJson: true)
class MasterModuleListResponse {
  final bool success;
  final String message;
  final List<MasterModuleItem>? data;

  MasterModuleListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MasterModuleListResponse.fromJson(Map<String, dynamic> json) =>
      _$MasterModuleListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MasterModuleListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MasterModuleItem {
  @JsonKey(name: 'module_id')
  final int? moduleId;

  @JsonKey(name: 'module_unique_id')
  final String? moduleUniqueId;

  @JsonKey(name: 'make_model')
  final String? makeModel;

  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;

  @JsonKey(name: 'seriel_number')
  final String? serialNumber;

  @JsonKey(name: 'installation_date')
  final String? installationDate;

  final String? location;

  @JsonKey(name: 'placement_type')
  final String? placementType;

  @JsonKey(name: 'sim_no')
  final String? simNo;

  @JsonKey(name: 'service_provider_primary')
  final String? serviceProviderPrimary;

  @JsonKey(name: 'service_provider_secondary')
  final String? serviceProviderSecondary;

  @JsonKey(name: 'activation_date')
  final String? activationDate;

  @JsonKey(name: 'recharge_date')
  final String? rechargeDate;

  @JsonKey(name: 'battery_recharge_date')
  final String? batteryRechargeDate;

  @JsonKey(name: 'sim_status')
  final String? simStatus;

  @JsonKey(name: 'battery_replacement_date')
  final String? batteryReplacementDate;

  @JsonKey(name: 'dual_profile_supported')
  final bool? dualProfileSupported;

  @JsonKey(name: 'lora_enabled')
  final bool? loraEnabled;

  @JsonKey(name: 'esim_enabled')
  final bool? esimEnabled;

  @JsonKey(name: 'battery_capacity')
  final int? batteryCapacity;

  @JsonKey(name: 'battery_type')
  final String? batteryType;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'updated_by')
  final int? updatedBy;

  @JsonKey(name: 'updated_date')
  final String? updatedDate;

  final CoachItem? coach;
  final TrainItem? train;

  @JsonKey(name: 'module_created_by_name')
  final String? createdByName;

  @JsonKey(name: 'module_updated_by_name')
  final String? updatedByName;

  final List<DeviceItem>? devices;

  MasterModuleItem({
    this.moduleId,
    this.moduleUniqueId,
    this.makeModel,
    this.firmwareVersion,
    this.serialNumber,
    this.installationDate,
    this.location,
    this.placementType,
    this.simNo,
    this.serviceProviderPrimary,
    this.serviceProviderSecondary,
    this.activationDate,
    this.rechargeDate,
    this.batteryRechargeDate,
    this.simStatus,
    this.batteryReplacementDate,
    this.dualProfileSupported,
    this.loraEnabled,
    this.esimEnabled,
    this.batteryCapacity,
    this.batteryType,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.coach,
    this.train,
    this.createdByName,
    this.updatedByName,
    this.devices,
  });

  factory MasterModuleItem.fromJson(Map<String, dynamic> json) =>
      _$MasterModuleItemFromJson(json);

  Map<String, dynamic> toJson() => _$MasterModuleItemToJson(this);
}