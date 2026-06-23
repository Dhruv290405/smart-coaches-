// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sensor_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSensorDeviceConfigurationResponse
_$CreateSensorDeviceConfigurationResponseFromJson(Map<String, dynamic> json) =>
    CreateSensorDeviceConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$CreateSensorDeviceConfigurationResponseToJson(
  CreateSensorDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
