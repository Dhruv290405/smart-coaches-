import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/usecases/train_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

@injectable
class TrainConfigurationBloc
    extends Bloc<CoachConfigurationEvent, TrainConfigurationState> {
  final CoachConfigurationUseCase trainConfigurationUseCase;

  TrainConfigurationBloc({required this.trainConfigurationUseCase})
    : super(TrainConfigurationState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadTrainConfigurationList>(_onLoadTrainConfigurationList);
    on<CreateEditTrainConfiguration>(_onCreateDeviceConfiguration);
    on<DeleteTrainConfiguration>(_onDeleteTrainConfiguration);
  }

  void _onLoadInitialData(
    LoadInitialData event,
    Emitter<TrainConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        trainConfigurationUseCase.fetchDevice(),
        trainConfigurationUseCase.getAllRegions(),
        trainConfigurationUseCase.getAllStations(),
      ]);

      final List<DeviceEntity> deviceList = results[0] as List<DeviceEntity>;
      final List<RegionItem> regionList = results[1] as List<RegionItem>;
      final List<StationItem> stationList = results[2] as List<StationItem>;

      emit(
        state.copyWith(
          isLoading: false,
          deviceList: deviceList,
          regionList: regionList,
          stationList: stationList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadTrainConfigurationList(
    LoadTrainConfigurationList event,
    Emitter<TrainConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<TrainConfigsEntity> list = await trainConfigurationUseCase.fetchTrainList();

      emit(state.copyWith(isLoading: false, trainList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateDeviceConfiguration(
    CreateEditTrainConfiguration event,
    Emitter<TrainConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.trainId != null) {
        message = await trainConfigurationUseCase.editTrainConfiguration(
          event.trainId,
          event.trainConfigurationRequest,
        );
      } else {
        message = await trainConfigurationUseCase.createTrainConfiguration(
          event.trainConfigurationRequest,
        );
      }

      emit(
        state.copyWith(
          isLoading: false,
          isActionSuccess: true,
          actionMessage: message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onDeleteTrainConfiguration(
    DeleteTrainConfiguration event,
    Emitter<TrainConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await trainConfigurationUseCase.deleteTrainConfiguration(
        event.trainId,
      );

      final updatedList = state.trainList
          .where((device) => device.trainId != event.trainId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          trainList: updatedList,
          isActionSuccess: true,
          actionMessage: message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadTrainConfigurationList());
    }
  }
}
