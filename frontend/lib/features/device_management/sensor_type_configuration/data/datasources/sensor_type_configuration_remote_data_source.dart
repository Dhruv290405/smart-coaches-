import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/create_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/delete_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/edit_sensor_type_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_type_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';

@injectable
class SensorTypeConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  SensorTypeConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

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

  Future<List<SensorItem>> fetchSensor(
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) async {
    return safeRequest(() async {
      final SensorListResponse sensorListResponse =
          await restClient.getSensorList();
      if (!sensorListResponse.success || sensorListResponse.data == null) {
        throw Exception(sensorListResponse.message);
      }
      return sensorListResponse.data!;
    });
  }

  Future<String> createSensorConfiguration(
      SensorTypeConfigurationRequest sensorTypeConfigurationRequest) async {
    return safeRequest(() async {
      final CreateSensorTypeConfigurationResponse configurationResponse =
          await restClient.createSensorTypeConfiguration(
              sensorTypeConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editSensorTypeConfiguration(int? sensorId,
      SensorTypeConfigurationRequest sensorTypeConfigurationRequest) async {
    return safeRequest(() async {
      final EditSensorTypeConfigurationResponse configurationResponse =
          await restClient.editSensorTypeConfiguration(
              sensorId, sensorTypeConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteSensorTypeConfiguration(int? deviceId) async {
    return safeRequest(() async {
      final DeleteSensorTypeConfigurationResponse
          deleteSensorTypeConfigurationResponse =
          await restClient.deleteSensorTypeConfiguration(deviceId);
      if (!deleteSensorTypeConfigurationResponse.success) {
        throw Exception(deleteSensorTypeConfigurationResponse.message);
      }
      return deleteSensorTypeConfigurationResponse.message;
    });
  }

  Future<List<SensorCategoryItem>> getCategories() async {
    return safeRequest(() async {
      final SensorCategoryListResponse sensorCategoryListResponse = await restClient.getCategories();
      if (!sensorCategoryListResponse.success || sensorCategoryListResponse.data == null) {
        throw Exception(sensorCategoryListResponse.message);
      }
      return sensorCategoryListResponse.data!;
    });
  }

  Future<List<SiUnitItem>> getSiUnits(int? categoryId) async {
    return safeRequest(() async {
      final SiUnitListResponse siUnitListResponse = await restClient.getSiUnits(categoryId);
      if (!siUnitListResponse.success || siUnitListResponse.data == null) {
        throw Exception(siUnitListResponse.message);
      }
      return siUnitListResponse.data!;
    });
  }
}
