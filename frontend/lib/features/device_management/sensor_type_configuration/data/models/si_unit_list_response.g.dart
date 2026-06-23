// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'si_unit_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiUnitListResponse _$SiUnitListResponseFromJson(Map<String, dynamic> json) =>
    SiUnitListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SiUnitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SiUnitListResponseToJson(SiUnitListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SiUnitItem _$SiUnitItemFromJson(Map<String, dynamic> json) => SiUnitItem(
  unitId: (json['unit_id'] as num?)?.toInt(),
  unit: json['unit'] as String?,
  isBaseUnit: (json['is_base_unit'] as num?)?.toInt(),
);

Map<String, dynamic> _$SiUnitItemToJson(SiUnitItem instance) =>
    <String, dynamic>{
      'unit_id': instance.unitId,
      'unit': instance.unit,
      'is_base_unit': instance.isBaseUnit,
    };
