import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_make_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/coach_types_list_response.dart';

class CoachConfigurationState {
  final List<DeviceEntity> deviceList;
  final List<CoachMakeItem> coachMakeList;
  final List<CoachTypeItem> coachTypeList;
  final List<CoachEntity> coachList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const CoachConfigurationState({
    this.deviceList = const [],
    this.coachMakeList = const [],
    this.coachTypeList = const [],
    this.coachList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  CoachConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    List<CoachMakeItem>? coachMakeList,
    List<CoachTypeItem>? coachTypeList,
    List<CoachEntity>? coachList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return CoachConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      coachMakeList: coachMakeList ?? this.coachMakeList,
      coachTypeList: coachTypeList ?? this.coachTypeList,
      coachList: coachList ?? this.coachList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
