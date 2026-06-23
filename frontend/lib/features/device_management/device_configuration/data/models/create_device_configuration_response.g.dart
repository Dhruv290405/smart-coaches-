// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDeviceConfigurationResponse _$CreateDeviceConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => CreateDeviceConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$CreateDeviceConfigurationResponseToJson(
  CreateDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
