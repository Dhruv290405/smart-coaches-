import 'package:json_annotation/json_annotation.dart';

part 'delete_rule_configuration_response.g.dart';

@JsonSerializable()
class DeleteRuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteRuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteRuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteRuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteRuleConfigurationResponseToJson(this);
}
