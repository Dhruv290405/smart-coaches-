import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';

part 'all_regions_list_response.g.dart';

@JsonSerializable()
class AllRegionListResponse {
  final bool success;
  final String message;
  final AllRegionListData? data;

  AllRegionListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AllRegionListResponse.fromJson(Map<String, dynamic> json) =>
      _$AllRegionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AllRegionListResponseToJson(this);
}

@JsonSerializable()
class AllRegionListData {
  final List<RegionItem>? regions;

  AllRegionListData({
    required this.regions,
  });

  factory AllRegionListData.fromJson(Map<String, dynamic> json) =>
      _$AllRegionListDataFromJson(json);

  Map<String, dynamic> toJson() => _$AllRegionListDataToJson(this);
}