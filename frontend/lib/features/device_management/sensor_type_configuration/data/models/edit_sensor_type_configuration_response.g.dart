// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_sensor_type_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditSensorTypeConfigurationResponse
_$EditSensorTypeConfigurationResponseFromJson(Map<String, dynamic> json) =>
    EditSensorTypeConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$EditSensorTypeConfigurationResponseToJson(
  EditSensorTypeConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
