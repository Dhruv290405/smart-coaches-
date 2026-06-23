import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/datasources/rule_configuration_remote_data_source.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/alert_type_response.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/repositories/rule_configuration_repository.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_category_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/si_unit_entity.dart';

@Injectable(as: RuleConfigurationRepository)
class RuleConfigurationRepositoryImpl implements RuleConfigurationRepository {
  final RuleConfigurationRemoteDataSourceImpl remoteDataSource;

  RuleConfigurationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeviceEntity>> fetchDevice() async {
    final models = await remoteDataSource.fetchDevice();
    return models.map((item) => DeviceEntity.fromModel(item)).toList();
  }

  @override
  Future<List<SensorTypeEntity>> fetchSensor() async {
    final models = await remoteDataSource.fetchSensor();
    return models.map((item) => SensorTypeEntity.fromModel(item)).toList();
  }

  @override
  Future<List<RuleConfigurationEntity>> getRulesList() async {
    final models = await remoteDataSource.getRulesList();
    return models
        .map((item) => RuleConfigurationEntity.fromModel(item))
        .toList();
  }

  @override
  Future<String> createRuleConfiguration(
      RuleConfigurationRequest ruleConfigurationRequest) async {
    return await remoteDataSource
        .createRuleConfiguration(ruleConfigurationRequest);
  }

  @override
  Future<String> editRuleConfiguration(
      int? ruleId, RuleConfigurationRequest ruleConfigurationRequest) async {
    return await remoteDataSource.editRuleConfiguration(
        ruleId, ruleConfigurationRequest);
  }

  @override
  Future<String> deleteRuleConfiguration(int? ruleId) async {
    return await remoteDataSource.deleteRuleConfiguration(ruleId);
  }

  @override
  Future<List<SensorCategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((item) => SensorCategoryEntity.fromModel(item)).toList();
  }

  @override
  Future<List<SiUnitEntity>> getSiUnits(int? categoryId) async {
    final models = await remoteDataSource.getSiUnits(categoryId);
    return models.map((item) => SiUnitEntity.fromModel(item)).toList();
  }

  @override
  Future<List<AlertTypeItem>> getAlertTypes() async {
    return await remoteDataSource.getAlertTypes();
  }
}
