
import 'package:injectable/injectable.dart';

import '../../data/models/train_list_response.dart';
import '../repositories/train_list_configuration_repository.dart';

@injectable
class TrainListUsecase {
  final TrainListRepository repository;

  TrainListUsecase({required this.repository});

  Future<List<TrainItem>> fetchTrainList() => repository.getTrainList();
  Future<List<BasicCoachItem>> fetchCoachList(int? trainId) => repository.getCoachList(trainId);
  Future<List<BasicSensorItem>> fetchSensorList(int? coachId) => repository.fetchSensorList(coachId);
}