// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionListResponse _$RegionListResponseFromJson(Map<String, dynamic> json) =>
    RegionListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : RegionListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegionListResponseToJson(RegionListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RegionListData _$RegionListDataFromJson(Map<String, dynamic> json) =>
    RegionListData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegionListDataToJson(RegionListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

RegionItem _$RegionItemFromJson(Map<String, dynamic> json) => RegionItem(
  regionId: (json['region_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  divisionId: (json['division_id'] as num?)?.toInt(),
  isActive: (json['is_active'] as num?)?.toInt(),
  createdDate: json['created_date'] as String?,
  updatedDate: json['updated_date'] as String?,
);

Map<String, dynamic> _$RegionItemToJson(RegionItem instance) =>
    <String, dynamic>{
      'region_id': instance.regionId,
      'name': instance.name,
      'division_id': instance.divisionId,
      'is_active': instance.isActive,
      'created_date': instance.createdDate,
      'updated_date': instance.updatedDate,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };
