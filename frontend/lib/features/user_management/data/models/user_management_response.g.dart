// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserManagementResponse _$UserManagementResponseFromJson(
  Map<String, dynamic> json,
) => UserManagementResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserManagementResponseToJson(
  UserManagementResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
