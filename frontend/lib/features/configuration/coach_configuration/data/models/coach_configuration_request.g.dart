// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachConfigurationRequest _$CoachConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _CoachConfigurationRequest(
  entityType: json['entity_type'] as String?,
  coachUniqueId: json['coach_unique_id'] as String?,
  coachDisplayId: json['coach_display_id'] as String?,
  manufacturingYear: json['manufacturing_year'] as String?,
  makeOfCoach: json['make_of_coach'] as String?,
  typeOfCoach: json['type_of_coach'] as String?,
  noOfMasterModule: (json['no_of_master_module'] as num?)?.toInt(),
  coachStatus: json['coach_status'] as String?,
  position: (json['position'] as num?)?.toInt(),
);

Map<String, dynamic> _$CoachConfigurationRequestToJson(
  _CoachConfigurationRequest instance,
) => <String, dynamic>{
  'entity_type': instance.entityType,
  'coach_unique_id': instance.coachUniqueId,
  'coach_display_id': instance.coachDisplayId,
  'manufacturing_year': instance.manufacturingYear,
  'make_of_coach': instance.makeOfCoach,
  'type_of_coach': instance.typeOfCoach,
  'no_of_master_module': instance.noOfMasterModule,
  'coach_status': instance.coachStatus,
  'position': instance.position,
};
