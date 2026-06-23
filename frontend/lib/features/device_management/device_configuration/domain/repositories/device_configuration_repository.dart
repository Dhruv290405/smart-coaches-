import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

abstract class DeviceConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();
  Future<String> createDeviceConfiguration(DeviceConfigurationRequest deviceConfigurationRequest);
  Future<String> editDeviceConfiguration(String? deviceId, DeviceConfigurationRequest deviceConfigurationRequest);
  Future<String> deleteDeviceConfiguration(String? deviceId);
}
