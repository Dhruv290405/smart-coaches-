import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

class TrainConfigurationState {
  final List<DeviceEntity> deviceList;
  final List<TrainConfigsEntity> trainList;
  final List<RegionItem> regionList;
  final List<StationItem> stationList;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;
  final String? actionMessage;

  const TrainConfigurationState({
    this.deviceList = const [],
    this.regionList = const [],
    this.stationList = const [],
    this.trainList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
    this.actionMessage,
  });

  TrainConfigurationState copyWith({
    List<DeviceEntity>? deviceList,
    List<TrainConfigsEntity>? trainList,
    List<RegionItem>? regionList,
    List<StationItem>? stationList,
    bool? isLoading,
    String? errorMessage,
    bool? isActionSuccess,
    String? actionMessage,
  }) {
    return TrainConfigurationState(
      deviceList: deviceList ?? this.deviceList,
      trainList: trainList ?? this.trainList,
      regionList: regionList ?? this.regionList,
      stationList: stationList ?? this.stationList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isActionSuccess: isActionSuccess ?? false,
      actionMessage: actionMessage,
    );
  }
}
