import 'package:injectable/injectable.dart';
import '../../data/datasource/break_binding_remote_data_source.dart';
import '../../data/models/break_binding_response.dart';
import '../../data/models/coach_by_location_response.dart';
import '../../data/models/pneumatic_status_model.dart';
import 'break_bindinng_repository.dart';

@Injectable(as: BreakBindinngRepository)
class TrainListRepositoryImpl implements BreakBindinngRepository {
  final BreakBindingRemoteDataSourceImpl bindingRemoteDataSourceImpl;

  TrainListRepositoryImpl({required this.bindingRemoteDataSourceImpl});

  @override
  Future<List<TrainItem>> getTrainList() async {
    return bindingRemoteDataSourceImpl.fetchTrainList();
  }

  @override
  Future<List<CoachItem>> getCoachList(int trainId) async {
    return bindingRemoteDataSourceImpl.fetchCoachList(trainId);
  }

  @override
  Future<List<CoachByLocationItem>> getCoachesByLocation() async {
    return bindingRemoteDataSourceImpl.fetchCoachesByLocation();
  }

  @override
  Future<PneumaticStatusResponse> getPneumaticStatus({String? trainNo, String? coachNo, String? deviceId, String? fromDate, String? toDate, int? limit}) async {
    return bindingRemoteDataSourceImpl.fetchPneumaticStatus(trainNo: trainNo, coachNo: coachNo, deviceId: deviceId, fromDate: fromDate, toDate: toDate, limit: limit);
  }
}
