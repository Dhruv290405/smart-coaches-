// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_master_module_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteMasterModuleConfigurationResponse
_$DeleteMasterModuleConfigurationResponseFromJson(Map<String, dynamic> json) =>
    DeleteMasterModuleConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$DeleteMasterModuleConfigurationResponseToJson(
  DeleteMasterModuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
