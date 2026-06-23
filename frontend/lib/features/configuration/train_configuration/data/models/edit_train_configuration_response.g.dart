// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_train_configuration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditTrainConfigurationResponse _$EditTrainConfigurationResponseFromJson(
  Map<String, dynamic> json,
) => EditTrainConfigurationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$EditTrainConfigurationResponseToJson(
  EditTrainConfigurationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
