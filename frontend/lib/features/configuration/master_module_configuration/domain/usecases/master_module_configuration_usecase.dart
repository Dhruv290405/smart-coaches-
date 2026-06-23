import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/repositories/master_module_configuration_repository.dart';

@injectable
class MasterModuleConfigurationUseCase {
  final MasterModuleConfigurationRepository repository;

  MasterModuleConfigurationUseCase(this.repository);

  Future<List<DeviceEntity>> fetchDevice() => repository.fetchDevice();

  Future<List<MasterModuleEntity>> fetchMasterModuleList() =>
      repository.fetchMasterModuleList();

  Future<String> createMasterModuleConfiguration(
          MasterModuleConfigurationRequest masterModuleConfigurationRequest) =>
      repository
          .createMasterModuleConfiguration(masterModuleConfigurationRequest);

  Future<String> editMasterModuleConfiguration(int? moduleId,
          MasterModuleConfigurationRequest masterModuleConfigurationRequest) =>
      repository.editMasterModuleConfiguration(
          moduleId, masterModuleConfigurationRequest);

  Future<String> deleteMasterModuleConfiguration(int? moduleId) =>
      repository.deleteMasterModuleConfiguration(moduleId);

  Future<List<CoachEntity>> getAllCoachesList() =>
      repository.getAllCoachesList();
}
