// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_types_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachTypeListResponse _$CoachTypeListResponseFromJson(
  Map<String, dynamic> json,
) => CoachTypeListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CoachTypeItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachTypeListResponseToJson(
  CoachTypeListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CoachTypeItem _$CoachTypeItemFromJson(Map<String, dynamic> json) =>
    CoachTypeItem(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CoachTypeItemToJson(CoachTypeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
