import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/usecases/sensor_type_configuration_usecase.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_state.dart';

@injectable
class SensorTypeConfigurationBloc
    extends Bloc<SensorTypeConfigurationEvent, SensorTypeConfigurationState> {
  final SensorTypeConfigurationUseCase sensorTypeConfigurationUseCase;

  SensorTypeConfigurationBloc(
      {required this.sensorTypeConfigurationUseCase})
      : super(SensorTypeConfigurationState()) {
    on<LoadDeviceConfigurationList>(_onLoadDeviceConfigurationList);
    on<LoadSensorCategories>(_onLoadSensorCategories);
    on<LoadSensorCategorySiUnits>(_onLoadSensorCategorySiUnits);
    on<LoadSensorTypeConfigurationList>(_onLoadSensorTypeConfigurationList);
    on<CreateEditSensorTypeConfiguration>(_onCreateSensorTypeConfiguration);
    on<DeleteSensorTypeConfiguration>(_onDeleteSensorTypeConfiguration);
  }

  void _onLoadDeviceConfigurationList(LoadDeviceConfigurationList event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<DeviceEntity> deviceList = await sensorTypeConfigurationUseCase.fetchDevice();

      emit(state.copyWith(isLoading: false, deviceList: deviceList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorCategories(LoadSensorCategories event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<SensorCategoryEntity> list = await sensorTypeConfigurationUseCase.getCategories();

      emit(state.copyWith(isLoading: false, sensorCategoriesList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorCategorySiUnits(LoadSensorCategorySiUnits event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<SiUnitEntity> list =
          await sensorTypeConfigurationUseCase.getSiUnits(event.id);

      emit(state.copyWith(isLoading: false, sensorCategorySiUnitList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorTypeConfigurationList(LoadSensorTypeConfigurationList event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<SensorTypeEntity> sensorList =
          await sensorTypeConfigurationUseCase.fetchSensor();

      emit(state.copyWith(isLoading: false, sensorList: sensorList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateSensorTypeConfiguration(CreateEditSensorTypeConfiguration event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.sensorId != null) {
        message =
            await sensorTypeConfigurationUseCase.editSensorTypeConfiguration(
                event.sensorId, event.deviceConfigurationRequest);
      } else {
        message = await sensorTypeConfigurationUseCase
            .createSensorConfiguration(event.deviceConfigurationRequest);
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

  void _onDeleteSensorTypeConfiguration(DeleteSensorTypeConfiguration event,
      Emitter<SensorTypeConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await sensorTypeConfigurationUseCase
          .deleteSensorTypeConfiguration(event.id);

      final updatedList =
          state.sensorList.where((device) => device.sensorTypeId != event.id).toList();

      emit(state.copyWith(
        isLoading: false,
        sensorList: updatedList,
        isActionSuccess: true,
        actionMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadSensorTypeConfigurationList());
    }
  }
}
