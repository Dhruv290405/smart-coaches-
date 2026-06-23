import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/create_device_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/delete_device_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/edit_device_configuration_response.dart';

@injectable
class DeviceConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  DeviceConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<DeviceItem>> fetchDevice(
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) async {
    return safeRequest(() async {
      final DeviceListResponse deviceListResponse =
          await restClient.getDeviceList();
      if (!deviceListResponse.success || deviceListResponse.data == null) {
        throw Exception(deviceListResponse.message);
      }
      return deviceListResponse.data!;
    });
  }

  Future<String> createDeviceConfiguration(
      DeviceConfigurationRequest deviceConfigurationRequest) async {
    return safeRequest(() async {
      final CreateDeviceConfigurationResponse configurationResponse =
          await restClient
              .createDeviceConfiguration(deviceConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editDeviceConfiguration(String? deviceId,
      DeviceConfigurationRequest deviceConfigurationRequest) async {
    return safeRequest(() async {
      final EditDeviceConfigurationResponse configurationResponse =
          await restClient.editDeviceConfiguration(
              deviceId, deviceConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteDeviceConfiguration(String? deviceId) async {
    return safeRequest(() async {
      final DeleteDeviceConfigurationResponse
          deleteDeviceConfigurationResponse =
          await restClient.deleteDeviceConfiguration(deviceId);
      if (!deleteDeviceConfigurationResponse.success) {
        throw Exception(deleteDeviceConfigurationResponse.message);
      }
      return deleteDeviceConfigurationResponse.message;
    });
  }
}
