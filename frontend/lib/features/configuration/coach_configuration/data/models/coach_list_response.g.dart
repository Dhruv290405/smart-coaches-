// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachListResponse _$CoachListResponseFromJson(Map<String, dynamic> json) =>
    CoachListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CoachItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoachListResponseToJson(CoachListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

CoachItem _$CoachItemFromJson(Map<String, dynamic> json) => CoachItem(
  coachId: json['coach_id'],
  coachUniqueId: json['coach_unique_id'] as String?,
  coachDisplayId: json['coach_display_id'] as String?,
  position: json['position'],
  createdByName: json['created_by_name'] as String?,
  updatedByName: json['updated_by_name'] as String?,
  manufacturingYear: json['manufacturing_year'],
  entityType: json['entity_type'] as String?,
  makeOfCoachName: json['make_of_coach_name'] as String?,
  makeOfCoachId: json['make_of_coach_id'],
  typeOfCoachCode: json['type_of_coach_code'] as String?,
  typeOfCoachId: json['type_of_coach_id'],
  noOfMasterModule: json['no_of_master_module'],
  coachStatus: json['coach_status'] as String?,
  createdAt: json['created_date'] as String?,
  updatedAt: json['updated_date'] as String?,
);

Map<String, dynamic> _$CoachItemToJson(CoachItem instance) => <String, dynamic>{
  'coach_id': instance.coachId,
  'coach_unique_id': instance.coachUniqueId,
  'coach_display_id': instance.coachDisplayId,
  'position': instance.position,
  'no_of_master_module': instance.noOfMasterModule,
  'coach_status': instance.coachStatus,
  'entity_type': instance.entityType,
  'manufacturing_year': instance.manufacturingYear,
  'created_by_name': instance.createdByName,
  'created_date': instance.createdAt,
  'updated_by_name': instance.updatedByName,
  'updated_date': instance.updatedAt,
  'make_of_coach_name': instance.makeOfCoachName,
  'make_of_coach_id': instance.makeOfCoachId,
  'type_of_coach_code': instance.typeOfCoachCode,
  'type_of_coach_id': instance.typeOfCoachId,
};
