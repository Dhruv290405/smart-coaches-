import 'package:json_annotation/json_annotation.dart';

part 'delete_sensor_device_configuration_response.g.dart';

@JsonSerializable()
class DeleteSensorDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteSensorDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteSensorDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSensorDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteSensorDeviceConfigurationResponseToJson(this);
}
