import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

abstract class CoachConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();

  Future<List<TrainConfigsEntity>> fetchTrainList();

  Future<String> createTrainConfiguration(
    TrainConfigurationRequest trainConfigurationRequest,
  );

  Future<String> editTrainConfiguration(
    int? trainId,
    TrainConfigurationRequest trainConfigurationRequest,
  );

  Future<String> deleteTrainConfiguration(int? trainId);

  Future<List<RegionItem>> getAllRegions();

  Future<List<StationItem>> getAllStations();
}
