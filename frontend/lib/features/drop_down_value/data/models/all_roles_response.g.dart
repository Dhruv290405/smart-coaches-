// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_roles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllRolesResponse _$AllRolesResponseFromJson(Map<String, dynamic> json) =>
    AllRolesResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RoleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllRolesResponseToJson(AllRolesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
