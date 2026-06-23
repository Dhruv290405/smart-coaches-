// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_train_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTrainConfigurationResponse _$CreateTrainConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => CreateTrainConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$CreateTrainConfigurationResponseToJson(
  CreateTrainConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
