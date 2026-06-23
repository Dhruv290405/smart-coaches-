import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/usecases/device_configuration_usecase.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_state.dart';

@injectable
class DeviceConfigurationBloc
    extends Bloc<DeviceConfigurationEvent, DeviceConfigurationState> {
  final DeviceConfigurationUseCase deviceConfigurationUseCase;

  DeviceConfigurationBloc({required this.deviceConfigurationUseCase})
      : super(DeviceConfigurationState()) {
    on<LoadDeviceConfigurationList>(_onLoadDeviceConfigurationList);
    on<CreateEditDeviceConfiguration>(_onCreateDeviceConfiguration);
    on<DeleteDeviceConfiguration>(_onDeleteDeviceConfiguration);
  }

  void _onLoadDeviceConfigurationList(LoadDeviceConfigurationList event,
      Emitter<DeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<DeviceEntity> deviceList =
          await deviceConfigurationUseCase.fetchDevice();

      emit(state.copyWith(isLoading: false, deviceList: deviceList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateDeviceConfiguration(CreateEditDeviceConfiguration event,
      Emitter<DeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.deviceId != null) {
        message = await deviceConfigurationUseCase.editDeviceConfiguration(
            event.deviceId, event.deviceConfigurationRequest);
      } else {
        message = await deviceConfigurationUseCase
            .createDeviceConfiguration(event.deviceConfigurationRequest);
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

  void _onDeleteDeviceConfiguration(DeleteDeviceConfiguration event,
      Emitter<DeviceConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await deviceConfigurationUseCase
          .deleteDeviceConfiguration(event.deviceId);

      final updatedList = state.deviceList
          .where((device) => device.deviceId != event.deviceId)
          .toList();

      emit(state.copyWith(
        isLoading: false,
        deviceList: updatedList,
        isActionSuccess: true,
        actionMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadDeviceConfigurationList());
    }
  }
}
