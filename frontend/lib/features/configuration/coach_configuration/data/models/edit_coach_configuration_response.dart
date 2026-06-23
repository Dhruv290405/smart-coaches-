import 'package:json_annotation/json_annotation.dart';

part 'edit_coach_configuration_response.g.dart';

@JsonSerializable()
class EditCoachConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditCoachConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditCoachConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditCoachConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditCoachConfigurationResponseToJson(this);
}
