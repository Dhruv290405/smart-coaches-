import 'package:json_annotation/json_annotation.dart';

part 'edit_rule_configuration_response.g.dart';

@JsonSerializable()
class EditRuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditRuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditRuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditRuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditRuleConfigurationResponseToJson(this);
}
