// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_rule_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteRuleConfigurationResponse _$DeleteRuleConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => DeleteRuleConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$DeleteRuleConfigurationResponseToJson(
  DeleteRuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
