import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/usecases/rule_configuration_usecase.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

@injectable
class RuleConfigurationBloc
    extends Bloc<RuleConfigurationEvent, RuleConfigurationState> {
  final RuleConfigurationUseCase ruleConfigurationUseCase;

  RuleConfigurationBloc({required this.ruleConfigurationUseCase})
      : super(RuleConfigurationState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadSensorCategorySiUnits>(_onLoadSensorCategorySiUnits);
    on<LoadRuleConfigurationList>(_onLoadRuleConfigurationList);
    on<CreateEditRuleConfiguration>(_onCreateRuleConfiguration);
    on<DeleteRuleConfiguration>(_onDeleteRuleConfiguration);
  }

  void _onLoadInitialData(LoadInitialData event, Emitter<RuleConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final results = await Future.wait([
        ruleConfigurationUseCase.fetchDevice(),
        ruleConfigurationUseCase.fetchSensor(),
        ruleConfigurationUseCase.getCategories(),
        ruleConfigurationUseCase.getAlertTypes(),
      ]);

      final List<DeviceEntity> deviceList = results[0] as List<DeviceEntity>;
      final List<SensorTypeEntity> sensorList = results[1] as List<SensorTypeEntity>;
      final List<SensorCategoryEntity> categoriesList = results[2] as List<SensorCategoryEntity>;
      final List<AlertTypeItem> alertTypeList = results[3] as List<AlertTypeItem>;

      emit(state.copyWith(
        isLoading: false,
        deviceList: deviceList,
        sensorList: sensorList,
        sensorCategoriesList: categoriesList,
        alertTypeList: alertTypeList,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadSensorCategorySiUnits(LoadSensorCategorySiUnits event,
      Emitter<RuleConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<SiUnitEntity> list = await ruleConfigurationUseCase.getSiUnits(event.id);

      final updatedMap = Map<int, List<SiUnitEntity>>.from(state.sensorCategorySiUnitsMap);
      updatedMap[event.id!] = list;

      emit(state.copyWith(isLoading: false, /*sensorCategorySiUnitList: list*/sensorCategorySiUnitsMap: updatedMap,));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadRuleConfigurationList(LoadRuleConfigurationList event,
      Emitter<RuleConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      List<RuleConfigurationEntity> rulesList =
          await ruleConfigurationUseCase.getRulesList();

      emit(state.copyWith(isLoading: false, rulesList: rulesList));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onCreateRuleConfiguration(CreateEditRuleConfiguration event,
      Emitter<RuleConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message;
      if (event.ruleId != null) {
        message = await ruleConfigurationUseCase.editRuleConfiguration(
            event.ruleId, event.ruleConfigurationRequest);
      } else {
        message = await ruleConfigurationUseCase
            .createRuleConfiguration(event.ruleConfigurationRequest);
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

  void _onDeleteRuleConfiguration(DeleteRuleConfiguration event,
      Emitter<RuleConfigurationState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String message =
          await ruleConfigurationUseCase.deleteRuleConfiguration(event.id);

      final updatedList =
          state.rulesList.where((device) => device.ruleId != event.id).toList();

      emit(state.copyWith(
        isLoading: false,
        rulesList: updatedList,
        isActionSuccess: true,
        actionMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      add(LoadRuleConfigurationList());
    }
  }
}
