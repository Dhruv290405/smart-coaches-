import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/datasources/sensor_type_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/repositories/sensor_type_configuration_repository.dart';

@Injectable(as: SensorTypeConfigurationRepository)
class SensorTypeConfigurationRepositoryImpl
    implements SensorTypeConfigurationRepository {
  final SensorTypeConfigurationRemoteDataSourceImpl remoteDataSource;

  SensorTypeConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeviceEntity>> fetchDevice() async {
    final models = await remoteDataSource.fetchDevice();
    return models.map((item) => DeviceEntity.fromModel(item)).toList();
  }

  @override
  Future<List<SensorTypeEntity>> fetchSensor() async {
    final models = await remoteDataSource.fetchSensor();
    return models.map((item) => SensorTypeEntity.fromModel(item)).toList();
  }

  @override
  Future<String> createSensorConfiguration(
      SensorTypeConfigurationRequest sensorTypeConfigurationRequest) async {
    return await remoteDataSource
        .createSensorConfiguration(sensorTypeConfigurationRequest);
  }

  @override
  Future<String> editSensorTypeConfiguration(int? sensorId,
      SensorTypeConfigurationRequest sensorTypeConfigurationRequest) async {
    return await remoteDataSource.editSensorTypeConfiguration(
        sensorId, sensorTypeConfigurationRequest);
  }

  @override
  Future<String> deleteSensorTypeConfiguration(int? deviceId) async {
    return await remoteDataSource.deleteSensorTypeConfiguration(deviceId);
  }

  @override
  Future<List<SensorCategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((item) => SensorCategoryEntity.fromModel(item)).toList();
  }

  @override
  Future<List<SiUnitEntity>> getSiUnits(int? categoryId) async {
    final models = await remoteDataSource.getSiUnits(categoryId);
    return models.map((item) => SiUnitEntity.fromModel(item)).toList();
  }
}
