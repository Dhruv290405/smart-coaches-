// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_make_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorMakeListResponse _$SensorMakeListResponseFromJson(
  Map<String, dynamic> json,
) => SensorMakeListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => SensorMakeItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorMakeListResponseToJson(
  SensorMakeListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

SensorMakeItem _$SensorMakeItemFromJson(Map<String, dynamic> json) =>
    SensorMakeItem(
      sensorMakeId: (json['sensor_make_id'] as num?)?.toInt(),
      name: json['make_name'] as String?,
    );

Map<String, dynamic> _$SensorMakeItemToJson(SensorMakeItem instance) =>
    <String, dynamic>{
      'sensor_make_id': instance.sensorMakeId,
      'make_name': instance.name,
    };
