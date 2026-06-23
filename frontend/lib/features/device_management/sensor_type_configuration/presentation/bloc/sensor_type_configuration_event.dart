import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';

abstract class SensorTypeConfigurationEvent {}

class LoadDeviceConfigurationList extends SensorTypeConfigurationEvent {}

class LoadSensorCategories extends SensorTypeConfigurationEvent {}

class LoadSensorCategorySiUnits extends SensorTypeConfigurationEvent {
  final int? id;

  LoadSensorCategorySiUnits(this.id);
}

class LoadSensorTypeConfigurationList extends SensorTypeConfigurationEvent {}

class CreateEditSensorTypeConfiguration extends SensorTypeConfigurationEvent {
  final int? sensorId; //for edit
  final SensorTypeConfigurationRequest deviceConfigurationRequest;

  CreateEditSensorTypeConfiguration(this.deviceConfigurationRequest,
      {this.sensorId});
}

class DeleteSensorTypeConfiguration extends SensorTypeConfigurationEvent {
  final int? id;

  DeleteSensorTypeConfiguration(this.id);
}
