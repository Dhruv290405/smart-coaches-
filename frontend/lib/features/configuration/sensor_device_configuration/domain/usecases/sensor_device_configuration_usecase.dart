import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/repositories/sensor_device_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

import '../../../master_module_configuration/domain/entities/master_module_entity.dart';

@injectable
class SensorDeviceConfigurationUseCase {
  final SensorDeviceConfigurationRepository repository;

  SensorDeviceConfigurationUseCase(this.repository);

  Future<List<CoachEntity>> fetchCoachList() => repository.fetchCoachList();

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<SensorDeviceEntity>> fetchSensorDeviceList() => repository.fetchSensorDeviceList();

  Future<String> createSensorDeviceConfiguration(
          SensorDeviceConfigurationRequest trainConfigurationRequest) =>
      repository.createSensorDeviceConfiguration(trainConfigurationRequest);

  Future<String> editSensorDeviceConfiguration(
          int? sensorId, SensorDeviceConfigurationRequest sensorDeviceConfigurationRequest) =>
      repository.editSensorDeviceConfiguration(sensorId, sensorDeviceConfigurationRequest);

  Future<String> deleteSensorDeviceConfiguration(int? sensorId) =>
      repository.deleteSensorDeviceConfiguration(sensorId);

  Future<List<SensorMakeItem>> getSensorMakeList() => repository.getSensorMakeList();

  Future<List<MasterModuleEntity>> getMasterModuleForCoach(int coachId) {
    return repository.getMasterModulesForCoach(coachId);
  }
}
