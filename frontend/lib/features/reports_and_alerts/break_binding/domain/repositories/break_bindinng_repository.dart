import '../../data/models/break_binding_response.dart';
import '../../data/models/coach_by_location_response.dart';
import '../../data/models/pneumatic_status_model.dart';

abstract class BreakBindinngRepository {
  Future<List<TrainItem>> getTrainList();

  Future<List<CoachItem>> getCoachList(int trainId);

  Future<List<CoachByLocationItem>> getCoachesByLocation();

  Future<PneumaticStatusResponse> getPneumaticStatus({String? trainNo, String? coachNo, String? deviceId, String? fromDate, String? toDate, int? limit});
}