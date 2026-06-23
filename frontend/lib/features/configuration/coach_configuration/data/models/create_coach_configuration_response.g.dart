// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_coach_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCoachConfigurationResponse _$CreateCoachConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => CreateCoachConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$CreateCoachConfigurationResponseToJson(
  CreateCoachConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
