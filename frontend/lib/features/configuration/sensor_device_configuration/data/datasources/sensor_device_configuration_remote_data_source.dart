import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/create_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/delete_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/edit_sensor_device_configuration_response.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/data/models/sensor_device_list_response.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart'
    as device_response;
import 'package:smart_coach_new/features/drop_down_value/data/models/sensor_make_list_response.dart';

import '../../../coach_configuration/data/models/coach_list_response.dart';
import '../../../master_module_configuration/data/models/master_module_list_response.dart';

@injectable
class SensorDeviceConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  SensorDeviceConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<CoachItem>> fetchCoachList() async {
    return safeRequest(() async {
      final CoachListResponse trainListResponse = await restClient
          .getCoachList();
      if (!trainListResponse.success || trainListResponse.data == null) {
        throw Exception(trainListResponse.message);
      }
      return trainListResponse.data!;
    });
  }

  Future<List<device_response.DeviceItem>> fetchDevice({
    String? status,
    String? organisationType,
    String? fromDate,
    String? toDate,
  }) async {
    return safeRequest(() async {
      final device_response.DeviceListResponse deviceListResponse =
          await restClient.getDeviceList();
      if (!deviceListResponse.success || deviceListResponse.data == null) {
        throw Exception(deviceListResponse.message);
      }
      return deviceListResponse.data!;
    });
  }

  Future<List<SensorDeviceItem>> fetchSensorDeviceList() async {
    return safeRequest(() async {
      final SensorDeviceListResponse trainListResponse = await restClient
          .getSensorDeviceList();
      if (!trainListResponse.success || trainListResponse.data == null) {
        throw Exception(trainListResponse.message);
      }
      return trainListResponse.data!;
    });
  }

  Future<String> createSensorDeviceConfiguration(
    SensorDeviceConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final CreateSensorDeviceConfigurationResponse configurationResponse =
          await restClient.createSensorDeviceConfiguration(
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editSensorDeviceConfiguration(
    int? trainId,
    SensorDeviceConfigurationRequest trainConfigurationRequest,
  ) async {
    return safeRequest(() async {
      final EditSensorDeviceConfigurationResponse configurationResponse =
          await restClient.editSensorDeviceConfiguration(
            trainId,
            trainConfigurationRequest.toJson(),
          );
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteSensorDeviceConfiguration(int? trainId) async {
    return safeRequest(() async {
      final DeleteSensorDeviceConfigurationResponse
      deleteSensorDeviceConfigurationResponse = await restClient
          .deleteSensorDeviceConfiguration(trainId);
      if (!deleteSensorDeviceConfigurationResponse.success) {
        throw Exception(deleteSensorDeviceConfigurationResponse.message);
      }
      return deleteSensorDeviceConfigurationResponse.message;
    });
  }

  Future<List<SensorMakeItem>> getSensorMakeList() async {
    return safeRequest(() async {
      final SensorMakeListResponse sensorMakeListResponse = await restClient
          .getSensorMakeList();
      if (!sensorMakeListResponse.success ||
          sensorMakeListResponse.data == null) {
        throw Exception(sensorMakeListResponse.message);
      }
      return sensorMakeListResponse.data ?? [];
    });
  }

  Future<List<MasterModuleItem>> fetchMasterModules(int coachId) async {
    return safeRequest(() async {
      final MasterModuleListResponse masterModuleListResponse = await restClient.getMasterModulesForCoach(coachId);
      if (!masterModuleListResponse.success || masterModuleListResponse.data == null) {
        throw Exception(masterModuleListResponse.message);
      }
      return masterModuleListResponse.data ?? [];
    });
  }
}
