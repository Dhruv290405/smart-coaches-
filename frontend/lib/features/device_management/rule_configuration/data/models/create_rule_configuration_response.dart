import 'package:json_annotation/json_annotation.dart';

part 'create_rule_configuration_response.g.dart';

@JsonSerializable()
class CreateRuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateRuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateRuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateRuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRuleConfigurationResponseToJson(this);
}
