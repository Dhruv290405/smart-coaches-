import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/data/models/device_list_response.dart'
    as device_response;
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/create_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/delete_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/edit_rule_configuration_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rules_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_category_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/sensor_list_response.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/data/models/si_unit_list_response.dart';

@injectable
class RuleConfigurationRemoteDataSourceImpl {
  final RestClient restClient;
  final Prefs prefs;

  RuleConfigurationRemoteDataSourceImpl(this.restClient, this.prefs);

  Future<List<device_response.DeviceItem>> fetchDevice(
      {String? status,
      String? organisationType,
      String? fromDate,
      String? toDate}) async {
    return safeRequest(() async {
      final device_response.DeviceListResponse deviceListResponse =
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

  Future<List<RuleItem>> getRulesList() async {
    return safeRequest(() async {
      final RulesListResponse rulesListResponse =
          await restClient.getRulesList();
      if (!rulesListResponse.success || rulesListResponse.data == null) {
        throw Exception(rulesListResponse.message);
      }
      return rulesListResponse.data!;
    });
  }

  Future<String> createRuleConfiguration(
      RuleConfigurationRequest ruleConfigurationRequest) async {
    return safeRequest(() async {
      final CreateRuleConfigurationResponse configurationResponse =
          await restClient
              .createRuleConfiguration(ruleConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> editRuleConfiguration(
      int? ruleId, RuleConfigurationRequest ruleConfigurationRequest) async {
    return safeRequest(() async {
      final EditRuleConfigurationResponse configurationResponse =
          await restClient.editRuleConfiguration(
              ruleId, ruleConfigurationRequest.toJson());
      if (!configurationResponse.success) {
        throw Exception(configurationResponse.message);
      }
      return configurationResponse.message;
    });
  }

  Future<String> deleteRuleConfiguration(int? ruleId) async {
    return safeRequest(() async {
      final DeleteRuleConfigurationResponse deleteRuleConfigurationResponse =
          await restClient.deleteRuleConfiguration(ruleId);
      if (!deleteRuleConfigurationResponse.success) {
        throw Exception(deleteRuleConfigurationResponse.message);
      }
      return deleteRuleConfigurationResponse.message;
    });
  }

  Future<List<SensorCategoryItem>> getCategories() async {
    return safeRequest(() async {
      final SensorCategoryListResponse sensorCategoryListResponse =
          await restClient.getCategories();
      if (!sensorCategoryListResponse.success ||
          sensorCategoryListResponse.data == null) {
        throw Exception(sensorCategoryListResponse.message);
      }
      return sensorCategoryListResponse.data!;
    });
  }

  Future<List<SiUnitItem>> getSiUnits(int? categoryId) async {
    return safeRequest(() async {
      final SiUnitListResponse siUnitListResponse =
          await restClient.getSiUnits(categoryId);
      if (!siUnitListResponse.success || siUnitListResponse.data == null) {
        throw Exception(siUnitListResponse.message);
      }
      return siUnitListResponse.data!;
    });
  }

  Future<List<AlertTypeItem>> getAlertTypes() async {
    return safeRequest(() async {
      final AlertTypeResponse alertTypeResponse =
          await restClient.getAlertTypes();
      if (!alertTypeResponse.success || alertTypeResponse.data == null) {
        throw Exception(alertTypeResponse.message);
      }
      return alertTypeResponse.data!;
    });
  }
}
