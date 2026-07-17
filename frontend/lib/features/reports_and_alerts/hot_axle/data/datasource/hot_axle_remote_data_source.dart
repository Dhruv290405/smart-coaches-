import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_history_response.dart';

abstract class HotAxleRemoteDataSource {
  Future<HotAxleResponse> getHotAxleData({String? trainNo, String? deviceId});
  Future<dynamic> getHotAxleFilters();
  Future<HotAxleDashboardResponse> getHotAxleDashboard({String? trainNo, String? deviceId, String? coachType, String? owningRly, String? coachNumber});
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
  Future<dynamic> getHotAxleFilters() async {
    return safeRequest(() async => await restClient.getHotAxleFilters());
  }

  @override
  Future<HotAxleDashboardResponse> getHotAxleDashboard({String? trainNo, String? deviceId, String? coachType, String? owningRly, String? coachNumber}) async {
    return safeRequest(() async => await restClient.getHotAxleDashboard(trainNo, deviceId, coachType, owningRly, coachNumber));
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
