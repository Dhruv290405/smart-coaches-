import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/datasources/train_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/repositories/train_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

@Injectable(as: CoachConfigurationRepository)
class TrainConfigurationRepositoryImpl implements CoachConfigurationRepository {
  final CoachConfigurationRemoteDataSourceImpl remoteDataSource;

  TrainConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeviceEntity>> fetchDevice() async {
    final models = await remoteDataSource.fetchDevice();
    return models.map((m) {
      String? createdAt = Utils.formatReadableDate(
        m.createdAt,
        dateFormat: Constants.dateTimeFormatToShowInTable,
      );
      String? updatedAt = Utils.formatReadableDate(
        m.updatedAt,
        dateFormat: Constants.dateTimeFormatToShowInTable,
      );
      return DeviceEntity(
        deviceId: m.deviceId,
        shortName: m.shortName,
        fullName: m.fullName,
        description: m.description,
        numberOfSensors: m.numberOfSensors,
        dataType: Utils.normalizeDropDownValue(
          m.dataType,
          Constants.valueFormats,
        ),
        frequency: m.frequency,
        createdAt: createdAt,
        createdBy: m.createdBy,
        updatedAt: updatedAt,
        updatedBy: m.updatedBy,
        masterModuleId: m.masterModuleId,
        deviceUniqueId: m.deviceUniqueId,
        timeUnit: Utils.normalizeDropDownValue(
          m.timeUnit,
          Constants.evaluationUnitValues,
        ),
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
  Future<List<TrainConfigsEntity>> fetchTrainList() async {
    final models = await remoteDataSource.fetchTrainList();
    return models.map((m) {
      return TrainConfigsEntity.fromModel(m);
    }).toList();
  }

  @override
  Future<String> createTrainConfiguration(
    TrainConfigurationRequest trainConfigurationRequest,
  ) async {
    return await remoteDataSource.createTrainConfiguration(
      trainConfigurationRequest,
    );
  }

  @override
  Future<String> editTrainConfiguration(
    int? trainId,
    TrainConfigurationRequest trainConfigurationRequest,
  ) async {
    return await remoteDataSource.editTrainConfiguration(
      trainId,
      trainConfigurationRequest,
    );
  }

  @override
  Future<String> deleteTrainConfiguration(int? trainId) async {
    return await remoteDataSource.deleteTrainConfiguration(trainId);
  }

  @override
  Future<List<RegionItem>> getAllRegions() async {
    return await remoteDataSource.getAllRegions();
  }

  @override
  Future<List<StationItem>> getAllStations() async {
    return await remoteDataSource.getAllStations();
  }
}
