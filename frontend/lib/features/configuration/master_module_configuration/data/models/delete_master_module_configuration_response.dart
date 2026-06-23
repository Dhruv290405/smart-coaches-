import 'package:json_annotation/json_annotation.dart';

part 'delete_master_module_configuration_response.g.dart';

@JsonSerializable()
class DeleteMasterModuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteMasterModuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteMasterModuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteMasterModuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteMasterModuleConfigurationResponseToJson(this);
}
