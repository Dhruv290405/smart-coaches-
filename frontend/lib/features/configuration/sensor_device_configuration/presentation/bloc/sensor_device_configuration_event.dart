import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';

abstract class SensorDeviceConfigurationEvent {}

class LoadInitialData extends SensorDeviceConfigurationEvent {}

class LoadDeviceListData extends SensorDeviceConfigurationEvent {}

class LoadMasterModuleConfigurationList extends SensorDeviceConfigurationEvent {}

class LoadSensorDeviceConfigurationList extends SensorDeviceConfigurationEvent {}

class CreateEditSensorDeviceConfiguration extends SensorDeviceConfigurationEvent {
  final int? sensorId; //for edit
  final SensorDeviceConfigurationRequest sensorDeviceConfigurationRequest;

  CreateEditSensorDeviceConfiguration(this.sensorDeviceConfigurationRequest, {this.sensorId});
}

class DeleteSensorDeviceConfiguration extends SensorDeviceConfigurationEvent {
  final int? sensorId;

  DeleteSensorDeviceConfiguration(this.sensorId);
}

class LoadMasterModulesForCoach extends SensorDeviceConfigurationEvent {
  final int? coachId;

  LoadMasterModulesForCoach(this.coachId);
}