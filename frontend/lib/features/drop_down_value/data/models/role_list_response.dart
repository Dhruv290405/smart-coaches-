import 'package:json_annotation/json_annotation.dart';

part 'role_list_response.g.dart';

@JsonSerializable()
class RoleListResponse {
  final bool success;
  final String message;
  final RoleListData? data;

  RoleListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RoleListResponse.fromJson(Map<String, dynamic> json) =>
      _$RoleListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoleListResponseToJson(this);
}

@JsonSerializable()
class RoleListData {
  final List<RoleItem>? items;
  final Pagination? pagination;

  RoleListData({
    required this.items,
    required this.pagination,
  });

  factory RoleListData.fromJson(Map<String, dynamic> json) =>
      _$RoleListDataFromJson(json);

  Map<String, dynamic> toJson() => _$RoleListDataToJson(this);
}

@JsonSerializable()
class RoleItem {
  @JsonKey(name: 'role_id')
  final int? roleId;

  final String? name;

  @JsonKey(name: 'is_active')
  final int? isActive;

  final String? scope;

  RoleItem({
    this.roleId,
    this.name,
    this.isActive,
    this.scope,
  });

  factory RoleItem.fromJson(Map<String, dynamic> json) =>
      _$RoleItemFromJson(json);

  Map<String, dynamic> toJson() => _$RoleItemToJson(this);
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