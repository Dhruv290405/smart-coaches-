import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/domain/repositories/train_list_configuration_repository.dart';

import '../../data/datasources/train_list_remote_data_source.dart';

@Injectable(as: TrainListRepository)
class TrainListRepositoryImpl implements TrainListRepository {
  final TrainRemoteDataSourceImpl remoteDataSource;

  TrainListRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TrainItem>> getTrainList() async {
    final models = await remoteDataSource.fetchTrainList();
    return models.map((m) {
      return TrainItem(
          trainNumber: m.trainNumber,
          trainName: m.trainName,
          trainId: m.trainId
      );
    }
    ).toList();
  }

  @override
  Future<List<BasicCoachItem>> getCoachList(int? trainId) async {
    print("BasicCoachItem : $trainId");
    final models = await remoteDataSource.fetchCoachList(trainId);
    return models.map((m) {
      return BasicCoachItem(
          coach_id: m.coach_id,
        coach_unique_id: m.coach_unique_id
      );
    }
    ).toList();
  }

  @override
  Future<List<BasicSensorItem>> fetchSensorList(int? trainId) async {
    final models = await remoteDataSource.fetchSensorList(trainId);
    return models.map((m) {
      return BasicSensorItem(
          sensor_config_id: m.sensor_config_id,
          sensor_id: m.sensor_id,
          sensor_type_id: m.sensor_type_id
      );
    }
    ).toList();
  }
}
