// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_configuration_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainConfigurationRequest _$TrainConfigurationRequestFromJson(
  Map<String, dynamic> json,
) => _TrainConfigurationRequest(
  trainNumber: _parseInt(json['train_number']),
  trainName: json['train_name'] as String?,
  originationRegionId: _parseInt(json['origination_region_id']),
  regionId: _parseInt(json['region_id']),
  departureStationId: _parseInt(json['departure_station_id']),
  destinationStationId: _parseInt(json['destination_station_id']),
  numberOfCoaches: _parseInt(json['no_of_coaches']),
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
