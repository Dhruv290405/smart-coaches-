import 'package:json_annotation/json_annotation.dart';

part 'create_sensor_type_configuration_response.g.dart';

@JsonSerializable()
class CreateSensorTypeConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateSensorTypeConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateSensorTypeConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSensorTypeConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSensorTypeConfigurationResponseToJson(this);
}
