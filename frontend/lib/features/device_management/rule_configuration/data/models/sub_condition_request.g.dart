// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_condition_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubConditionRequest _$SubConditionRequestFromJson(Map<String, dynamic> json) =>
    _SubConditionRequest(
      operator: json['operator'] as String?,
      thresholdValue: json['threshold_value'] as num?,
      connector: json['connector'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubConditionRequestToJson(
  _SubConditionRequest instance,
) => <String, dynamic>{
  'operator': instance.operator,
  'threshold_value': instance.thresholdValue,
  'connector': instance.connector,
  'sort_order': instance.sortOrder,
};
