abstract class TrainListEvent {}

class LoadInitData extends TrainListEvent {}

class LoadCoachData extends TrainListEvent {
  final int? trainId;
  LoadCoachData(this.trainId);
}

class LoadSensorData extends TrainListEvent {
  final int? coachId;
  LoadSensorData(this.coachId);
}