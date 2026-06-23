import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/usecases/train_list_usecase.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/bloc/train_list_event.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/bloc/train_list_state.dart';

@injectable
class TrainListBloc extends Bloc<TrainListEvent, TrainListState> {
  final TrainListUsecase trainListUsecase;

  TrainListBloc({required this.trainListUsecase})
    : super(TrainListState()) {
    on<LoadInitData>(_onLoadInitialData);
    on<LoadCoachData>(_onLoadCoachData);
    on<LoadSensorData>(_onLoadSensorData);
  }

  void _onLoadInitialData(
      LoadInitData event,
      Emitter<TrainListState> emit
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        trainListUsecase.fetchTrainList()
      ]);

      final List<TrainItem> trainList = results[0];

      emit(state.copyWith(isLoading: false, trainList: trainList, ));
    } catch(e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadCoachData(
      LoadCoachData event,
      Emitter<TrainListState> emit
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await Future.wait([
        trainListUsecase.fetchCoachList(event.trainId)
      ]);

      final List<BasicCoachItem> coachList = result[0];
      emit(state.copyWith(isLoading: false, coachList: coachList));
    } catch(e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorData(
      LoadSensorData event,
      Emitter<TrainListState> emit
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await Future.wait([
        trainListUsecase.fetchSensorList(event.coachId)
      ]);

      final List<BasicSensorItem> sensorList = result[0];
      emit(state.copyWith(isLoading: false, sensorList: sensorList));
    } catch(e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}