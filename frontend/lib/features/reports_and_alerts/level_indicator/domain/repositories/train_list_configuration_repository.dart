import '../../data/models/train_list_response.dart';

abstract class TrainListRepository {
  Future<List<TrainItem>> getTrainList();
  Future<List<BasicCoachItem>> getCoachList(int? trainId);
  Future<List<BasicSensorItem>> fetchSensorList(int? coachId);
}