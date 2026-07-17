import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/datasources/sensor_device_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/repositories/sensor_device_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

import '../../../coach_configuration/domain/entities/coach_entity.dart';
import '../../../master_module_configuration/domain/entities/master_module_entity.dart';

@Injectable(as: SensorDeviceConfigurationRepository)
class SensorDeviceConfigurationRepositoryImpl implements SensorDeviceConfigurationRepository {
  final SensorDeviceConfigurationRemoteDataSourceImpl remoteDataSource;

  SensorDeviceConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CoachEntity>> fetchCoachList() async {
    final models = await remoteDataSource.fetchCoachList();
    return models.map((m) {
      return CoachEntity.fromModel(m);
    }).toList();
  }

  @override
  Future<List<DeviceEntity>> fetchDevice() async {
    final models = await remoteDataSource.fetchDevice();
    return models.map((m) {
      String? createdAt = Utils.formatReadableDate(m.createdAt,
          dateFormat: Constants.dateTimeFormatToShowInTable);
      String? updatedAt = Utils.formatReadableDate(m.updatedAt,
          dateFormat: Constants.dateTimeFormatToShowInTable);
      return DeviceEntity(
        deviceId: m.deviceId,
        shortName: m.shortName,
        fullName: m.fullName,
        description: m.description,
        numberOfSensors: m.numberOfSensors,
        dataType:
            Utils.normalizeDropDownValue(m.dataType, Constants.valueFormats),
        frequency: m.frequency,
        createdAt: createdAt,
        createdBy: m.createdBy,
        updatedAt: updatedAt,
        updatedBy: m.updatedBy,
        masterModuleId: m.masterModuleId,
        deviceUniqueId: m.deviceUniqueId,
        timeUnit: Utils.normalizeDropDownValue(
            m.timeUnit, Constants.evaluationUnitValues),
        isActive: m.isActive,
        masterModuleSerial: m.masterModuleSerial,
        coachUniqueId: m.coachUniqueId,
        trainNumber: m.trainNumber,
        trainName: m.trainName,
        deviceTypeName: m.deviceTypeName,
        deviceModel: m.deviceModel,
      );
    }).toList();
  }

  @override
  Future<List<SensorDeviceEntity>> fetchSensorDeviceList() async {
    final models = await remoteDataSource.fetchSensorDeviceList();
    return models.map((m) {
      return SensorDeviceEntity.fromModel(m);
    }).toList();
  }

  @override
  Future<String> createSensorDeviceConfiguration(
      SensorDeviceConfigurationRequest coachConfigurationRequest) async {
    return await remoteDataSource
        .createSensorDeviceConfiguration(coachConfigurationRequest);
  }

  @override
  Future<String> editSensorDeviceConfiguration(int? sensorId,
      SensorDeviceConfigurationRequest coachConfigurationRequest) async {
    return await remoteDataSource.editSensorDeviceConfiguration(
        sensorId, coachConfigurationRequest);
  }

  @override
  Future<String> deleteSensorDeviceConfiguration(int? sensorId) async {
    return await remoteDataSource.deleteSensorDeviceConfiguration(sensorId);
  }

  @override
  Future<List<SensorMakeItem>> getSensorMakeList() async {
    return await remoteDataSource.getSensorMakeList();
  }

  @override
  Future<List<MasterModuleEntity>> getMasterModulesForCoach(int coachId) async {
    final models = await remoteDataSource.fetchMasterModules(coachId);
    return models.map((m) {
      return MasterModuleEntity.fromModel(m);
    }).toList();
  }
}
