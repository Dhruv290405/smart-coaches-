import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

abstract class SensorTypeConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();

  Future<List<SensorTypeEntity>> fetchSensor();

  Future<String> createSensorConfiguration(SensorTypeConfigurationRequest sensorTypeConfigurationRequest);

  Future<String> editSensorTypeConfiguration(int? sensorId, SensorTypeConfigurationRequest sensorTypeConfigurationRequest);

  Future<String> deleteSensorTypeConfiguration(int? deviceId);

  Future<List<SensorCategoryEntity>> getCategories();

  Future<List<SiUnitEntity>> getSiUnits(int? categoryId);
}
