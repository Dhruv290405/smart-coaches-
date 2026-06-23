// import 'package:json_annotation/json_annotation.dart';
//
// part 'user_train_response.g.dart';
//
// @JsonSerializable(explicitToJson: true)
// class UserTrainResponse {
//   final bool? success;
//   final String? message;
//   final UserUserTrainData? data;
//
//   UserTrainResponse({this.success, this.message, this.data});
//
//   factory UserTrainResponse.fromJson(Map<String, dynamic> json) =>
//       _$UserTrainResponseFromJson(json);
//
//   Map<String, dynamic> toJson() => _$UserTrainResponseToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true)
// class UserUserTrainData {
//   final List<UserTrainItem>? trains;
//
//   UserUserTrainData({this.trains});
//
//   factory UserUserTrainData.fromJson(Map<String, dynamic> json) =>
//       _$UserUserTrainDataFromJson(json);
//
//   Map<String, dynamic> toJson() => _$UserUserTrainDataToJson(this);
// }
//
// @JsonSerializable(explicitToJson: true)
// class UserTrainItem {
//   @JsonKey(name: 'train_id')
//   final int? trainId;
//
//   @JsonKey(name: 'train_number')
//   final String? trainNumber;
//
//   @JsonKey(name: 'train_name')
//   final String? trainName;
//
//   @JsonKey(name: 'origination_region_id')
//   final int? originationRegionId;
//
//   @JsonKey(name: 'region_id')
//   final int? regionId;
//
//   @JsonKey(name: 'departure_station_id')
//   final int? departureStationId;
//
//   @JsonKey(name: 'destination_station_id')
//   final int? destinationStationId;
//
//   @JsonKey(name: 'no_of_coaches')
//   final int? numberOfCoaches;
//
//   final String? line;
//
//   @JsonKey(name: 'train_operator')
//   final String? trainOperator;
//
//   @JsonKey(name: 'engine_number')
//   final String? engineNumber;
//
//   @JsonKey(name: 'created_by')
//   final int? createdBy;
//
//   @JsonKey(name: 'created_at')
//   final String? createdAt;
//
//   @JsonKey(name: 'updated_by')
//   final int? updatedBy;
//
//   @JsonKey(name: 'updated_at')
//   final String? updatedAt;
//
//   @JsonKey(name: 'origination_region_name')
//   final String? originationRegionName;
//   @JsonKey(name: 'region_name')
//   final String? regionName;
//   @JsonKey(name: 'departure_station_name')
//   final String? departureStationName;
//   @JsonKey(name: 'destination_station_name')
//   final String? destinationStationName;
//   @JsonKey(name: 'entity_type')
//   final String? entityType;
//
//   // @JsonKey(name: 'is_mapped')
//   // bool? isMapped;
//
//   UserTrainItem({
//     this.trainId,
//     this.originationRegionName,
//     this.regionName,
//     this.departureStationName,
//     this.destinationStationName,
//     this.entityType,
//     // this.isMapped,
//     this.trainNumber,
//     this.trainName,
//     this.originationRegionId,
//     this.regionId,
//     this.departureStationId,
//     this.destinationStationId,
//     this.numberOfCoaches,
//     this.line,
//     this.trainOperator,
//     this.engineNumber,
//     this.createdBy,
//     this.createdAt,
//     this.updatedBy,
//     this.updatedAt,
//   });
//
//   factory UserTrainItem.fromJson(Map<String, dynamic> json) =>
//       _$UserTrainItemFromJson(json);
//
//   Map<String, dynamic> toJson() => _$UserTrainItemToJson(this);
// }
