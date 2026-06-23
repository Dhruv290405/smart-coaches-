import 'package:json_annotation/json_annotation.dart';

part 'create_master_module_configuration_response.g.dart';

@JsonSerializable()
class CreateMasterModuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateMasterModuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateMasterModuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateMasterModuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMasterModuleConfigurationResponseToJson(this);
}
