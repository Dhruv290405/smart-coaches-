import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';

abstract class CoachConfigurationEvent {}

class LoadInitialData extends CoachConfigurationEvent {}

class LoadCoachConfigurationList extends CoachConfigurationEvent {}

class CreateEditCoachConfiguration extends CoachConfigurationEvent {
  final int? coachId; //for edit
  final CoachConfigurationRequest coachConfigurationRequest;

  CreateEditCoachConfiguration(this.coachConfigurationRequest, {this.coachId});
}

class DeleteCoachConfiguration extends CoachConfigurationEvent {
  final int? coachId;

  DeleteCoachConfiguration(this.coachId);
}
