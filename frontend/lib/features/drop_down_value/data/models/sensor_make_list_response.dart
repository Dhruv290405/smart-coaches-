import 'package:json_annotation/json_annotation.dart';

part 'sensor_make_list_response.g.dart';

@JsonSerializable()
class SensorMakeListResponse {
  final bool success;
  final String message;
  final List<SensorMakeItem>? data;

  SensorMakeListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SensorMakeListResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorMakeListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorMakeListResponseToJson(this);
}

@JsonSerializable()
class SensorMakeItem {
  @JsonKey(name: 'sensor_make_id')
  final int? sensorMakeId;

  @JsonKey(name: 'make_name')
  final String? name;

  SensorMakeItem({
    this.sensorMakeId,
    this.name,
  });

  factory SensorMakeItem.fromJson(Map<String, dynamic> json) =>
      _$SensorMakeItemFromJson(json);

  Map<String, dynamic> toJson() => _$SensorMakeItemToJson(this);
}