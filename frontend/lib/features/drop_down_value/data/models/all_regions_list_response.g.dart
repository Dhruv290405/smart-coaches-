// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_regions_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllRegionListResponse _$AllRegionListResponseFromJson(
  Map<String, dynamic> json,
) => AllRegionListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : AllRegionListData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AllRegionListResponseToJson(
  AllRegionListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

AllRegionListData _$AllRegionListDataFromJson(Map<String, dynamic> json) =>
    AllRegionListData(
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllRegionListDataToJson(AllRegionListData instance) =>
    <String, dynamic>{'regions': instance.regions};
