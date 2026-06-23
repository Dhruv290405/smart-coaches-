// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RulesListResponse _$RulesListResponseFromJson(Map<String, dynamic> json) =>
    RulesListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RuleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RulesListResponseToJson(RulesListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

RuleItem _$RuleItemFromJson(Map<String, dynamic> json) => RuleItem(
  ruleId: (json['rule_id'] as num?)?.toInt(),
  ruleName: json['rule_name'] as String?,
  evaluationFrequency: (json['evaluation_frequency'] as num?)?.toInt(),
  evaluationUnit: json['evaluation_unit'] as String?,
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  devices: (json['devices'] as List<dynamic>?)
      ?.map((e) => DeviceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  sensorTypes: (json['sensor_types'] as List<dynamic>?)
      ?.map((e) => SensorTypeItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  conditions: (json['conditions'] as List<dynamic>?)
      ?.map((e) => ConditionItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$RuleItemToJson(RuleItem instance) => <String, dynamic>{
  'rule_id': instance.ruleId,
  'rule_name': instance.ruleName,
  'evaluation_frequency': instance.evaluationFrequency,
  'evaluation_unit': instance.evaluationUnit,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'devices': instance.devices?.map((e) => e.toJson()).toList(),
  'sensor_types': instance.sensorTypes?.map((e) => e.toJson()).toList(),
  'conditions': instance.conditions?.map((e) => e.toJson()).toList(),
  'is_active': instance.isActive,
};

DeviceItem _$DeviceItemFromJson(Map<String, dynamic> json) => DeviceItem(
  deviceId: json['device_id'] as String?,
  deviceUniqueId: json['device_unique_id'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$DeviceItemToJson(DeviceItem instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'device_unique_id': instance.deviceUniqueId,
      'name': instance.name,
    };

SensorTypeItem _$SensorTypeItemFromJson(Map<String, dynamic> json) =>
    SensorTypeItem(
      sensorTypeId: (json['sensor_type_id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$SensorTypeItemToJson(SensorTypeItem instance) =>
    <String, dynamic>{
      'sensor_type_id': instance.sensorTypeId,
      'name': instance.name,
    };

ConditionItem _$ConditionItemFromJson(Map<String, dynamic> json) =>
    ConditionItem(
      conditionId: (json['condition_id'] as num?)?.toInt(),
      valueType: json['value_type'] as String?,
      valueFormat: json['value_format'] as String?,
      connector: json['connector'] as String?,
      unit: json['unit'] as String?,
      alertType: json['alert_type'] as String?,
      alertMessageTemplate: json['alert_message_template'] == null
          ? null
          : AlertMessageTemplate.fromJson(
              json['alert_message_template'] as Map<String, dynamic>,
            ),
      conditionExpression: json['condition_expression'] as String?,
      subConditions: (json['sub_conditions'] as List<dynamic>?)
          ?.map((e) => SubConditionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      valueTypeId: (json['value_type_id'] as num?)?.toInt(),
      unitId: (json['unit_id'] as num?)?.toInt(),
      alertTypeId: (json['alert_type_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConditionItemToJson(ConditionItem instance) =>
    <String, dynamic>{
      'condition_id': instance.conditionId,
      'value_type': instance.valueType,
      'value_format': instance.valueFormat,
      'connector': instance.connector,
      'unit': instance.unit,
      'alert_type': instance.alertType,
      'alert_message_template': instance.alertMessageTemplate?.toJson(),
      'condition_expression': instance.conditionExpression,
      'sub_conditions': instance.subConditions?.map((e) => e.toJson()).toList(),
      'value_type_id': instance.valueTypeId,
      'unit_id': instance.unitId,
      'alert_type_id': instance.alertTypeId,
    };

SubConditionItem _$SubConditionItemFromJson(Map<String, dynamic> json) =>
    SubConditionItem(
      operator: json['operator'] as String?,
      thresholdValue: (json['threshold_value'] as num?)?.toInt(),
      connector: json['connector'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubConditionItemToJson(SubConditionItem instance) =>
    <String, dynamic>{
      'operator': instance.operator,
      'threshold_value': instance.thresholdValue,
      'connector': instance.connector,
      'sort_order': instance.sortOrder,
    };

AlertMessageTemplate _$AlertMessageTemplateFromJson(
  Map<String, dynamic> json,
) => AlertMessageTemplate(
  title: json['title'] as String?,
  body: json['body'] as String?,
  level: json['level'] as String?,
);

Map<String, dynamic> _$AlertMessageTemplateToJson(
  AlertMessageTemplate instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'level': instance.level,
};
