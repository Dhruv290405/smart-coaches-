import 'package:json_annotation/json_annotation.dart';

part 'edit_sensor_device_configuration_response.g.dart';

@JsonSerializable()
class EditSensorDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditSensorDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditSensorDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditSensorDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditSensorDeviceConfigurationResponseToJson(this);
}
