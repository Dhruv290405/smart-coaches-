import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

import '../../../master_module_configuration/domain/entities/master_module_entity.dart';

abstract class SensorDeviceConfigurationRepository {
  Future<List<CoachEntity>> fetchCoachList();

  Future<List<DeviceEntity>> fetchDevice();

  Future<List<SensorDeviceEntity>> fetchSensorDeviceList();

  Future<String> createSensorDeviceConfiguration(
      SensorDeviceConfigurationRequest coachConfigurationRequest);

  Future<String> editSensorDeviceConfiguration(int? sensorId,
      SensorDeviceConfigurationRequest coachConfigurationRequest);

  Future<String> deleteSensorDeviceConfiguration(int? sensorId);

  Future<List<SensorMakeItem>> getSensorMakeList();

  Future<List<MasterModuleEntity>> getMasterModulesForCoach(int coachId);
}
