// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneListResponse _$ZoneListResponseFromJson(Map<String, dynamic> json) =>
    ZoneListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : ZoneListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ZoneListResponseToJson(ZoneListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ZoneListData _$ZoneListDataFromJson(Map<String, dynamic> json) => ZoneListData(
  items: (json['items'] as List<dynamic>)
      .map((e) => ZoneItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ZoneListDataToJson(ZoneListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

ZoneItem _$ZoneItemFromJson(Map<String, dynamic> json) => ZoneItem(
  zoneId: (json['zone_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  headquarters: json['headquarters'] as String?,
  zoneCode: json['zone_code'] as String?,
  isActive: (json['is_active'] as num?)?.toInt(),
  createdDate: json['created_date'] as String?,
);

Map<String, dynamic> _$ZoneItemToJson(ZoneItem instance) => <String, dynamic>{
  'zone_id': instance.zoneId,
  'name': instance.name,
  'headquarters': instance.headquarters,
  'zone_code': instance.zoneCode,
  'is_active': instance.isActive,
  'created_date': instance.createdDate,
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
