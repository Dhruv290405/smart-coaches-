// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sensor_type_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSensorTypeConfigurationResponse
_$CreateSensorTypeConfigurationResponseFromJson(Map<String, dynamic> json) =>
    CreateSensorTypeConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$CreateSensorTypeConfigurationResponseToJson(
  CreateSensorTypeConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
