// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceConfigurationRequest _$DeviceConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _DeviceConfigurationRequest(
  deviceUniqueId: json['device_unique_id'] as String?,
  dataType: json['data_type'] as String?,
  timeUnit: json['time_unit'] as String?,
  description: json['description'] as String?,
  isActive: json['is_active'] as bool?,
  frequency: (json['frequency_secs'] as num?)?.toDouble(),
  fullName: json['full_name'] as String?,
  shortName: json['short_name'] as String?,
  numberOfSensors: (json['no_of_sensors'] as num?)?.toInt(),
);

Map<String, dynamic> _$DeviceConfigurationRequestToJson(
  _DeviceConfigurationRequest instance,
) => <String, dynamic>{
  'device_unique_id': instance.deviceUniqueId,
  'data_type': instance.dataType,
  'time_unit': instance.timeUnit,
  'description': instance.description,
  'is_active': instance.isActive,
  'frequency_secs': instance.frequency,
  'full_name': instance.fullName,
  'short_name': instance.shortName,
  'no_of_sensors': instance.numberOfSensors,
};
