import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_message_template_request.dart';
import 'sub_condition_request.dart';

part 'condition_block_request.freezed.dart';
part 'condition_block_request.g.dart';

@freezed
abstract class ConditionBlockRequest with _$ConditionBlockRequest {
  const factory ConditionBlockRequest({
    @JsonKey(name: 'value_type_id') int? valueTypeId,
    @JsonKey(name: 'value_format') String? valueFormat,
    @JsonKey(name: 'si_unit_id') int? siUnitId,
    @JsonKey(name: 'alert_type_id') int? alertTypeId,
    @JsonKey(name: 'alert_message_template') AlertMessageTemplateRequest? alertMessageTemplate,
    @JsonKey(name: 'connector') String? connector,
    @JsonKey(name: 'sub_conditions') List<SubConditionRequest>? subConditions,
  }) = _ConditionBlockRequest;

  factory ConditionBlockRequest.fromJson(Map<String, dynamic> json) =>
      _$ConditionBlockRequestFromJson(json);
}
