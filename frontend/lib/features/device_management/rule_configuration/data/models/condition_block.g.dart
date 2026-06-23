// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConditionBlock _$ConditionBlockFromJson(Map<String, dynamic> json) =>
    ConditionBlock(
      valueType: json['value_type'] as String?,
      valueFormat: json['value_format'] as String?,
      siUnit: json['si_unit'] as String?,
      operator: json['operator'] as String?,
      threshold: json['threshold'] as String?,
      subConditionConnector: json['sub_condition_connector'] as String?,
      subConditions: (json['sub_conditions'] as List<dynamic>?)
          ?.map((e) => SubCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      alertType: json['alert_type'] as String?,
      alertMessageTemplate: json['alert_message_template'] as String?,
    );

Map<String, dynamic> _$ConditionBlockToJson(ConditionBlock instance) =>
    <String, dynamic>{
      'value_type': instance.valueType,
      'value_format': instance.valueFormat,
      'si_unit': instance.siUnit,
      'operator': instance.operator,
      'threshold': instance.threshold,
      'sub_condition_connector': instance.subConditionConnector,
      'sub_conditions': instance.subConditions?.map((e) => e.toJson()).toList(),
      'alert_type': instance.alertType,
      'alert_message_template': instance.alertMessageTemplate,
    };
