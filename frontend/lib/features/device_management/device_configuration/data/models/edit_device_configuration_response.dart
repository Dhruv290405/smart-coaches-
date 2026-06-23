import 'package:json_annotation/json_annotation.dart';

part 'edit_device_configuration_response.g.dart';

@JsonSerializable()
class EditDeviceConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditDeviceConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditDeviceConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditDeviceConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditDeviceConfigurationResponseToJson(this);
}
