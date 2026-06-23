// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_coach_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditCoachConfigurationResponse _$EditCoachConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => EditCoachConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$EditCoachConfigurationResponseToJson(
  EditCoachConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
