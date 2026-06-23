import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/datasource/hot_axle_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_history_response.dart';

abstract class HotAxleRepository {
  Future<List<HotAxleData>> getHotAxleDashboard({String? trainNo, String? deviceId});
  Future<HotAxleHistoryResponse> getHotAxleHistory({
    required String coachNumber,
    required String startDate,
    required String endDate,
    required int page,
  });
}

@Injectable(as: HotAxleRepository)
class HotAxleRepositoryImpl implements HotAxleRepository {
  final HotAxleRemoteDataSource remoteDataSource;

  HotAxleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<HotAxleData>> getHotAxleDashboard({String? trainNo, String? deviceId}) async {
    final response = await remoteDataSource.getHotAxleDashboard(
      trainNo: trainNo,
      deviceId: deviceId,
    );
    return response.data ?? [];
  }

  @override
  Future<HotAxleHistoryResponse> getHotAxleHistory({
    required String coachNumber,
    required String startDate,
    required String endDate,
    required int page,
  }) async {
    return remoteDataSource.getHotAxleHistory(
      coachNumber: coachNumber,
      startDate: startDate,
      endDate: endDate,
      page: page,
    );
  }
}
