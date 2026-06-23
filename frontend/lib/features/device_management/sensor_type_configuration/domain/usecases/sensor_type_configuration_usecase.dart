import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart';

@injectable
class SensorTypeConfigurationUseCase {
  final SensorTypeConfigurationRepository repository;

  SensorTypeConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<SensorTypeEntity>> fetchSensor() => repository.fetchSensor();

  Future<String> createSensorConfiguration(
          SensorTypeConfigurationRequest sensorTypeConfigurationRequest) =>
      repository.createSensorConfiguration(sensorTypeConfigurationRequest);

  Future<String> editSensorTypeConfiguration(int? sensorId,
          SensorTypeConfigurationRequest sensorTypeConfigurationRequest) =>
      repository.editSensorTypeConfiguration(
          sensorId, sensorTypeConfigurationRequest);

  Future<String> deleteSensorTypeConfiguration(int? deviceId) =>
      repository.deleteSensorTypeConfiguration(deviceId);

  Future<List<SensorCategoryEntity>> getCategories() =>
      repository.getCategories();

  Future<List<SiUnitEntity>> getSiUnits(int? categoryId) =>
      repository.getSiUnits(categoryId);
}
