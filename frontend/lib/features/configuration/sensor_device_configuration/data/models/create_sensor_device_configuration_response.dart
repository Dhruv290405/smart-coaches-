import 'package:json_annotation/json_annotation.dart';

part 'create_sensor_device_configuration_response.g.dart';

@JsonSerializable()
class CreateSensorDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateSensorDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateSensorDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSensorDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSensorDeviceConfigurationResponseToJson(this);
}
