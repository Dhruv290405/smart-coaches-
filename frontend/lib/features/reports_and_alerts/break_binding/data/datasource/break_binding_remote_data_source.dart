import 'package:injectable/injectable.dart';
import '../../../../../core/network/rest_client.dart';
import '../../../../../core/network/safe_request.dart';
import '../../../../../core/utils/prefs.dart';
import '../models/break_binding_response.dart';
import '../models/coach_by_location_response.dart';
import '../models/pneumatic_status_model.dart';

@injectable
class BreakBindingRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  BreakBindingRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<TrainItem>> fetchTrainList() async {
    return safeRequest(() async {
      final TrainListResponseForBreakBinding trainConfigsListResponse = await restClient
          .getTrainListBasic();
      if (!trainConfigsListResponse.success) {
        throw Exception(trainConfigsListResponse.message);
      }
      return trainConfigsListResponse.data ?? [];
    });
  }

  Future<List<CoachItem>> fetchCoachList(int trainId) async {
    return safeRequest(() async {
      final CoachListResponseForBreakBinding coachListResponse = await restClient
          .getCoachListBasic(trainId);
      if (!coachListResponse.success) {
        throw Exception(coachListResponse.message);
      }
      return coachListResponse.data ?? [];
    });
  }

  Future<List<CoachByLocationItem>> fetchCoachesByLocation() async {
    return safeRequest(() async {
      final CoachByLocationResponse response = await restClient.getPneumaticCoachesByLocation();
      if (!response.success) {
        throw Exception(response.message);
      }
      return response.data ?? [];
    });
  }

  Future<PneumaticStatusResponse> fetchPneumaticStatus({String? trainNo, String? coachNo, String? deviceId, String? fromDate, String? toDate, int? limit}) async {
    return safeRequest(() async {
      return await restClient.getPneumaticStatus(trainNo, coachNo, deviceId, fromDate, toDate, limit);
    });
  }
}
