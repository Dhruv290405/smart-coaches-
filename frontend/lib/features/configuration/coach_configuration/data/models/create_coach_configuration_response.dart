import 'package:json_annotation/json_annotation.dart';

part 'create_coach_configuration_response.g.dart';

@JsonSerializable()
class CreateCoachConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateCoachConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateCoachConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateCoachConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCoachConfigurationResponseToJson(this);
}
