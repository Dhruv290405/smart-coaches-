import 'package:json_annotation/json_annotation.dart';

part 'sensor_category_list_response.g.dart';

@JsonSerializable()
class SensorCategoryListResponse {
  final bool success;
  final String message;
  final List<SensorCategoryItem>? data;

  SensorCategoryListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SensorCategoryListResponse.fromJson(Map<String, dynamic> json) =>
      _$SensorCategoryListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SensorCategoryListResponseToJson(this);
}

@JsonSerializable()
class SensorCategoryItem {
  @JsonKey(name: 'value_type_id')
  final int? valueTypeId;

  final String? name;

  @JsonKey(name: 'base_unit')
  final String? baseUnit;

  SensorCategoryItem({
    this.valueTypeId,
    this.name,
    this.baseUnit,
  });

  factory SensorCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$SensorCategoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$SensorCategoryItemToJson(this);
}
