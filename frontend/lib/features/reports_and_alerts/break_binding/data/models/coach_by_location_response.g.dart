// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_by_location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachByLocationResponse _$CoachByLocationResponseFromJson(
  Map<String, dynamic> json,
) => CoachByLocationResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  count: (json['count'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CoachByLocationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachByLocationResponseToJson(
  CoachByLocationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'count': instance.count,
  'data': instance.data,
};

CoachByLocationItem _$CoachByLocationItemFromJson(Map<String, dynamic> json) =>
    CoachByLocationItem(
      id: (json['id'] as num?)?.toInt(),
      technicalId: json['technical_id'],
      coachNo: json['coach_no'],
      deviceId: json['device_id'],
      trainNo: json['Train_no'],
      location: json['Location'],
      actualId: json['Actual_id'],
    );

Map<String, dynamic> _$CoachByLocationItemToJson(
  CoachByLocationItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'technical_id': instance.technicalId,
  'coach_no': instance.coachNo,
  'device_id': instance.deviceId,
  'Train_no': instance.trainNo,
  'Location': instance.location,
  'Actual_id': instance.actualId,
};
