import 'package:json_annotation/json_annotation.dart';

part 'region_list_response.g.dart';

@JsonSerializable()
class RegionListResponse {
  final bool success;
  final String message;
  final RegionListData? data;

  RegionListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RegionListResponse.fromJson(Map<String, dynamic> json) =>
      _$RegionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegionListResponseToJson(this);
}

@JsonSerializable()
class RegionListData {
  final List<RegionItem>? items;
  final Pagination? pagination;

  RegionListData({
    required this.items,
    required this.pagination,
  });

  factory RegionListData.fromJson(Map<String, dynamic> json) =>
      _$RegionListDataFromJson(json);

  Map<String, dynamic> toJson() => _$RegionListDataToJson(this);
}

@JsonSerializable()
class RegionItem {
  @JsonKey(name: 'region_id')
  final int? regionId;

  final String? name;

  @JsonKey(name: 'division_id')
  final int? divisionId;

  @JsonKey(name: 'is_active')
  final int? isActive;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'updated_date')
  final String? updatedDate;

  RegionItem({
    this.regionId,
    this.name,
    this.divisionId,
    this.isActive,
    this.createdDate,
    this.updatedDate,
  });

  factory RegionItem.fromJson(Map<String, dynamic> json) =>
      _$RegionItemFromJson(json);

  Map<String, dynamic> toJson() => _$RegionItemToJson(this);
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
