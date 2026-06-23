import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

abstract class RuleConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();

  Future<List<SensorTypeEntity>> fetchSensor();

  Future<List<RuleConfigurationEntity>> getRulesList();

  Future<String> createRuleConfiguration(
      RuleConfigurationRequest ruleConfigurationRequest);

  Future<String> editRuleConfiguration(
      int? ruleId, RuleConfigurationRequest ruleConfigurationRequest);

  Future<String> deleteRuleConfiguration(int? ruleId);

  Future<List<SensorCategoryEntity>> getCategories();

  Future<List<SiUnitEntity>> getSiUnits(int? categoryId);

  Future<List<AlertTypeItem>> getAlertTypes();
}
