import 'package:smart_coach_new/features/configuration/master_module_configuration/data/models/master_module_configuration_request.dart';

abstract class MasterModuleConfigurationEvent {}

class LoadInitialData extends MasterModuleConfigurationEvent {}

class LoadMasterModuleConfigurationList
    extends MasterModuleConfigurationEvent {}

class CreateEditMasterModuleConfiguration
    extends MasterModuleConfigurationEvent {
  final int? moduleId; //for edit
  final MasterModuleConfigurationRequest masterModuleConfigurationRequest;

  CreateEditMasterModuleConfiguration(this.masterModuleConfigurationRequest,
      {this.moduleId});
}

class DeleteMasterModuleConfiguration extends MasterModuleConfigurationEvent {
  final int? moduleId;

  DeleteMasterModuleConfiguration(this.moduleId);
}
