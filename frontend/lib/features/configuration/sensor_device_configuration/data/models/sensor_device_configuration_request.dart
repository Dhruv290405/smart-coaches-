import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_device_configuration_request.freezed.dart';
part 'sensor_device_configuration_request.g.dart';

@freezed
abstract class SensorDeviceConfigurationRequest with _$SensorDeviceConfigurationRequest {
  const factory SensorDeviceConfigurationRequest({
    @JsonKey(name: 'coach_id') int? coachId,
    @JsonKey(name: 'master_module_id') int? masterModuleId,
    @JsonKey(name: 'device_id') String? deviceId,
    @JsonKey(name: 'sensors') List<SensorRequest>? sensors,
  }) = _SensorDeviceConfigurationRequest;

  factory SensorDeviceConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$SensorDeviceConfigurationRequestFromJson(json);
}

@freezed
abstract class SensorRequest with _$SensorRequest {
  const factory SensorRequest({
    @JsonKey(name: 'sensor_id') String? sensorId,
    @JsonKey(name: 'sensor_make_id') int? sensorMakeId,
    @JsonKey(name: 'install_date') String? installDate,
    @JsonKey(name: 'placement') String? placement,
    @JsonKey(name: 'location') String? location,
    @JsonKey(name: 'remarks') String? remarks,
  }) = _SensorRequest;

  factory SensorRequest.fromJson(Map<String, dynamic> json) =>
      _$SensorRequestFromJson(json);
}