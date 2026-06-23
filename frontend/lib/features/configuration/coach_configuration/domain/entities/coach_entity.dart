import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_list_response.dart';

class CoachEntity {
  final dynamic coachId;
  final String? coachUniqueId;
  final String? coachDisplayId;
  final dynamic position;
  final dynamic noOfMasterModule;
  final String? coachStatus;
  final String? entityType;
  final dynamic manufacturingYear;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String? makeOfCoach;
  final dynamic makeOfCoachId;
  final String? typeOfCoach;
  final dynamic typeOfCoachId;

  const CoachEntity({
    this.coachId,
    this.coachUniqueId,
    this.coachDisplayId,
    this.position,
    this.manufacturingYear,
    this.entityType,
    this.makeOfCoach,
    this.makeOfCoachId,
    this.typeOfCoach,
    this.typeOfCoachId,
    this.noOfMasterModule,
    this.coachStatus,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory CoachEntity.fromModel(CoachItem model) {
    return CoachEntity(
      coachId: model.coachId,
      coachUniqueId: model.coachUniqueId,
      coachDisplayId: model.coachDisplayId,
      position: model.position,
      manufacturingYear: model.manufacturingYear,
      entityType: model.entityType,
      makeOfCoach: model.makeOfCoachName,
      typeOfCoach: model.typeOfCoachCode,
      typeOfCoachId: model.typeOfCoachId,
      makeOfCoachId: model.makeOfCoachId,
      noOfMasterModule: model.noOfMasterModule,
      coachStatus: model.coachStatus,
      createdAt: model.createdAt,
      createdBy: model.createdByName,
      updatedAt: model.updatedAt,
      updatedBy: model.updatedByName,
    );
  }
}
