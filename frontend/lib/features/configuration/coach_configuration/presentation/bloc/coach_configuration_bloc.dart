import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/usecases/coach_configuration_usecase.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

@injectable
class CoachConfigurationBloc
    extends Bloc<CoachConfigurationEvent, CoachConfigurationState> {
  final CoachConfigurationUseCase coachConfigurationUseCase;

  CoachConfigurationBloc({required this.coachConfigurationUseCase})
    : super(CoachConfigurationState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadCoachConfigurationList>(_onLoadCoachConfigurationList);
    on<CreateEditCoachConfiguration>(_onCreateDeviceConfiguration);
    on<DeleteCoachConfiguration>(_onDeleteCoachConfiguration);
  }

  void _onLoadInitialData(
    LoadInitialData event,
    Emitter<CoachConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        coachConfigurationUseCase.fetchDevice(),
        coachConfigurationUseCase.getCoachMakeList(),
        coachConfigurationUseCase.getCoachTypeList(),
      ]);

      final List<DeviceEntity> deviceList = results[0] as List<DeviceEntity>;
      final List<CoachMakeItem> coachMakeList = results[1] as List<CoachMakeItem>;
      final List<CoachTypeItem> coachTypeList = results[2] as List<CoachTypeItem>;

      emit(state.copyWith(isLoading: false, deviceList: deviceList, coachMakeList: coachMakeList, coachTypeList: coachTypeList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadCoachConfigurationList(
    LoadCoachConfigurationList event,
    Emitter<CoachConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<CoachEntity> list = await coachConfigurationUseCase.fetchCoachList();

      emit(state.copyWith(isLoading: false, coachList: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateDeviceConfiguration(
    CreateEditCoachConfiguration event,
    Emitter<CoachConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.coachId != null) {
        message = await coachConfigurationUseCase.editCoachConfiguration(
          event.coachId,
          event.coachConfigurationRequest,
        );
      } else {
        message = await coachConfigurationUseCase.createCoachConfiguration(
          event.coachConfigurationRequest,
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

  void _onDeleteCoachConfiguration(
    DeleteCoachConfiguration event,
    Emitter<CoachConfigurationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message = await coachConfigurationUseCase.deleteCoachConfiguration(
        event.coachId,
      );

      final updatedList = state.coachList
          .where((device) => device.coachId != event.coachId)
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          coachList: updatedList,
          isActionSuccess: true,
          actionMessage: message,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadCoachConfigurationList());
    }
  }
}
