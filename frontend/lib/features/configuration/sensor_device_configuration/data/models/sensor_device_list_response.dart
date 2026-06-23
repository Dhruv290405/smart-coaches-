import 'package:json_annotation/json_annotation.dart';

part 'sensor_device_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SensorDeviceListResponse {
  final bool success;
  final String message;
  final List<SensorDeviceItem>? data;

  SensorDeviceListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SensorDeviceListResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorDeviceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDeviceListResponseToJson(this);
}

@JsonSerializable()
class SensorDeviceItem {
  @JsonKey(name: 'sensor_config_id')
  final int? sensorConfigId;

  @JsonKey(name: 'sensor_type_id')
  final int? sensorTypeId;

  @JsonKey(name: 'sensor_id')
  final String? sensorTypeName;

  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'sensor_make_id')
  final int? sensorMakeId;

  @JsonKey(name: 'install_date')
  final String? installDate;

  final String? placement;
  final String? location;
  final String? remarks;

  @JsonKey(name: 'master_module_id')
  final int? masterModuleId;

  @JsonKey(name: 'coach_id')
  final int? coachId;

  @JsonKey(name: 'short_name')
  final String? shortName;

  @JsonKey(name: 'full_name')
  final String? fullName;

  final String? description;

  @JsonKey(name: 'data_type')
  final String? dataType;

  @JsonKey(name: 'frequency_secs')
  final double? frequencySecs;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'updated_by')
  final int? updatedBy;   // change from String? -> int?

  @JsonKey(name: 'device_unique_id')
  final String? deviceUniqueId;

  @JsonKey(name: 'time_unit')
  final String? timeUnit;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'no_of_sensors')
  final int? noOfSensors;

  final String? name;

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

  @JsonKey(name: 'sim_status')
  final String? simStatus;

  @JsonKey(name: 'recharge_date')
  final String? rechargeDate;

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

  @JsonKey(name: 'battery_recharge_date')
  final String? batteryRechargeDate;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'updated_date')
  final String? updatedDate;

  @JsonKey(name: 'entity_type')
  final String? entityType;

  @JsonKey(name: 'train_id')
  final int? trainId;

  @JsonKey(name: 'coach_unique_id')
  final String? coachUniqueId;

  @JsonKey(name: 'coach_display_id')
  final String? coachDisplayId;

  @JsonKey(name: 'make_of_coach')
  final int? makeOfCoach;

  @JsonKey(name: 'type_of_coach')
  final int? typeOfCoach;

  @JsonKey(name: 'manufacturing_year')
  final int? manufacturingYear;

  final int? position;

  @JsonKey(name: 'no_of_master_module')
  final int? noOfMasterModule;

  @JsonKey(name: 'coach_status')
  final String? coachStatus;

  @JsonKey(name: 'total_devices_attached')
  final int? totalDevicesAttached;

  @JsonKey(name: 'tech_coach_no')
  final String? techCoachNo;

  @JsonKey(name: 'comm_coach_no')
  final String? commCoachNo;

  @JsonKey(name: 'train_no')
  final String? trainNo;

  final String? status;

  SensorDeviceItem({
    this.sensorConfigId,
    this.sensorTypeId,
    this.sensorTypeName,
    this.deviceId,
    this.sensorMakeId,
    this.installDate,
    this.placement,
    this.location,
    this.remarks,
    this.masterModuleId,
    this.coachId,
    this.shortName,
    this.fullName,
    this.description,
    this.dataType,
    this.frequencySecs,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deviceUniqueId,
    this.timeUnit,
    this.isActive,
    this.noOfSensors,
    this.name,
    this.moduleId,
    this.moduleUniqueId,
    this.makeModel,
    this.firmwareVersion,
    this.serialNumber,
    this.installationDate,
    this.placementType,
    this.simNo,
    this.serviceProviderPrimary,
    this.serviceProviderSecondary,
    this.activationDate,
    this.simStatus,
    this.rechargeDate,
    this.batteryReplacementDate,
    this.dualProfileSupported,
    this.loraEnabled,
    this.esimEnabled,
    this.batteryCapacity,
    this.batteryType,
    this.batteryRechargeDate,
    this.createdDate,
    this.updatedDate,
    this.entityType,
    this.trainId,
    this.coachUniqueId,
    this.coachDisplayId,
    this.makeOfCoach,
    this.typeOfCoach,
    this.manufacturingYear,
    this.position,
    this.noOfMasterModule,
    this.coachStatus,
    this.totalDevicesAttached,
    this.techCoachNo,
    this.commCoachNo,
    this.trainNo,
    this.status,
  });

  factory SensorDeviceItem.fromJson(Map<String, dynamic> json) =>
      _$SensorDeviceItemFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDeviceItemToJson(this);
}
