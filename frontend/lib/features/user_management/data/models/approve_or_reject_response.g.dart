// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approve_or_reject_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApproveOrRejectResponse _$ApproveOrRejectResponseFromJson(
  Map<String, dynamic> json,
) => ApproveOrRejectResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$ApproveOrRejectResponseToJson(
  ApproveOrRejectResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
