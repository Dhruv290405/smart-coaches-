import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_response.dart';

abstract class BcPressureRemoteDataSource {
  Future<BcPressureResponse> getBcPressureData({
    String? trainNo,
    String? deviceId,
  });
}

@Injectable(as: BcPressureRemoteDataSource)
class BcPressureRemoteDataSourceImpl implements BcPressureRemoteDataSource {
  final RestClient restClient;

  BcPressureRemoteDataSourceImpl(this.restClient);

  @override
  Future<BcPressureResponse> getBcPressureData({
    String? trainNo,
    String? deviceId,
  }) async {
    return safeRequest(() async {
      return await restClient.getBcPressureData(trainNo, deviceId);
    });
  }
}
