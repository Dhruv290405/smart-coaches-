import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/usecases/master_module_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/usecases/sensor_device_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

@injectable
class SensorDeviceConfigurationBloc extends Bloc<SensorDeviceConfigurationEvent,
    SensorDeviceConfigurationState> {
  final CoachConfigurationUseCase coachConfigurationUseCase;
  final SensorDeviceConfigurationUseCase sensorDeviceConfigurationUseCase;
  final MasterModuleConfigurationUseCase masterModuleConfigurationUseCase;

  SensorDeviceConfigurationBloc(
      {required this.coachConfigurationUseCase, required this.sensorDeviceConfigurationUseCase, required this.masterModuleConfigurationUseCase})
      : super(SensorDeviceConfigurationState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadDeviceListData>(_onLoadDeviceListData);
    on<LoadMasterModuleConfigurationList>(_onLoadMasterModuleConfigurationList);
    on<LoadSensorDeviceConfigurationList>(_onLoadSensorDeviceConfigurationList);
    on<CreateEditSensorDeviceConfiguration>(_onCreateDeviceConfiguration);
    on<DeleteSensorDeviceConfiguration>(_onDeleteSensorDeviceConfiguration);
    on<LoadMasterModulesForCoach>(_onLoadMasterModuleConfigurationListForCoach);
  }

  void _onLoadInitialData(LoadInitialData event,
      Emitter<SensorDeviceConfigurationState> emit) async {

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        sensorDeviceConfigurationUseCase.getSensorMakeList(),
        coachConfigurationUseCase.fetchCoachList(),
        sensorDeviceConfigurationUseCase.fetchDevice(),
      ]);

      final List<SensorMakeItem> sensorMakeList = results[0] as List<SensorMakeItem>;
      final List<CoachEntity> coachList = results[1] as List<CoachEntity>;
      final List<DeviceEntity> deviceList = results[2] as List<DeviceEntity>;

      emit(state.copyWith(
        isLoading: false,
        sensorMakeList: sensorMakeList,
        coachList: coachList,
        deviceList: deviceList,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadDeviceListData(LoadDeviceListData event,
      Emitter<SensorDeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<DeviceEntity> deviceList = await sensorDeviceConfigurationUseCase.fetchDevice();

      emit(state.copyWith(isLoading: false, deviceList: deviceList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadMasterModuleConfigurationList(
      LoadMasterModuleConfigurationList event,
      Emitter<SensorDeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<MasterModuleEntity> list =
      await masterModuleConfigurationUseCase.fetchMasterModuleList();

      emit(state.copyWith(isLoading: false, masterModuleList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorDeviceConfigurationList(
      LoadSensorDeviceConfigurationList event,
      Emitter<SensorDeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<SensorDeviceEntity> list =
          await sensorDeviceConfigurationUseCase.fetchSensorDeviceList();

      print("bloc: $list");

      emit(state.copyWith(isLoading: false, sensorDeviceList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateDeviceConfiguration(CreateEditSensorDeviceConfiguration event,
      Emitter<SensorDeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.sensorId != null) {
        message = await sensorDeviceConfigurationUseCase
            .editSensorDeviceConfiguration(
                event.sensorId, event.sensorDeviceConfigurationRequest);
      } else {
        message = await sensorDeviceConfigurationUseCase
            .createSensorDeviceConfiguration(
                event.sensorDeviceConfigurationRequest);
      }

      emit(state.copyWith(
        isLoading: false,
        isActionSuccess: true,
        actionMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onDeleteSensorDeviceConfiguration(DeleteSensorDeviceConfiguration event,
      Emitter<SensorDeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await sensorDeviceConfigurationUseCase
          .deleteSensorDeviceConfiguration(event.sensorId);

      final updatedList = state.sensorDeviceList
          .where((device) => device.sensorConfigId != event.sensorId)
          .toList();

      emit(state.copyWith(
        isLoading: false,
        sensorDeviceList: updatedList,
        isActionSuccess: true,
        actionMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadSensorDeviceConfigurationList());
    }
  }

  void _onLoadMasterModuleConfigurationListForCoach(
      LoadMasterModulesForCoach event,
      Emitter<SensorDeviceConfigurationState> emit,
      ) async {
    if (event.coachId == null) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Coach ID is null'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      print("Event ${event.coachId}");
      List<MasterModuleEntity> list = await sensorDeviceConfigurationUseCase
          .getMasterModuleForCoach(event.coachId!);

      emit(state.copyWith(isLoading: false, masterModuleList: list));
      if (list.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'No master modules found for this coach'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load master modules: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }
}
