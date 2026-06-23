// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_make_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMakeListResponse _$CoachMakeListResponseFromJson(
  Map<String, dynamic> json,
) => CoachMakeListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CoachMakeItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachMakeListResponseToJson(
  CoachMakeListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CoachMakeItem _$CoachMakeItemFromJson(Map<String, dynamic> json) =>
    CoachMakeItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CoachMakeItemToJson(CoachMakeItem instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
