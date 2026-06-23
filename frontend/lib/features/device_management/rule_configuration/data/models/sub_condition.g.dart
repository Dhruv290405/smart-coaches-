// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubCondition _$SubConditionFromJson(Map<String, dynamic> json) => SubCondition(
  operator: json['operator'] as String?,
  threshold: json['threshold'] as String?,
);

Map<String, dynamic> _$SubConditionToJson(SubCondition instance) =>
    <String, dynamic>{
      'operator': instance.operator,
      'threshold': instance.threshold,
    };
