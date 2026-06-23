// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_master_module_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditMasterModuleConfigurationResponse
_$EditMasterModuleConfigurationResponseFromJson(Map<String, dynamic> json) =>
    EditMasterModuleConfigurationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$EditMasterModuleConfigurationResponseToJson(
  EditMasterModuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
