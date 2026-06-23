// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_type_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SensorTypeConfigurationRequest _$SensorTypeConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _SensorTypeConfigurationRequest(
  sensorTypeName: json['sensor_type_name'] as String?,
  category: (json['category'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  valueFormat: json['value_format'] as String?,
  minExpectedValue: (json['min_expected_value'] as num?)?.toInt(),
  maxExpectedValue: (json['max_expected_value'] as num?)?.toInt(),
  samplingFrequency: (json['sampling_frequency'] as num?)?.toDouble(),
  timeInterval: json['time_interval'] as String?,
  isActive: json['is_active'] as bool?,
  unitIds: (json['unit_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  deviceIds: (json['device_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SensorTypeConfigurationRequestToJson(
  _SensorTypeConfigurationRequest instance,
) => <String, dynamic>{
  'sensor_type_name': instance.sensorTypeName,
  'category': instance.category,
  'name': instance.name,
  'description': instance.description,
  'value_format': instance.valueFormat,
  'min_expected_value': instance.minExpectedValue,
  'max_expected_value': instance.maxExpectedValue,
  'sampling_frequency': instance.samplingFrequency,
  'time_interval': instance.timeInterval,
  'is_active': instance.isActive,
  'unit_ids': instance.unitIds,
  'device_ids': instance.deviceIds,
};
