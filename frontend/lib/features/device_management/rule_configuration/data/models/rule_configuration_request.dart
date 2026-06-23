import 'package:freezed_annotation/freezed_annotation.dart';
import 'condition_block_request.dart';
import 'sub_condition_request.dart';

part 'rule_configuration_request.freezed.dart';
part 'rule_configuration_request.g.dart';

@freezed
abstract class RuleConfigurationRequest with _$RuleConfigurationRequest {
  const factory RuleConfigurationRequest({
    @JsonKey(name: 'rule_name') String? ruleName,
    @JsonKey(name: 'evaluation_frequency') String? evaluationFrequency,
    @JsonKey(name: 'evaluation_unit') String? evaluationUnit,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'device_ids') List<String>? deviceIds,
    @JsonKey(name: 'sensor_type_ids') List<int>? sensorTypeIds,
    @JsonKey(name: 'conditions') List<ConditionBlockRequest>? conditions,
  }) = _RuleConfigurationRequest;

  factory RuleConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$RuleConfigurationRequestFromJson(json);
}
