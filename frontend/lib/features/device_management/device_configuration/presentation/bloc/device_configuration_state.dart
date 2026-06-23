import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

class DeviceConfigurationState {
  final List<DeviceEntity> deviceList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const DeviceConfigurationState({
    this.deviceList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  DeviceConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return DeviceConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
