import 'package:equatable/equatable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';

abstract class CoachDashboardEvent extends Equatable {
  const CoachDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadCoachDashboardData extends CoachDashboardEvent {}

class SelectCoach extends CoachDashboardEvent {
  final CoachEntity coach;
  const SelectCoach(this.coach);

  @override
  List<Object?> get props => [coach];
}

class SearchCoachById extends CoachDashboardEvent {
  final String query;
  const SearchCoachById(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTrainChanged extends CoachDashboardEvent {
  final String trainNo;
  const FilterTrainChanged(this.trainNo);

  @override
  List<Object?> get props => [trainNo];
}

class FilterCoachTypeChanged extends CoachDashboardEvent {
  final String coachType;
  const FilterCoachTypeChanged(this.coachType);

  @override
  List<Object?> get props => [coachType];
}

class FilterUniqueIdChanged extends CoachDashboardEvent {
  final String uniqueId;
  const FilterUniqueIdChanged(this.uniqueId);

  @override
  List<Object?> get props => [uniqueId];
}
