import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/repositories/device_configuration_repository.dart';

@injectable
class DeviceConfigurationUseCase {
  final DeviceConfigurationRepository repository;

  DeviceConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<String> createDeviceConfiguration(DeviceConfigurationRequest deviceConfigurationRequest) => repository.createDeviceConfiguration(deviceConfigurationRequest);

  Future<String> editDeviceConfiguration(String? deviceId, DeviceConfigurationRequest deviceConfigurationRequest) => repository.editDeviceConfiguration(deviceId, deviceConfigurationRequest);

  Future<String> deleteDeviceConfiguration(String? deviceId) =>
      repository.deleteDeviceConfiguration(deviceId);
}
