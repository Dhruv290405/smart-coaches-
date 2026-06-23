// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainConfigurationRequest _$TrainConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _TrainConfigurationRequest(
  trainNumber: (json['train_number'] as num?)?.toInt(),
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
      ?.map(
        (e) => CoachConfigurationRequest.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$TrainConfigurationRequestToJson(
  _TrainConfigurationRequest instance,
) => <String, dynamic>{
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
  'coaches': instance.coaches,
};
