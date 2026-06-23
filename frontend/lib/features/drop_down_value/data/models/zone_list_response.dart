import 'package:json_annotation/json_annotation.dart';

part 'zone_list_response.g.dart';

@JsonSerializable()
class ZoneListResponse {
  final bool success;
  final String message;

  /// Make `data` optional
  final ZoneListData? data;

  ZoneListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ZoneListResponse.fromJson(Map<String, dynamic> json) =>
      _$ZoneListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneListResponseToJson(this);
}


@JsonSerializable()
class ZoneListData {
  final List<ZoneItem> items;
  final Pagination? pagination;

  ZoneListData({
    required this.items,
    required this.pagination,
  });

  factory ZoneListData.fromJson(Map<String, dynamic> json) =>
      _$ZoneListDataFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneListDataToJson(this);
}

@JsonSerializable()
class ZoneItem {
  @JsonKey(name: 'zone_id')
  final int? zoneId;

  final String? name;
  final String? headquarters;

  @JsonKey(name: 'zone_code')
  final String? zoneCode;

  @JsonKey(name: 'is_active')
  final int? isActive;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  ZoneItem({
    this.zoneId,
    this.name,
    this.headquarters,
    this.zoneCode,
    this.isActive,
    this.createdDate,
  });

  factory ZoneItem.fromJson(Map<String, dynamic> json) =>
      _$ZoneItemFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneItemToJson(this);
}

@JsonSerializable()
class Pagination {
  final int total;
  final int page;
  final int limit;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
