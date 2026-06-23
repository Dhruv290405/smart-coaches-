// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StationListResponse _$StationListResponseFromJson(Map<String, dynamic> json) =>
    StationListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : StationListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StationListResponseToJson(
  StationListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

StationListData _$StationListDataFromJson(Map<String, dynamic> json) =>
    StationListData(
      stations: (json['stations'] as List<dynamic>)
          .map((e) => StationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StationListDataToJson(StationListData instance) =>
    <String, dynamic>{'stations': instance.stations};

StationItem _$StationItemFromJson(Map<String, dynamic> json) => StationItem(
  regionId: (json['region_id'] as num?)?.toInt(),
  name: json['name'] as String?,
  isActive: (json['is_active'] as num?)?.toInt(),
  createdDate: json['created_date'] as String?,
);

Map<String, dynamic> _$StationItemToJson(StationItem instance) =>
    <String, dynamic>{
      'region_id': instance.regionId,
      'name': instance.name,
      'is_active': instance.isActive,
      'created_date': instance.createdDate,
    };
