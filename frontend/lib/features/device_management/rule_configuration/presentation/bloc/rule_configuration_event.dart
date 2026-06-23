import 'package:smart_coach_new/features/device_management/rule_configuration/data/models/rule_configuration_request.dart';

abstract class RuleConfigurationEvent {}

class LoadInitialData extends RuleConfigurationEvent {}

class LoadSensorCategorySiUnits extends RuleConfigurationEvent {
  final int? id;

  LoadSensorCategorySiUnits(this.id);
}

class LoadRuleConfigurationList extends RuleConfigurationEvent {}

class CreateEditRuleConfiguration extends RuleConfigurationEvent {
  final int? ruleId; //for edit
  final RuleConfigurationRequest ruleConfigurationRequest;

  CreateEditRuleConfiguration(this.ruleConfigurationRequest, {this.ruleId});
}

class DeleteRuleConfiguration extends RuleConfigurationEvent {
  final int? id;

  DeleteRuleConfiguration(this.id);
}
