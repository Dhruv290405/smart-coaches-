import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_configuration_request.freezed.dart';
part 'coach_configuration_request.g.dart';

@freezed
abstract class CoachConfigurationRequest with _$CoachConfigurationRequest {
  const factory CoachConfigurationRequest({
    @JsonKey(name: 'entity_type') String? entityType,
    @JsonKey(name: 'coach_unique_id') String? coachUniqueId,
    @JsonKey(name: 'coach_display_id') String? coachDisplayId,
    @JsonKey(name: 'manufacturing_year') String? manufacturingYear,
    @JsonKey(name: 'make_of_coach') String? makeOfCoach,
    @JsonKey(name: 'type_of_coach') String? typeOfCoach,
    @JsonKey(name: 'no_of_master_module') int? noOfMasterModule,
    @JsonKey(name: 'coach_status') String? coachStatus,
    @JsonKey(name: 'position') int? position,
  }) = _CoachConfigurationRequest;

  factory CoachConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$CoachConfigurationRequestFromJson(json);
}
