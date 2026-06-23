import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';

class MasterModuleConfigurationState {
  final List<DeviceEntity> deviceList;
  final List<CoachEntity> coachList;
  final List<MasterModuleEntity> masterModuleList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const MasterModuleConfigurationState({
    this.deviceList = const [],
    this.coachList = const [],
    this.masterModuleList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  MasterModuleConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    List<CoachEntity>? coachList,
    List<MasterModuleEntity>? masterModuleList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return MasterModuleConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      coachList: coachList ?? this.coachList,
      masterModuleList: masterModuleList ?? this.masterModuleList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
