import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/repository/acp_repository.dart';
import 'coach_dashboard_event.dart';
import 'coach_dashboard_state.dart';

@injectable
class CoachDashboardBloc extends Bloc<CoachDashboardEvent, CoachDashboardState> {
  final CoachConfigurationUseCase coachConfigurationUseCase;
  final AcpRepository acpRepository;

  CoachDashboardBloc({
    required this.coachConfigurationUseCase,
    required this.acpRepository,
  }) : super(const CoachDashboardState()) {
    on<LoadCoachDashboardData>(_onLoadData);
    on<SelectCoach>(_onSelectCoach);
    on<SearchCoachById>(_onSearchCoach);
    on<FilterTrainChanged>(_onTrainChanged);
    on<FilterCoachTypeChanged>(_onCoachTypeChanged);
    on<FilterUniqueIdChanged>(_onUniqueIdChanged);
  }

  Future<void> _onLoadData(LoadCoachDashboardData event, Emitter<CoachDashboardState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final coaches = await coachConfigurationUseCase.fetchCoachList();
      final devices = await coachConfigurationUseCase.fetchDevice();

      final trainResponse = await acpRepository.getAcpFilters();
      final List<String> trains = ['All Trains', ...trainResponse.data?.map((e) => e.trainNo).whereType<String>().toSet() ?? []];

      // Full reset — clears selected coach, config, filters, not-found state
      emit(CoachDashboardState(
        isLoading: false,
        coachList: coaches,
        allDevices: devices,
        trainNumbers: trains,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectCoach(SelectCoach event, Emitter<CoachDashboardState> emit) async {
    emit(state.copyWith(isLoading: true, selectedCoach: event.coach, coachNotFound: false, coachNotFoundMessage: ''));

    try {
      final filtered = state.allDevices.where((d) => d.coachUniqueId == event.coach.coachUniqueId).toList();
      final coachNo = event.coach.coachUniqueId ?? "";
      final config = await coachConfigurationUseCase.getCoachConfig(coachNo);

      emit(state.copyWith(
        isLoading: false,
        selectedCoach: event.coach,
        coachConfig: config,
        filteredDevices: filtered,
        coachNotFound: false,
      ));
    } catch (e, stack) {
      emit(state.copyWith(
        isLoading: false,
        coachNotFound: true,
        coachNotFoundMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onSearchCoach(SearchCoachById event, Emitter<CoachDashboardState> emit) {
    if (event.query.isEmpty) return;

    emit(state.copyWith(errorMessage: null));

    // First try to find the coach in the already-loaded coachList
    final coach = state.coachList.where((c) {
      final id = c.coachUniqueId?.toLowerCase() ?? '';
      return id.contains(event.query.toLowerCase());
    }).toList();

    if (coach.isNotEmpty) {
      add(SelectCoach(coach.first));
      return;
    }

    add(SelectCoach(CoachEntity(coachUniqueId: event.query)));
  }

  Future<void> _onTrainChanged(FilterTrainChanged event, Emitter<CoachDashboardState> emit) async {
    emit(state.copyWith(selectedTrain: event.trainNo, selectedCoachType: 'All Types', selectedUniqueId: 'All Coach Numbers', coachNumbers: ['All Coach Numbers']));
    
    if (event.trainNo == 'All Trains') {
      emit(state.copyWith(coachTypes: ['All Types']));
      return;
    }

    try {
      final response = await acpRepository.getAcpFilters(trainNo: event.trainNo);
      final List<String> types = ['All Types', ...response.data?.map((e) => e.commCoachNo).whereType<String>().toSet() ?? []];
      emit(state.copyWith(coachTypes: types));
    } catch (e) {
    }
  }

  Future<void> _onCoachTypeChanged(FilterCoachTypeChanged event, Emitter<CoachDashboardState> emit) async {
    emit(state.copyWith(selectedCoachType: event.coachType, selectedUniqueId: 'All Coach Numbers'));
    
    if (event.coachType == 'All Types') {
      emit(state.copyWith(coachNumbers: ['All Coach Numbers']));
      return;
    }

    try {
      final response = await acpRepository.getAcpFilters(trainNo: state.selectedTrain, coachType: event.coachType);
      final List<String> ids = ['All Coach Numbers', ...response.data?.map((e) => e.techCoachNo).whereType<String>().toSet() ?? []];
      emit(state.copyWith(coachNumbers: ids));
    } catch (e) {
    }
  }

  void _onUniqueIdChanged(FilterUniqueIdChanged event, Emitter<CoachDashboardState> emit) {
    emit(state.copyWith(selectedUniqueId: event.uniqueId));
    if (event.uniqueId != 'All Coach Numbers') {
      add(SearchCoachById(event.uniqueId));
    }
  }
}
