import 'package:json_annotation/json_annotation.dart';

part 'station_list_response.g.dart';

@JsonSerializable()
class StationListResponse {
  final bool success;
  final String message;
  final StationListData? data;

  StationListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StationListResponse.fromJson(Map<String, dynamic> json) =>
      _$StationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StationListResponseToJson(this);
}


@JsonSerializable()
class StationListData {
  final List<StationItem> stations;

  StationListData({
    required this.stations,
  });

  factory StationListData.fromJson(Map<String, dynamic> json) =>
      _$StationListDataFromJson(json);

  Map<String, dynamic> toJson() => _$StationListDataToJson(this);
}

@JsonSerializable()
class StationItem {
  @JsonKey(name: 'region_id')
  final int? regionId;

  final String? name;

  @JsonKey(name: 'is_active')
  final int? isActive;

  @JsonKey(name: 'created_date')
  final String? createdDate;

  StationItem({
    this.regionId,
    this.name,
    this.isActive,
    this.createdDate,
  });

  factory StationItem.fromJson(Map<String, dynamic> json) =>
      _$StationItemFromJson(json);

  Map<String, dynamic> toJson() => _$StationItemToJson(this);
}