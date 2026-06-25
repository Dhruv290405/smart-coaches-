import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';

abstract class MasterModuleConfigurationRepository {
  Future<List<DeviceEntity>> fetchDevice();

  Future<List<MasterModuleEntity>> fetchMasterModuleList();

  Future<String> createMasterModuleConfiguration(
    MasterModuleConfigurationRequest masterModuleConfigurationRequest, {
    Map<String, dynamic>? extraFields,
  });

  Future<String> editMasterModuleConfiguration(
    int? moduleId,
    MasterModuleConfigurationRequest masterModuleConfigurationRequest, {
    Map<String, dynamic>? extraFields,
  });

  Future<String> deleteMasterModuleConfiguration(int? moduleId);

  Future<List<CoachEntity>> getAllCoachesList();
}
