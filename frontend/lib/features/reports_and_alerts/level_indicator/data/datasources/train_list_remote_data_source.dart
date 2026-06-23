
import 'package:injectable/injectable.dart';

import '../../../../../core/network/rest_client.dart';
import '../../../../../core/network/safe_request.dart';
import '../../../../../core/utils/prefs.dart';
import '../models/train_list_response.dart';

@injectable
class TrainRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  TrainRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<TrainItem>> fetchTrainList() async {
    return safeRequest(() async {
      final TrainListResponseForReport trainConfigsListResponse = await restClient
          .getTrainListForReport();
      if (!trainConfigsListResponse.success) {
        throw Exception(trainConfigsListResponse.message);
      }
      return trainConfigsListResponse.data ?? [];
    });
  }

  Future<List<BasicCoachItem>> fetchCoachList(int? trainId) async {
    return safeRequest(() async {
      final CoachListResponseForReport coachListResponse = await restClient
          .getCoachesForReport(trainId);
      if(!coachListResponse.success) {
        throw Exception(coachListResponse.message);
      }
      return coachListResponse.data ?? [];
    });
  }

  Future<List<BasicSensorItem>> fetchSensorList(int? coachId) async {
    return safeRequest(() async {
      final SensorListResponseForReport sensorListResponse = await restClient
          .getSensorsForReport(coachId);
      if(!sensorListResponse.success) {
        throw Exception(sensorListResponse.message);
      }
      return sensorListResponse.data ?? [];
    });
  }
}