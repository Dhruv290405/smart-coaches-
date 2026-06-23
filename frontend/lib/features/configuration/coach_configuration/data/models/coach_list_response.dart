import 'package:json_annotation/json_annotation.dart';

part 'coach_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CoachListResponse {
  final bool success;
  final String message;
  final List<CoachItem>? data;

  CoachListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CoachListResponse.fromJson(Map<String, dynamic> json) =>
      _$CoachListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoachListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CoachItem {

  @JsonKey(name: 'coach_id')
  final dynamic coachId;

  @JsonKey(name: 'coach_unique_id')
  final String? coachUniqueId;

  @JsonKey(name: 'coach_display_id')
  final String? coachDisplayId;

  @JsonKey(name: 'position')
  final dynamic position;

  @JsonKey(name: 'no_of_master_module')
  final dynamic noOfMasterModule;

  @JsonKey(name: 'coach_status')
  final String? coachStatus;
  @JsonKey(name: 'entity_type')
  final String? entityType;


  @JsonKey(name: 'manufacturing_year')
  final dynamic manufacturingYear;

  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  @JsonKey(name: 'created_date')
  final String? createdAt;

  @JsonKey(name: 'updated_by_name')
  final String? updatedByName;

  @JsonKey(name: 'updated_date')
  final String? updatedAt;

  @JsonKey(name: 'make_of_coach_name')
  final String? makeOfCoachName;

  @JsonKey(name: 'make_of_coach_id')
  final dynamic makeOfCoachId;

  @JsonKey(name: 'type_of_coach_code')
  final String? typeOfCoachCode;

  @JsonKey(name: 'type_of_coach_id')
  final dynamic typeOfCoachId;


  CoachItem({
    this.coachId,
    this.coachUniqueId,
    this.coachDisplayId,
    this.position,
    this.createdByName,
    this.updatedByName,
    this.manufacturingYear,
    this.entityType,
    this.makeOfCoachName,
    this.makeOfCoachId,
    this.typeOfCoachCode,
    this.typeOfCoachId,
    this.noOfMasterModule,
    this.coachStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory CoachItem.fromJson(Map<String, dynamic> json) =>
      _$CoachItemFromJson(json);

  Map<String, dynamic> toJson() => _$CoachItemToJson(this);
}
