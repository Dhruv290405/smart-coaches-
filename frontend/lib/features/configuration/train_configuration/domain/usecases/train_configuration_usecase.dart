import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/repositories/train_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

@injectable
class CoachConfigurationUseCase {
  final CoachConfigurationRepository repository;

  CoachConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<TrainConfigsEntity>> fetchTrainList() => repository.fetchTrainList();

  Future<String> createTrainConfiguration(
          TrainConfigurationRequest trainConfigurationRequest) =>
      repository.createTrainConfiguration(trainConfigurationRequest);

  Future<String> editTrainConfiguration(
          int? trainId, TrainConfigurationRequest trainConfigurationRequest) =>
      repository.editTrainConfiguration(trainId, trainConfigurationRequest);

  Future<String> deleteTrainConfiguration(int? trainId) =>
      repository.deleteTrainConfiguration(trainId);

  Future<List<RegionItem>> getAllRegions() => repository.getAllRegions();
  Future<List<StationItem>> getAllStations() => repository.getAllStations();
}
