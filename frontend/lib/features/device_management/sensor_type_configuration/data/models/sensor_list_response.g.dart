// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorListResponse _$SensorListResponseFromJson(Map<String, dynamic> json) =>
    SensorListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SensorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorListResponseToJson(SensorListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

SensorItem _$SensorItemFromJson(Map<String, dynamic> json) => SensorItem(
  sensorTypeId: (json['sensor_type_id'] as num?)?.toInt(),
  sensorTypeName: json['sensor_type_name'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  valueType: json['value_type'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  valueFormat: json['value_format'] as String?,
  minExpectedValue: json['min_expected_value'] as num?,
  maxExpectedValue: json['max_expected_value'] as num?,
  samplingFrequency: json['sampling_frequency'] as String?,
  timeInterval: json['time_interval'] as String?,
  isActive: json['is_active'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
  units: (json['units'] as List<dynamic>?)
      ?.map((e) => Unit.fromJson(e as Map<String, dynamic>))
      .toList(),
  devices: (json['devices'] as List<dynamic>?)
      ?.map((e) => Device.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorItemToJson(SensorItem instance) =>
    <String, dynamic>{
      'sensor_type_id': instance.sensorTypeId,
      'sensor_type_name': instance.sensorTypeName,
      'category': instance.category?.toJson(),
      'value_type': instance.valueType,
      'name': instance.name,
      'description': instance.description,
      'value_format': instance.valueFormat,
      'min_expected_value': instance.minExpectedValue,
      'max_expected_value': instance.maxExpectedValue,
      'sampling_frequency': instance.samplingFrequency,
      'time_interval': instance.timeInterval,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'units': instance.units?.map((e) => e.toJson()).toList(),
      'devices': instance.devices?.map((e) => e.toJson()).toList(),
    };

Category _$CategoryFromJson(Map<String, dynamic> json) =>
    Category(id: (json['id'] as num?)?.toInt(), name: json['name'] as String?);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
  unitId: (json['unit_id'] as num?)?.toInt(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
  'unit_id': instance.unitId,
  'unit': instance.unit,
};

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  deviceId: json['device_id'] as String?,
  shortName: json['short_name'] as String?,
  fullName: json['full_name'] as String?,
  deviceUniqueId: json['device_unique_id'] as String?,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'device_id': instance.deviceId,
  'short_name': instance.shortName,
  'full_name': instance.fullName,
  'device_unique_id': instance.deviceUniqueId,
};
