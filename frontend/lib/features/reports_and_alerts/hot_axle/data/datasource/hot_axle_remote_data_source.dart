import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_history_response.dart';

abstract class HotAxleRemoteDataSource {
  Future<HotAxleResponse> getHotAxleData({String? trainNo, String? deviceId});
  Future<HotAxleDashboardResponse> getHotAxleDashboard({String? trainNo, String? deviceId});
  Future<HotAxleHistoryResponse> getHotAxleHistory({
    required String coachNumber,
    required String startDate,
    required String endDate,
    required int page,
  });
}

@Injectable(as: HotAxleRemoteDataSource)
class HotAxleRemoteDataSourceImpl implements HotAxleRemoteDataSource {
  final RestClient restClient;

  HotAxleRemoteDataSourceImpl(this.restClient);

  @override
  Future<HotAxleResponse> getHotAxleData({String? trainNo, String? deviceId}) async {
    return safeRequest(() async => await restClient.getHotAxleData(trainNo, deviceId));
  }

  @override
  Future<HotAxleDashboardResponse> getHotAxleDashboard({String? trainNo, String? deviceId}) async {
    return safeRequest(() async => await restClient.getHotAxleDashboard(trainNo, deviceId));
  }

  @override
  Future<HotAxleHistoryResponse> getHotAxleHistory({
    required String coachNumber,
    required String startDate,
    required String endDate,
    required int page,
  }) async {
    return safeRequest(() async => await restClient.getHotAxleHistory(coachNumber, startDate, endDate, page));
  }
}
