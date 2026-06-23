// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_train_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteTrainConfigurationResponse _$DeleteTrainConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => DeleteTrainConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$DeleteTrainConfigurationResponseToJson(
  DeleteTrainConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
