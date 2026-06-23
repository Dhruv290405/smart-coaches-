// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_sensor_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditSensorDeviceConfigurationResponse
_$EditSensorDeviceConfigurationResponseFromJson(Map<String, dynamic> json) =>
    EditSensorDeviceConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$EditSensorDeviceConfigurationResponseToJson(
  EditSensorDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
