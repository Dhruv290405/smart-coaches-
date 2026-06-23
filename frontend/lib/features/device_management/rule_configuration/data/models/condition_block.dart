import 'package:json_annotation/json_annotation.dart';

import 'sub_condition.dart';

part 'condition_block.g.dart';

@JsonSerializable(explicitToJson: true)
class ConditionBlock {
  @JsonKey(name: 'value_type')
  final String? valueType;

  @JsonKey(name: 'value_format')
  final String? valueFormat;

  @JsonKey(name: 'si_unit')
  final String? siUnit;

  @JsonKey(name: 'operator')
  final String? operator;

  @JsonKey(name: 'threshold')
  final String? threshold;

  @JsonKey(name: 'sub_condition_connector')
  final String? subConditionConnector;

  @JsonKey(name: 'sub_conditions')
  final List<SubCondition>? subConditions;

  @JsonKey(name: 'alert_type')
  final String? alertType;

  @JsonKey(name: 'alert_message_template')
  final String? alertMessageTemplate;

  ConditionBlock({
    this.valueType,
    this.valueFormat,
    this.siUnit,
    this.operator,
    this.threshold,
    this.subConditionConnector,
    this.subConditions,
    this.alertType,
    this.alertMessageTemplate,
  });

  factory ConditionBlock.fromJson(Map<String, dynamic> json) =>
      _$ConditionBlockFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionBlockToJson(this);
}
