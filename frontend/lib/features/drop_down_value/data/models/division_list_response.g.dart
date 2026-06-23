// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'division_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivisionListResponse _$DivisionListResponseFromJson(
  Map<String, dynamic> json,
) => DivisionListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : DivisionListData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DivisionListResponseToJson(
  DivisionListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

DivisionListData _$DivisionListDataFromJson(Map<String, dynamic> json) =>
    DivisionListData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => DivisionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DivisionListDataToJson(DivisionListData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

DivisionItem _$DivisionItemFromJson(Map<String, dynamic> json) => DivisionItem(
  divisionId: (json['division_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  zoneId: (json['zone_id'] as num?)?.toInt(),
  isActive: (json['is_active'] as num?)?.toInt(),
  createdDate: json['created_date'] as String?,
  updatedDate: json['updated_date'] as String?,
);

Map<String, dynamic> _$DivisionItemToJson(DivisionItem instance) =>
    <String, dynamic>{
      'division_id': instance.divisionId,
      'name': instance.name,
      'zone_id': instance.zoneId,
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
