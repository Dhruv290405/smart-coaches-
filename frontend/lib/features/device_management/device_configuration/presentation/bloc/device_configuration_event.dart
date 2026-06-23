import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';

abstract class DeviceConfigurationEvent {}

class LoadDeviceConfigurationList extends DeviceConfigurationEvent {}

class CreateEditDeviceConfiguration extends DeviceConfigurationEvent {
  final String? deviceId;//for edit
  final DeviceConfigurationRequest deviceConfigurationRequest;

  CreateEditDeviceConfiguration(this.deviceConfigurationRequest, {this.deviceId});
}

class DeleteDeviceConfiguration extends DeviceConfigurationEvent {
  final String? deviceId;

  DeleteDeviceConfiguration(this.deviceId);
}