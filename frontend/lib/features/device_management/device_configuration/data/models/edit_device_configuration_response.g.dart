// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_device_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditDeviceConfigurationResponse _$EditDeviceConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => EditDeviceConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$EditDeviceConfigurationResponseToJson(
  EditDeviceConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
