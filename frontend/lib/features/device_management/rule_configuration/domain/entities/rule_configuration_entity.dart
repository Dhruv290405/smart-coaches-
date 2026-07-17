import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rules_list_response.dart';

class RuleConfigurationEntity {
  final int? ruleId;
  final String? ruleName;
  final List<String> deviceNames;
  final List<String> deviceIds;
  final List<String> sensorTypeNames;
  final List<int> sensorTypeIds;
  final int? evaluationFrequency;
  final String? evaluationUnit;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final List<ConditionBlockEntity> conditions;
  final bool? isActive;

  RuleConfigurationEntity({
    this.ruleId,
    this.ruleName,
    this.deviceNames = const [],
    this.deviceIds = const <String>[],
    this.sensorTypeNames = const [],
    this.sensorTypeIds = const [],
    this.evaluationFrequency,
    this.evaluationUnit,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.conditions = const [],
    this.isActive,
  });

  factory RuleConfigurationEntity.fromModel(RuleItem model) {
    return RuleConfigurationEntity(
      ruleId: model.ruleId,
      ruleName: model.ruleName,
      deviceNames: model.devices?.map((e) => e.name ?? '').toList() ?? [],
      deviceIds: model.devices?.map((e) => e.deviceId).where((id) => id != null).cast<String>().toList() ?? [],
      sensorTypeNames:
          model.sensorTypes?.map((e) => e.name ?? '').toList() ?? [],
      sensorTypeIds:
          model.sensorTypes?.map((e) => e.sensorTypeId ?? -1).toList() ?? [],
      evaluationFrequency: model.evaluationFrequency,
      evaluationUnit: Utils.normalizeDropDownValue(model.evaluationUnit, Constants.evaluationUnitValues),
      createdBy: model.createdBy,
      updatedBy: model.updatedBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      conditions: model.conditions
              ?.map((c) => ConditionBlockEntity.fromModel(c))
              .toList() ??
          [],
      isActive: model.isActive,
    );
  }
}

class ConditionBlockEntity {
  final String? valueType;
  final String? valueFormat;
  final String? connector;
  final String? siUnit;
  final String? operator;
  final int? threshold;
  final List<SubConditionEntity> subConditions;
  final String? alertType;
  final String? alertMessageTemplate;
  final String? alertDescription;
  final int? valueTypeId;
  final int? unitId;
  final int? alertTypeId;

  ConditionBlockEntity({
    this.valueType,
    this.valueFormat,
    this.connector,
    this.siUnit,
    this.operator,
    this.threshold,
    this.subConditions = const [],
    this.alertType,
    this.alertMessageTemplate,
    this.alertDescription,
    this.valueTypeId,
    this.unitId,
    this.alertTypeId,
  });

  factory ConditionBlockEntity.fromModel(ConditionItem model) {
    final List<SubConditionItem> sortedSubs = model.subConditions ?? [];

    // Sort by sort_order
    sortedSubs.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

    return ConditionBlockEntity(
      valueFormat: Utils.normalizeDropDownValue(model.valueFormat, Constants.valueFormats),
      connector: Utils.normalizeDropDownValue(model.connector, Constants.conditionConnectors),
      valueType: model.valueType,
      siUnit: model.unit,
      operator: sortedSubs.isNotEmpty ? sortedSubs.first.operator : null,
      threshold: sortedSubs.isNotEmpty ? sortedSubs.first.thresholdValue : null,
      subConditions: sortedSubs
          .skip(1) // rest are treated as sub-conditions
          .map((e) => SubConditionEntity.fromModel(e))
          .toList(),
      alertType: model.alertType,
      alertMessageTemplate: model.alertMessageTemplate?.title,
      alertDescription: model.alertMessageTemplate?.body,
      valueTypeId: model.valueTypeId,
      unitId: model.unitId,
      alertTypeId: model.alertTypeId,
    );
  }
}

class SubConditionEntity {
  final String? operator;
  final int? threshold;
  final String? connector;
  final int? sortOrder;

  SubConditionEntity({
    this.operator,
    this.threshold,
    this.connector,
    this.sortOrder,
  });

  factory SubConditionEntity.fromModel(SubConditionItem model) {
    return SubConditionEntity(
      operator: model.operator,
      threshold: model.thresholdValue,
      connector: model.connector,
      sortOrder: model.sortOrder,
    );
  }
}
