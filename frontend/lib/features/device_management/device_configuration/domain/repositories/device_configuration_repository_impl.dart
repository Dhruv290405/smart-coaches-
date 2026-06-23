import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/datasources/device_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/repositories/device_configuration_repository.dart';

@Injectable(as: DeviceConfigurationRepository)
class DeviceConfigurationRepositoryImpl
    implements DeviceConfigurationRepository {
  final DeviceConfigurationRemoteDataSourceImpl remoteDataSource;

  DeviceConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeviceEntity>> fetchDevice() async {
    final models = await remoteDataSource.fetchDevice();
    return models.map((m) {
      String? createdAt =
          Utils.formatReadableDate(m.createdAt, dateFormat: Constants.dateTimeFormatToShowInTable);
      String? updatedAt =
          Utils.formatReadableDate(m.updatedAt, dateFormat: Constants.dateTimeFormatToShowInTable);
      return DeviceEntity(
        deviceId: m.deviceId,
        shortName: m.shortName,
        fullName: m.fullName,
        description: m.description,
        numberOfSensors: m.numberOfSensors,
        dataType: Utils.normalizeDropDownValue(m.dataType, Constants.valueFormats),
        frequency: m.frequency,
        createdAt: createdAt,
        createdBy: m.createdBy,
        updatedAt: updatedAt,
        updatedBy: m.updatedBy,
        masterModuleId: m.masterModuleId,
        deviceUniqueId: m.deviceUniqueId,
        timeUnit: Utils.normalizeDropDownValue(m.timeUnit, Constants.evaluationUnitValues),
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
  Future<String> createDeviceConfiguration(
      DeviceConfigurationRequest deviceConfigurationRequest) async {
    return await remoteDataSource
        .createDeviceConfiguration(deviceConfigurationRequest);
  }

  @override
  Future<String> editDeviceConfiguration(String? deviceId,
      DeviceConfigurationRequest deviceConfigurationRequest) async {
    return await remoteDataSource.editDeviceConfiguration(
        deviceId, deviceConfigurationRequest);
  }

  @override
  Future<String> deleteDeviceConfiguration(String? deviceId) async {
    return await remoteDataSource.deleteDeviceConfiguration(deviceId);
  }
}
