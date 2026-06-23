import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

class SensorTypeConfigurationState {
  final List<DeviceEntity> deviceList;
  final List<SensorCategoryEntity> sensorCategoriesList;
  final List<SiUnitEntity> sensorCategorySiUnitList;
  final List<SensorTypeEntity> sensorList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const SensorTypeConfigurationState({
    this.deviceList = const [],
    this.sensorCategoriesList = const [],
    this.sensorCategorySiUnitList = const [],
    this.sensorList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  SensorTypeConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    List<SensorCategoryEntity>? sensorCategoriesList,
    List<SiUnitEntity>? sensorCategorySiUnitList,
    List<SensorTypeEntity>? sensorList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return SensorTypeConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      sensorCategoriesList: sensorCategoriesList ?? this.sensorCategoriesList,
      sensorCategorySiUnitList:
          sensorCategorySiUnitList ?? this.sensorCategorySiUnitList,
      sensorList: sensorList ?? this.sensorList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
