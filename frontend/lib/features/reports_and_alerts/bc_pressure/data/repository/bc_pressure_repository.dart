import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/datasource/bc_pressure_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/bc_pressure/data/models/bc_pressure_response.dart';

abstract class BcPressureRepository {
  Future<List<BcPressureData>> getBcPressureData({
    String? trainNo,
    String? deviceId,
  });
}

@Injectable(as: BcPressureRepository)
class BcPressureRepositoryImpl implements BcPressureRepository {
  final BcPressureRemoteDataSource remoteDataSource;

  BcPressureRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BcPressureData>> getBcPressureData({
    String? trainNo,
    String? deviceId,
  }) async {
    final response = await remoteDataSource.getBcPressureData(
      trainNo: trainNo,
      deviceId: deviceId,
    );
    return response.data ?? [];
  }
}
