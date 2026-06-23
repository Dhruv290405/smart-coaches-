import 'package:equatable/equatable.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class CoachDashboardState extends Equatable {
  final List<CoachEntity> coachList;
  final CoachEntity? selectedCoach;
  final CoachConfigResponse? coachConfig;
  final List<DeviceEntity> allDevices;
  final List<DeviceEntity> filteredDevices;
  final bool isLoading;
  final String? errorMessage;
  final bool coachNotFound;
  final String coachNotFoundMessage;

  // Cascading Filter fields
  final List<String> trainNumbers;
  final List<String> coachTypes;
  final List<String> coachNumbers;
  final String selectedTrain;
  final String selectedCoachType;
  final String selectedUniqueId;

  const CoachDashboardState({
    this.coachList = const [],
    this.selectedCoach,
    this.coachConfig,
    this.allDevices = const [],
    this.filteredDevices = const [],
    this.isLoading = false,
    this.errorMessage,
    this.coachNotFound = false,
    this.coachNotFoundMessage = '',
    this.trainNumbers = const ['All Trains'],
    this.coachTypes = const ['All Types'],
    this.coachNumbers = const ['All Coach Numbers'],
    this.selectedTrain = 'All Trains',
    this.selectedCoachType = 'All Types',
    this.selectedUniqueId = 'All Coach Numbers',
  });

  CoachDashboardState copyWith({
    List<CoachEntity>? coachList,
    CoachEntity? selectedCoach,
    CoachConfigResponse? coachConfig,
    List<DeviceEntity>? allDevices,
    List<DeviceEntity>? filteredDevices,
    bool? isLoading,
    String? errorMessage,
    bool? coachNotFound,
    String? coachNotFoundMessage,
    List<String>? trainNumbers,
    List<String>? coachTypes,
    List<String>? coachNumbers,
    String? selectedTrain,
    String? selectedCoachType,
    String? selectedUniqueId,
  }) {
    return CoachDashboardState(
      coachList: coachList ?? this.coachList,
      selectedCoach: selectedCoach ?? this.selectedCoach,
      coachConfig: coachConfig ?? this.coachConfig,
      allDevices: allDevices ?? this.allDevices,
      filteredDevices: filteredDevices ?? this.filteredDevices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      coachNotFound: coachNotFound ?? this.coachNotFound,
      coachNotFoundMessage: coachNotFoundMessage ?? this.coachNotFoundMessage,
      trainNumbers: trainNumbers ?? this.trainNumbers,
      coachTypes: coachTypes ?? this.coachTypes,
      coachNumbers: coachNumbers ?? this.coachNumbers,
      selectedTrain: selectedTrain ?? this.selectedTrain,
      selectedCoachType: selectedCoachType ?? this.selectedCoachType,
      selectedUniqueId: selectedUniqueId ?? this.selectedUniqueId,
    );
  }

  @override
  List<Object?> get props => [
        coachList,
        selectedCoach,
        coachConfig,
        allDevices,
        filteredDevices,
        isLoading,
        errorMessage,
        coachNotFound,
        coachNotFoundMessage,
        trainNumbers,
        coachTypes,
        coachNumbers,
        selectedTrain,
        selectedCoachType,
        selectedUniqueId,
      ];
}
