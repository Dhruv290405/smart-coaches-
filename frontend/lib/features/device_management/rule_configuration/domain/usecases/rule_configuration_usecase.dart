import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/repositories/rule_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

@injectable
class RuleConfigurationUseCase {
  final RuleConfigurationRepository repository;

  RuleConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<SensorTypeEntity>> fetchSensor() => repository.fetchSensor();

  Future<List<RuleConfigurationEntity>> getRulesList() =>
      repository.getRulesList();

  Future<String> createRuleConfiguration(
          RuleConfigurationRequest ruleConfigurationRequest) =>
      repository.createRuleConfiguration(ruleConfigurationRequest);

  Future<String> editRuleConfiguration(
          int? ruleId, RuleConfigurationRequest ruleConfigurationRequest) =>
      repository.editRuleConfiguration(ruleId, ruleConfigurationRequest);

  Future<String> deleteRuleConfiguration(int? ruleId) =>
      repository.deleteRuleConfiguration(ruleId);

  Future<List<SensorCategoryEntity>> getCategories() => repository.getCategories();

  Future<List<SiUnitEntity>> getSiUnits(int? categoryId) =>
      repository.getSiUnits(categoryId);

  Future<List<AlertTypeItem>> getAlertTypes() => repository.getAlertTypes();
}
