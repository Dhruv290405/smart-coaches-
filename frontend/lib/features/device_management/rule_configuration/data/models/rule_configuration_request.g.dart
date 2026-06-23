// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RuleConfigurationRequest _$RuleConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _RuleConfigurationRequest(
  ruleName: json['rule_name'] as String?,
  evaluationFrequency: json['evaluation_frequency'] as String?,
  evaluationUnit: json['evaluation_unit'] as String?,
  isActive: json['is_active'] as bool?,
  deviceIds: (json['device_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sensorTypeIds: (json['sensor_type_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  conditions: (json['conditions'] as List<dynamic>?)
      ?.map((e) => ConditionBlockRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RuleConfigurationRequestToJson(
  _RuleConfigurationRequest instance,
) => <String, dynamic>{
  'rule_name': instance.ruleName,
  'evaluation_frequency': instance.evaluationFrequency,
  'evaluation_unit': instance.evaluationUnit,
  'is_active': instance.isActive,
  'device_ids': instance.deviceIds,
  'sensor_type_ids': instance.sensorTypeIds,
  'conditions': instance.conditions,
};
