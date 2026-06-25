import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/usecases/master_module_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

@injectable
class MasterModuleConfigurationBloc
    extends
        Bloc<MasterModuleConfigurationEvent, MasterModuleConfigurationState> {
  final MasterModuleConfigurationUseCase masterModuleConfigurationUseCase;

  MasterModuleConfigurationBloc({
    required this.masterModuleConfigurationUseCase,
  }) : super(MasterModuleConfigurationState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadMasterModuleConfigurationList>(_onLoadMasterModuleConfigurationList);
    on<CreateEditMasterModuleConfiguration>(_onCreateDeviceConfiguration);
    on<DeleteMasterModuleConfiguration>(_onDeleteMasterModuleConfiguration);
  }

  void _onLoadInitialData(
    LoadInitialData event,
    Emitter<MasterModuleConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        masterModuleConfigurationUseCase.fetchDevice(),
        masterModuleConfigurationUseCase.getAllCoachesList(),
      ]);

      final List<DeviceEntity> deviceList = results[0] as List<DeviceEntity>;
      final List<CoachEntity> coachList = results[1] as List<CoachEntity>;

      emit(
        state.copyWith(
          isLoading: false,
          deviceList: deviceList,
          coachList: coachList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadMasterModuleConfigurationList(
    LoadMasterModuleConfigurationList event,
    Emitter<MasterModuleConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<MasterModuleEntity> list = await masterModuleConfigurationUseCase
          .fetchMasterModuleList();

      emit(state.copyWith(isLoading: false, masterModuleList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateDeviceConfiguration(
    CreateEditMasterModuleConfiguration event,
    Emitter<MasterModuleConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.moduleId != null) {
        message = await masterModuleConfigurationUseCase
            .editMasterModuleConfiguration(
              event.moduleId,
              event.masterModuleConfigurationRequest,
              extraFields: event.extraFields,
            );
      } else {
        message = await masterModuleConfigurationUseCase
            .createMasterModuleConfiguration(
              event.masterModuleConfigurationRequest,
              extraFields: event.extraFields,
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

  void _onDeleteMasterModuleConfiguration(
    DeleteMasterModuleConfiguration event,
    Emitter<MasterModuleConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await masterModuleConfigurationUseCase
          .deleteMasterModuleConfiguration(event.moduleId);

      final updatedList = state.masterModuleList
          .where((device) => device.moduleId != event.moduleId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          masterModuleList: updatedList,
          isActionSuccess: true,
          actionMessage: message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadMasterModuleConfigurationList());
    }
  }
}
