// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_device_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SensorDeviceConfigurationRequest _$SensorDeviceConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _SensorDeviceConfigurationRequest(
  coachId: (json['coach_id'] as num?)?.toInt(),
  masterModuleId: (json['master_module_id'] as num?)?.toInt(),
  deviceId: json['device_id'] as String?,
  sensors: (json['sensors'] as List<dynamic>?)
      ?.map((e) => SensorRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorDeviceConfigurationRequestToJson(
  _SensorDeviceConfigurationRequest instance,
) => <String, dynamic>{
  'coach_id': instance.coachId,
  'master_module_id': instance.masterModuleId,
  'device_id': instance.deviceId,
  'sensors': instance.sensors,
};

_SensorRequest _$SensorRequestFromJson(Map<String, dynamic> json) =>
    _SensorRequest(
      sensorId: json['sensor_id'] as String?,
      sensorMakeId: (json['sensor_make_id'] as num?)?.toInt(),
      installDate: json['install_date'] as String?,
      placement: json['placement'] as String?,
      location: json['location'] as String?,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$SensorRequestToJson(_SensorRequest instance) =>
    <String, dynamic>{
      'sensor_id': instance.sensorId,
      'sensor_make_id': instance.sensorMakeId,
      'install_date': instance.installDate,
      'placement': instance.placement,
      'location': instance.location,
      'remarks': instance.remarks,
    };
