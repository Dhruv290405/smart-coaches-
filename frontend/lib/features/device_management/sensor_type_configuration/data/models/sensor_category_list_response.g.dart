// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_category_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorCategoryListResponse _$SensorCategoryListResponseFromJson(
  Map<String, dynamic> json,
) => SensorCategoryListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => SensorCategoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SensorCategoryListResponseToJson(
  SensorCategoryListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

SensorCategoryItem _$SensorCategoryItemFromJson(Map<String, dynamic> json) =>
    SensorCategoryItem(
      valueTypeId: (json['value_type_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      baseUnit: json['base_unit'] as String?,
    );

Map<String, dynamic> _$SensorCategoryItemToJson(SensorCategoryItem instance) =>
    <String, dynamic>{
      'value_type_id': instance.valueTypeId,
      'name': instance.name,
      'base_unit': instance.baseUnit,
    };
