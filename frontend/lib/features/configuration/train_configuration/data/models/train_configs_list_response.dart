import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';

part 'train_configs_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TrainConfigsListResponse {
  final bool success;
  final String message;
  final List<TrainConfigsItem>? data;

  TrainConfigsListResponse({required this.success, required this.message, this.data});

  factory TrainConfigsListResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainConfigsListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainConfigsListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TrainConfigsItem {
  @JsonKey(name: 'train_id')
  final dynamic trainId;

  @JsonKey(name: 'train_number')
  final String? trainNumber;

  @JsonKey(name: 'train_name')
  final String? trainName;

  @JsonKey(name: 'origination_region_id')
  final dynamic originationRegionId;

  @JsonKey(name: 'region_id')
  final dynamic regionId;

  @JsonKey(name: 'departure_station_id')
  final dynamic departureStationId;

  @JsonKey(name: 'destination_station_id')
  final dynamic destinationStationId;

  @JsonKey(name: 'no_of_coaches')
  final dynamic numberOfCoaches;

  final String? line;

  @JsonKey(name: 'train_operator')
  final String? trainOperator;

  @JsonKey(name: 'engine_number')
  final String? engineNumber;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'coaches')
  final List<CoachItem>? coaches;

  @JsonKey(name: 'origination_region_name')
  final String? originationRegionName;
  @JsonKey(name: 'region_name')
  final String? regionName;
  @JsonKey(name: 'departure_station_name')
  final String? departureStationName;
  @JsonKey(name: 'destination_station_name')
  final String? destinationStationName;
  @JsonKey(name: 'entity_type')
  final String? entityType;

  @JsonKey(name: 'is_mapped')
  bool? isMapped;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? rawJson;

  TrainConfigsItem({
    this.trainId,
    this.originationRegionName,
    this.regionName,
    this.departureStationName,
    this.destinationStationName,
    this.entityType,
    this.isMapped,
    this.trainNumber,
    this.trainName,
    this.originationRegionId,
    this.regionId,
    this.departureStationId,
    this.destinationStationId,
    this.numberOfCoaches,
    this.line,
    this.trainOperator,
    this.engineNumber,
    this.coaches,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.rawJson,
  });

  factory TrainConfigsItem.fromJson(Map<String, dynamic> json) {
    return _$TrainConfigsItemFromJson(json)..rawJson = json;
  }

  Map<String, dynamic> toJson() => _$TrainConfigsItemToJson(this);
}