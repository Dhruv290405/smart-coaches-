import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';

part 'train_configuration_request.freezed.dart';
part 'train_configuration_request.g.dart';

@freezed
abstract class TrainConfigurationRequest with _$TrainConfigurationRequest {
  const factory TrainConfigurationRequest({
    @JsonKey(name: 'train_number') int? trainNumber,
    @JsonKey(name: 'train_name') String? trainName,
    @JsonKey(name: 'origination_region_id') int? originationRegionId,
    @JsonKey(name: 'region_id') int? regionId,
    @JsonKey(name: 'departure_station_id') int? departureStationId,
    @JsonKey(name: 'destination_station_id') int? destinationStationId,
    @JsonKey(name: 'no_of_coaches') int? numberOfCoaches,
    @JsonKey(name: 'line') String? line,
    @JsonKey(name: 'train_operator') String? trainOperator,
    @JsonKey(name: 'engine_number') String? engineNumber,
    @JsonKey(name: 'coaches') List<CoachConfigurationRequest>? coaches,
  }) = _TrainConfigurationRequest;

  factory TrainConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainConfigurationRequestFromJson(json);
}
