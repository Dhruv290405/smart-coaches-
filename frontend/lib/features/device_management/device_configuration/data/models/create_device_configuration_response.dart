import 'package:json_annotation/json_annotation.dart';

part 'create_device_configuration_response.g.dart';

@JsonSerializable()
class CreateDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDeviceConfigurationResponseToJson(this);
}
