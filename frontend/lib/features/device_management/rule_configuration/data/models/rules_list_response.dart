import 'package:json_annotation/json_annotation.dart';

part 'rules_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class RulesListResponse {
  final bool success;
  final String message;
  final List<RuleItem>? data;

  RulesListResponse({required this.success, required this.message, this.data});

  factory RulesListResponse.fromJson(Map<String, dynamic> json) =>
      _$RulesListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RulesListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RuleItem {
  @JsonKey(name: 'rule_id')
  final int? ruleId;

  @JsonKey(name: 'rule_name')
  final String? ruleName;

  @JsonKey(name: 'evaluation_frequency')
  final int? evaluationFrequency;

  @JsonKey(name: 'evaluation_unit')
  final String? evaluationUnit;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'devices')
  final List<DeviceItem>? devices;

  @JsonKey(name: 'sensor_types')
  final List<SensorTypeItem>? sensorTypes;

  @JsonKey(name: 'conditions')
  final List<ConditionItem>? conditions;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  RuleItem({
    this.ruleId,
    this.ruleName,
    this.evaluationFrequency,
    this.evaluationUnit,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.devices,
    this.sensorTypes,
    this.conditions,
    this.isActive,
  });

  factory RuleItem.fromJson(Map<String, dynamic> json) =>
      _$RuleItemFromJson(json);

  Map<String, dynamic> toJson() => _$RuleItemToJson(this);
}

@JsonSerializable()
class DeviceItem {
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'device_unique_id')
  final String? deviceUniqueId;

  @JsonKey(name: 'name')
  final String? name;

  DeviceItem({this.deviceId, this.deviceUniqueId, this.name});

  factory DeviceItem.fromJson(Map<String, dynamic> json) =>
      _$DeviceItemFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceItemToJson(this);
}

@JsonSerializable()
class SensorTypeItem {
  @JsonKey(name: 'sensor_type_id')
  final int? sensorTypeId;

  @JsonKey(name: 'name')
  final String? name;

  SensorTypeItem({this.sensorTypeId, this.name});

  factory SensorTypeItem.fromJson(Map<String, dynamic> json) =>
      _$SensorTypeItemFromJson(json);

  Map<String, dynamic> toJson() => _$SensorTypeItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConditionItem {
  @JsonKey(name: 'condition_id')
  final int? conditionId;

  @JsonKey(name: 'value_type')
  final String? valueType;

  @JsonKey(name: 'value_format')
  final String? valueFormat;
  @JsonKey(name: 'connector')
  final String? connector;

  @JsonKey(name: 'unit')
  final String? unit;

  @JsonKey(name: 'alert_type')
  final String? alertType;

  @JsonKey(name: 'alert_message_template')
  final AlertMessageTemplate? alertMessageTemplate;

  @JsonKey(name: 'condition_expression')
  final String? conditionExpression;

  @JsonKey(name: 'sub_conditions')
  final List<SubConditionItem>? subConditions;
  @JsonKey(name: 'value_type_id')
  final int? valueTypeId;
  @JsonKey(name: 'unit_id')
  final int? unitId;
  @JsonKey(name: 'alert_type_id')
  final int? alertTypeId;

  ConditionItem({
    this.conditionId,
    this.valueType,
    this.valueFormat,
    this.connector,
    this.unit,
    this.alertType,
    this.alertMessageTemplate,
    this.conditionExpression,
    this.subConditions,
    this.valueTypeId,
    this.unitId,
    this.alertTypeId,
  });

  factory ConditionItem.fromJson(Map<String, dynamic> json) =>
      _$ConditionItemFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionItemToJson(this);
}

@JsonSerializable()
class SubConditionItem {
  @JsonKey(name: 'operator')
  final String? operator;

  @JsonKey(name: 'threshold_value')
  final int? thresholdValue;

  @JsonKey(name: 'connector')
  final String? connector;

  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  SubConditionItem({
    this.operator,
    this.thresholdValue,
    this.connector,
    this.sortOrder,
  });

  factory SubConditionItem.fromJson(Map<String, dynamic> json) =>
      _$SubConditionItemFromJson(json);

  Map<String, dynamic> toJson() => _$SubConditionItemToJson(this);
}

@JsonSerializable()
class AlertMessageTemplate {
  final String? title;
  final String? body;
  final String? level;

  AlertMessageTemplate({this.title, this.body, this.level});

  factory AlertMessageTemplate.fromJson(Map<String, dynamic> json) =>
      _$AlertMessageTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$AlertMessageTemplateToJson(this);
}
