
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';

class TrainListState {
  final List<TrainItem> trainList;
  final List<BasicCoachItem> coachList;
  final List<BasicSensorItem> sensorList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const TrainListState({
    this.trainList = const [],
    this.coachList = const [],
    this.sensorList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  TrainListState copyWith({
    List<TrainItem>? trainList,
    List<BasicCoachItem>? coachList,
    List<BasicSensorItem>? sensorList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return TrainListState(
      trainList: trainList ?? this.trainList,
      coachList: coachList ?? this.coachList,
      sensorList: sensorList ?? this.sensorList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}