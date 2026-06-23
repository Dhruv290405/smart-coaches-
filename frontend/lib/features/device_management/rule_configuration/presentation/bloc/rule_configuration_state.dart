import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

class RuleConfigurationState {
  final List<DeviceEntity> deviceList;
  final List<SensorTypeEntity> sensorList;
  final List<SensorCategoryEntity> sensorCategoriesList;
  // final List<SiUnitEntity> sensorCategorySiUnitList;
  final Map<int, List<SiUnitEntity>> sensorCategorySiUnitsMap;
  final List<RuleConfigurationEntity> rulesList;
  final List<AlertTypeItem> alertTypeList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const RuleConfigurationState({
    this.deviceList = const [],
    this.sensorList = const [],
    this.sensorCategoriesList = const [],
    // this.sensorCategorySiUnitList = const [],
    this.sensorCategorySiUnitsMap = const {},
    this.rulesList = const [],
    this.alertTypeList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  RuleConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    List<SensorTypeEntity>? sensorList,
    List<SensorCategoryEntity>? sensorCategoriesList,
    // List<SiUnitEntity>? sensorCategorySiUnitList,
    Map<int, List<SiUnitEntity>>? sensorCategorySiUnitsMap,
    List<RuleConfigurationEntity>? rulesList,
    List<AlertTypeItem>? alertTypeList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return RuleConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      sensorList: sensorList ?? this.sensorList,
      sensorCategoriesList: sensorCategoriesList ?? this.sensorCategoriesList,
      // sensorCategorySiUnitList: sensorCategorySiUnitList ?? this.sensorCategorySiUnitList,
      sensorCategorySiUnitsMap: sensorCategorySiUnitsMap ?? this.sensorCategorySiUnitsMap,
      rulesList: rulesList ?? this.rulesList,
      alertTypeList: alertTypeList ?? this.alertTypeList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
