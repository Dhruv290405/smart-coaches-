import 'package:json_annotation/json_annotation.dart';

part 'delete_sensor_type_configuration_response.g.dart';

@JsonSerializable()
class DeleteSensorTypeConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteSensorTypeConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteSensorTypeConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSensorTypeConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteSensorTypeConfigurationResponseToJson(this);
}
