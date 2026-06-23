import 'package:json_annotation/json_annotation.dart';

part 'delete_device_configuration_response.g.dart';

@JsonSerializable()
class DeleteDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteDeviceConfigurationResponseToJson(this);
}
