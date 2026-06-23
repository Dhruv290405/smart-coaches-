// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_rule_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditRuleConfigurationResponse _$EditRuleConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => EditRuleConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$EditRuleConfigurationResponseToJson(
  EditRuleConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
