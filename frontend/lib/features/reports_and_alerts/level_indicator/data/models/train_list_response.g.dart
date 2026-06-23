// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainListResponseForReport _$TrainListResponseForReportFromJson(
  Map<String, dynamic> json,
) => TrainListResponseForReport(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => TrainItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TrainListResponseForReportToJson(
  TrainListResponseForReport instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CoachListResponseForReport _$CoachListResponseForReportFromJson(
  Map<String, dynamic> json,
) => CoachListResponseForReport(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => BasicCoachItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachListResponseForReportToJson(
  CoachListResponseForReport instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

TrainItem _$TrainItemFromJson(Map<String, dynamic> json) => TrainItem(
  trainNumber: json['train_number'] as String,
  trainName: json['train_name'] as String,
  trainId: (json['train_id'] as num).toInt(),
);

Map<String, dynamic> _$TrainItemToJson(TrainItem instance) => <String, dynamic>{
  'train_number': instance.trainNumber,
  'train_name': instance.trainName,
  'train_id': instance.trainId,
};

BasicCoachItem _$BasicCoachItemFromJson(Map<String, dynamic> json) =>
    BasicCoachItem(
      coach_id: (json['coach_id'] as num).toInt(),
      coach_unique_id: json['coach_unique_id'] as String,
    );

Map<String, dynamic> _$BasicCoachItemToJson(BasicCoachItem instance) =>
    <String, dynamic>{
      'coach_id': instance.coach_id,
      'coach_unique_id': instance.coach_unique_id,
    };

SensorListResponseForReport _$SensorListResponseForReportFromJson(
  Map<String, dynamic> json,
) => SensorListResponseForReport(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => BasicSensorItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorListResponseForReportToJson(
  SensorListResponseForReport instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

BasicSensorItem _$BasicSensorItemFromJson(Map<String, dynamic> json) =>
    BasicSensorItem(
      sensor_config_id: (json['sensor_config_id'] as num).toInt(),
      sensor_id: json['sensor_id'] as String,
      sensor_type_id: (json['sensor_type_id'] as num).toInt(),
    );

Map<String, dynamic> _$BasicSensorItemToJson(BasicSensorItem instance) =>
    <String, dynamic>{
      'sensor_config_id': instance.sensor_config_id,
      'sensor_id': instance.sensor_id,
      'sensor_type_id': instance.sensor_type_id,
    };
