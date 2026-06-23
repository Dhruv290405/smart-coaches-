// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_sensor_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteSensorDeviceConfigurationResponse
_$DeleteSensorDeviceConfigurationResponseFromJson(Map<String, dynamic> json) =>
    DeleteSensorDeviceConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$DeleteSensorDeviceConfigurationResponseToJson(
  DeleteSensorDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
