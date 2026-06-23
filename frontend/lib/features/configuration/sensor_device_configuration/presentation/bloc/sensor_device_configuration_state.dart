import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

class SensorDeviceConfigurationState {
  final List<CoachEntity> coachList;
  final List<DeviceEntity> deviceList;
  final List<SensorMakeItem> sensorMakeList;
  final List<MasterModuleEntity> masterModuleList;
  final List<SensorDeviceEntity> sensorDeviceList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const SensorDeviceConfigurationState({
    this.coachList = const [],
    this.deviceList = const [],
    this.sensorMakeList = const [],
    this.masterModuleList = const [],
    this.sensorDeviceList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  SensorDeviceConfigurationState copyWith({
    List<CoachEntity>? coachList,
    List<DeviceEntity>? deviceList,
    List<SensorMakeItem>? sensorMakeList,
    List<MasterModuleEntity>? masterModuleList,
    List<SensorDeviceEntity>? sensorDeviceList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return SensorDeviceConfigurationState(
      coachList: coachList ?? this.coachList,
      deviceList: deviceList ?? this.deviceList,
      sensorMakeList: sensorMakeList ?? this.sensorMakeList,
      masterModuleList: masterModuleList ?? this.masterModuleList,
      sensorDeviceList: sensorDeviceList ?? this.sensorDeviceList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
