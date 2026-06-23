import 'package:json_annotation/json_annotation.dart';

part 'delete_coach_configuration_response.g.dart';

@JsonSerializable()
class DeleteCoachConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteCoachConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteCoachConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteCoachConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteCoachConfigurationResponseToJson(this);
}
