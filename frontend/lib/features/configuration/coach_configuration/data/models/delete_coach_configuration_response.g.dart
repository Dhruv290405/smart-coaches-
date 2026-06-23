// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_coach_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteCoachConfigurationResponse _$DeleteCoachConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => DeleteCoachConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$DeleteCoachConfigurationResponseToJson(
  DeleteCoachConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
