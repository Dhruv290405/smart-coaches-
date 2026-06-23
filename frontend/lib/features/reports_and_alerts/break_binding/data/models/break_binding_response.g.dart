// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'break_binding_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainListResponseForBreakBinding _$TrainListResponseForBreakBindingFromJson(
  Map<String, dynamic> json,
) => TrainListResponseForBreakBinding(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => TrainItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TrainListResponseForBreakBindingToJson(
  TrainListResponseForBreakBinding instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CoachListResponseForBreakBinding _$CoachListResponseForBreakBindingFromJson(
  Map<String, dynamic> json,
) => CoachListResponseForBreakBinding(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => CoachItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoachListResponseForBreakBindingToJson(
  CoachListResponseForBreakBinding instance,
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

CoachItem _$CoachItemFromJson(Map<String, dynamic> json) => CoachItem(
  coachUniqueId: json['coach_unique_id'] as String,
  coachId: (json['coach_id'] as num).toInt(),
);

Map<String, dynamic> _$CoachItemToJson(CoachItem instance) => <String, dynamic>{
  'coach_unique_id': instance.coachUniqueId,
  'coach_id': instance.coachId,
};
