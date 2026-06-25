import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/datasources/master_module_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/repositories/master_module_configuration_repository.dart';

@Injectable(as: MasterModuleConfigurationRepository)
class MasterModuleConfigurationRepositoryImpl
    implements MasterModuleConfigurationRepository {
  final MasterModuleConfigurationRemoteDataSourceImpl remoteDataSource;

  MasterModuleConfigurationRepositoryImpl({required this.remoteDataSource});

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
  Future<List<MasterModuleEntity>> fetchMasterModuleList() async {
    final models = await remoteDataSource.fetchMasterModuleList();
    return models.map((m) {
      return MasterModuleEntity.fromModel(m);
    }).toList();
  }

  @override
  Future<String> createMasterModuleConfiguration(
      MasterModuleConfigurationRequest masterModuleConfigurationRequest,
      {Map<String, dynamic>? extraFields}) async {
    return await remoteDataSource
        .createMasterModuleConfiguration(masterModuleConfigurationRequest, extraFields: extraFields);
  }

  @override
  Future<String> editMasterModuleConfiguration(int? moduleId,
      MasterModuleConfigurationRequest masterModuleConfigurationRequest,
      {Map<String, dynamic>? extraFields}) async {
    return await remoteDataSource.editMasterModuleConfiguration(
        moduleId, masterModuleConfigurationRequest, extraFields: extraFields);
  }

  @override
  Future<String> deleteMasterModuleConfiguration(int? moduleId) async {
    return await remoteDataSource.deleteMasterModuleConfiguration(moduleId);
  }

  @override
  Future<List<CoachEntity>> getAllCoachesList() async {
    final models = await remoteDataSource.getAllCoachesList();
    return models.map((m) {
      return CoachEntity.fromModel(m);
    }).toList();
  }
}
