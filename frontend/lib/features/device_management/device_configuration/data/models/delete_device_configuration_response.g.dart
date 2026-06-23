// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteDeviceConfigurationResponse _$DeleteDeviceConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => DeleteDeviceConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$DeleteDeviceConfigurationResponseToJson(
  DeleteDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
