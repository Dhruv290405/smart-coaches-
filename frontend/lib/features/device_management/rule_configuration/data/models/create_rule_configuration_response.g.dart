// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_rule_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRuleConfigurationResponse _$CreateRuleConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => CreateRuleConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$CreateRuleConfigurationResponseToJson(
  CreateRuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
