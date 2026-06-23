import 'package:json_annotation/json_annotation.dart';

part 'device_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class DeviceListResponse {
  final bool success;
  final String message;
  final List<DeviceItem>? data;

  DeviceListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListResponseToJson(this);
}

@JsonSerializable()
class DeviceItem {
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'short_name')
  final String? shortName;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'data_type')
  final String? dataType;
  @JsonKey(name: 'frequency_secs')
  final double? frequency;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  @JsonKey(name: 'master_module_id')
  final int? masterModuleId;
  @JsonKey(name: 'device_unique_id')
  final String? deviceUniqueId;
  @JsonKey(name: 'time_unit')
  final String? timeUnit;
  @JsonKey(name: 'is_active')
  final int? isActive;
  @JsonKey(name: 'no_of_sensors')
  final int? numberOfSensors;
  @JsonKey(name: 'master_module_serial')
  final String? masterModuleSerial;
  @JsonKey(name: 'coach_unique_id')
  final String? coachUniqueId;
  @JsonKey(name: 'train_number')
  final int? trainNumber;
  @JsonKey(name: 'train_name')
  final String? trainName;
  @JsonKey(name: 'device_type_name')
  final String? deviceTypeName;
  @JsonKey(name: 'device_model')
  final String? deviceModel;

  DeviceItem({
    this.deviceId,
    this.shortName,
    this.fullName,
    this.description,
    this.dataType,
    this.frequency,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.masterModuleId,
    this.deviceUniqueId,
    this.timeUnit,
    this.isActive,
    this.numberOfSensors,
    this.masterModuleSerial,
    this.coachUniqueId,
    this.trainNumber,
    this.trainName,
    this.deviceTypeName,
    this.deviceModel,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) =>
      _$DeviceItemFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceItemToJson(this);
}
