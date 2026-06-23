import 'package:json_annotation/json_annotation.dart';

part 'edit_sensor_type_configuration_response.g.dart';

@JsonSerializable()
class EditSensorTypeConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditSensorTypeConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditSensorTypeConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditSensorTypeConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditSensorTypeConfigurationResponseToJson(this);
}
