import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/datasources/coach_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/repositories/coach_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

@Injectable(as: SensorDeviceConfigurationRepository)
class CoachConfigurationRepositoryImpl implements SensorDeviceConfigurationRepository {
  final SensorDeviceConfigurationRemoteDataSourceImpl remoteDataSource;

  CoachConfigurationRepositoryImpl({required this.remoteDataSource});

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
        dataType: Utils.normalizeDropDownValue(m.dataType, Constants.valueFormats),
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
  Future<List<CoachEntity>> fetchCoachList() async {
    final models = await remoteDataSource.fetchCoachList();
    return models.map((m) {
      return CoachEntity.fromModel(m);
    }).toList();
  }

  @override
  Future<String> createCoachConfiguration(
      CoachConfigurationRequest coachConfigurationRequest) async {
    return await remoteDataSource
        .createCoachConfiguration(coachConfigurationRequest);
  }

  @override
  Future<String> editCoachConfiguration(int? coachId,
      CoachConfigurationRequest coachConfigurationRequest) async {
    return await remoteDataSource.editCoachConfiguration(
        coachId, coachConfigurationRequest);
  }

  @override
  Future<String> deleteCoachConfiguration(int? coachId) async {
    return await remoteDataSource.deleteCoachConfiguration(coachId);
  }

  @override
  Future<List<CoachMakeItem>> getCoachMakeList() async {
    return await remoteDataSource.getCoachMakeList();
  }

  @override
  Future<List<CoachTypeItem>> getCoachTypeList() async {
    return await remoteDataSource.getCoachTypeList();
  }

  @override
  Future<CoachConfigResponse> getCoachConfig(String coachNo) async {
    return await remoteDataSource.getCoachConfig(coachNo);
  }
}
