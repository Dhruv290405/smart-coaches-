import 'package:json_annotation/json_annotation.dart';

part 'si_unit_list_response.g.dart';

@JsonSerializable()
class SiUnitListResponse {
  final bool success;
  final String message;
  final List<SiUnitItem>? data;

  SiUnitListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SiUnitListResponse.fromJson(Map<String, dynamic> json) =>
      _$SiUnitListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SiUnitListResponseToJson(this);
}

@JsonSerializable()
class SiUnitItem {
  @JsonKey(name: 'unit_id')
  final int? unitId;

  final String? unit;

  @JsonKey(name: 'is_base_unit')
  final int? isBaseUnit;

  SiUnitItem({
    this.unitId,
    this.unit,
    this.isBaseUnit,
  });

  factory SiUnitItem.fromJson(Map<String, dynamic> json) =>
      _$SiUnitItemFromJson(json);

  Map<String, dynamic> toJson() => _$SiUnitItemToJson(this);
}
