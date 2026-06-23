// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_master_module_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMasterModuleConfigurationResponse
_$CreateMasterModuleConfigurationResponseFromJson(Map<String, dynamic> json) =>
    CreateMasterModuleConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$CreateMasterModuleConfigurationResponseToJson(
  CreateMasterModuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
