import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_configuration_request.freezed.dart';

part 'device_configuration_request.g.dart';

@freezed
abstract class DeviceConfigurationRequest with _$DeviceConfigurationRequest {
  const factory DeviceConfigurationRequest({
    @JsonKey(name: 'device_unique_id') String? deviceUniqueId,
    @JsonKey(name: 'data_type') String? dataType,
    @JsonKey(name: 'time_unit') String? timeUnit,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'frequency_secs') double? frequency,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'short_name') String? shortName,
    @JsonKey(name: 'no_of_sensors') int? numberOfSensors,
  }) = _DeviceConfigurationRequest;

  factory DeviceConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceConfigurationRequestFromJson(json);
}
