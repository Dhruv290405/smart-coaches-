import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_type_configuration_request.freezed.dart';
part 'sensor_type_configuration_request.g.dart';

@freezed
abstract class SensorTypeConfigurationRequest
    with _$SensorTypeConfigurationRequest {
  const factory SensorTypeConfigurationRequest({
    @JsonKey(name: 'sensor_type_name') String? sensorTypeName,
    @JsonKey(name: 'category') int? category,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'value_format') String? valueFormat,
    @JsonKey(name: 'min_expected_value') int? minExpectedValue,
    @JsonKey(name: 'max_expected_value') int? maxExpectedValue,
    @JsonKey(name: 'sampling_frequency') double? samplingFrequency,
    @JsonKey(name: 'time_interval') String? timeInterval,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'unit_ids') List<int>? unitIds,
    @JsonKey(name: 'device_ids') List<String>? deviceIds,
  }) = _SensorTypeConfigurationRequest;

  factory SensorTypeConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$SensorTypeConfigurationRequestFromJson(json);
}
