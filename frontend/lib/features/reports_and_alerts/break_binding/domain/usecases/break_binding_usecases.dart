import 'package:injectable/injectable.dart';
import '../../data/models/break_binding_response.dart';
import '../../data/models/coach_by_location_response.dart';
import '../../data/models/pneumatic_status_model.dart';
import '../repositories/break_bindinng_repository.dart';

@injectable
class BreakBindingUsecases {
  final BreakBindinngRepository repository;

  BreakBindingUsecases({required this.repository});

  Future<List<TrainItem>> fetchTrainList() => repository.getTrainList();

  Future<List<CoachItem>> getCoachList(int trainId) => repository.getCoachList(trainId);

  Future<List<CoachByLocationItem>> getCoachesByLocation() => repository.getCoachesByLocation();

  Future<PneumaticStatusResponse> getPneumaticStatus({String? trainNo, String? coachNo, String? deviceId, String? fromDate, String? toDate, int? limit}) =>
    repository.getPneumaticStatus(trainNo: trainNo, coachNo: coachNo, deviceId: deviceId, fromDate: fromDate, toDate: toDate, limit: limit);
}