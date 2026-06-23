import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_module_configuration_request.freezed.dart';
part 'master_module_configuration_request.g.dart';

@freezed
abstract class MasterModuleConfigurationRequest with _$MasterModuleConfigurationRequest {
  const factory MasterModuleConfigurationRequest({
    @JsonKey(name: 'coach_id') int? coachId,
    @JsonKey(name: 'module_unique_id') String? moduleUniqueId,
    @JsonKey(name: 'make_model') String? makeModel,
    @JsonKey(name: 'firmware_version') String? firmwareVersion,
    @JsonKey(name: 'seriel_number') String? serielNumber,
    @JsonKey(name: 'installation_date') String? installationDate,
    @JsonKey(name: 'location') String? location,
    @JsonKey(name: 'placement_type') String? placementType,
    @JsonKey(name: 'sim_no') String? simNo,
    @JsonKey(name: 'recharge_date') String? rechargeDate,
    @JsonKey(name: 'battery_recharge_date') String? batteryRechargeDate,
    @JsonKey(name: 'service_provider_primary') String? serviceProviderPrimary,
    @JsonKey(name: 'service_provider_secondary') String? serviceProviderSecondary,
    @JsonKey(name: 'activation_date') String? activationDate,
    @JsonKey(name: 'sim_status') String? simStatus,
    @JsonKey(name: 'battery_replacement_date') String? batteryReplacementDate,
    @JsonKey(name: 'dual_profile_supported') bool? dualProfileSupported,
    @JsonKey(name: 'lora_enabled') bool? loraEnabled,
    @JsonKey(name: 'esim_enabled') bool? esimEnabled,
    @JsonKey(name: 'battery_capacity') int? batteryCapacity,
    @JsonKey(name: 'battery_type') String? batteryType,
    @JsonKey(name: 'device_ids') List<String>? deviceIds,
  }) = _MasterModuleConfigurationRequest;

  factory MasterModuleConfigurationRequest.fromJson(Map<String, dynamic> json) =>
      _$MasterModuleConfigurationRequestFromJson(json);
}
