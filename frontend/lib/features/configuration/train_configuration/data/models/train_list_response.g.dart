// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainListResponse _$TrainListResponseFromJson(Map<String, dynamic> json) =>
    TrainListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : TrainData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrainListResponseToJson(TrainListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

TrainData _$TrainDataFromJson(Map<String, dynamic> json) => TrainData(
  trains: (json['trains'] as List<dynamic>?)
      ?.map((e) => TrainItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TrainDataToJson(TrainData instance) => <String, dynamic>{
  'trains': instance.trains,
};

TrainItem _$TrainItemFromJson(Map<String, dynamic> json) => TrainItem(
  trainId: (json['train_id'] as num?)?.toInt(),
  originationRegionName: json['origination_region_name'] as String?,
  regionName: json['region_name'] as String?,
  departureStationName: json['departure_station_name'] as String?,
  destinationStationName: json['destination_station_name'] as String?,
  entityType: json['entity_type'] as String?,
  isMapped: json['is_mapped'] as bool?,
  trainNumber: json['train_number'] as String?,
  trainName: json['train_name'] as String?,
  originationRegionId: (json['origination_region_id'] as num?)?.toInt(),
  regionId: (json['region_id'] as num?)?.toInt(),
  departureStationId: (json['departure_station_id'] as num?)?.toInt(),
  destinationStationId: (json['destination_station_id'] as num?)?.toInt(),
  numberOfCoaches: (json['no_of_coaches'] as num?)?.toInt(),
  line: json['line'] as String?,
  trainOperator: json['train_operator'] as String?,
  engineNumber: json['engine_number'] as String?,
  coaches: (json['coaches'] as List<dynamic>?)
      ?.map((e) => CoachItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdBy: json['created_by'] as String?,
  createdAt: json['created_at'] as String?,
  updatedBy: json['updated_by'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TrainItemToJson(TrainItem instance) => <String, dynamic>{
  'train_id': instance.trainId,
  'train_number': instance.trainNumber,
  'train_name': instance.trainName,
  'origination_region_id': instance.originationRegionId,
  'region_id': instance.regionId,
  'departure_station_id': instance.departureStationId,
  'destination_station_id': instance.destinationStationId,
  'no_of_coaches': instance.numberOfCoaches,
  'line': instance.line,
  'train_operator': instance.trainOperator,
  'engine_number': instance.engineNumber,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'coaches': instance.coaches?.map((e) => e.toJson()).toList(),
  'origination_region_name': instance.originationRegionName,
  'region_name': instance.regionName,
  'departure_station_name': instance.departureStationName,
  'destination_station_name': instance.destinationStationName,
  'entity_type': instance.entityType,
  'is_mapped': instance.isMapped,
};
