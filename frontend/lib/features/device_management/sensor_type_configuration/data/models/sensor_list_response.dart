import 'package:json_annotation/json_annotation.dart';

part 'sensor_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class SensorListResponse {
  final bool success;
  final String message;
  final List<SensorItem>? data;

  SensorListResponse({required this.success, required this.message, this.data});

  factory SensorListResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SensorItem {
  @JsonKey(name: 'sensor_type_id')
  final int? sensorTypeId;

  @JsonKey(name: 'sensor_type_name')
  final String? sensorTypeName;

  final Category? category;

  @JsonKey(name: 'value_type')
  final String? valueType;

  final String? name;
  final String? description;

  @JsonKey(name: 'value_format')
  final String? valueFormat;

  @JsonKey(name: 'min_expected_value')
  final num? minExpectedValue;

  @JsonKey(name: 'max_expected_value')
  final num? maxExpectedValue;

  @JsonKey(name: 'sampling_frequency')
  final String? samplingFrequency;

  @JsonKey(name: 'time_interval')
  final String? timeInterval;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  final List<Unit>? units;
  final List<Device>? devices;

  SensorItem({
    this.sensorTypeId,
    this.sensorTypeName,
    this.category,
    this.valueType,
    this.name,
    this.description,
    this.valueFormat,
    this.minExpectedValue,
    this.maxExpectedValue,
    this.samplingFrequency,
    this.timeInterval,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.units,
    this.devices,
  });

  factory SensorItem.fromJson(Map<String, dynamic> json) =>
      _$SensorItemFromJson(json);

  Map<String, dynamic> toJson() => _$SensorItemToJson(this);
}

@JsonSerializable()
class Category {
  final int? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Unit {
  @JsonKey(name: 'unit_id')
  final int? unitId;
  final String? unit;

  Unit({this.unitId, this.unit});

  factory Unit.fromJson(Map<String, dynamic> json) =>
      _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}

@JsonSerializable()
class Device {
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'short_name')
  final String? shortName;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'device_unique_id')
  final String? deviceUniqueId;

  Device({this.deviceId, this.shortName, this.fullName, this.deviceUniqueId});

  factory Device.fromJson(Map<String, dynamic> json) =>
      _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
