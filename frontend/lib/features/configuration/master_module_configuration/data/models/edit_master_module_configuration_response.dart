import 'package:json_annotation/json_annotation.dart';

part 'edit_master_module_configuration_response.g.dart';

@JsonSerializable()
class EditMasterModuleConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditMasterModuleConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditMasterModuleConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditMasterModuleConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditMasterModuleConfigurationResponseToJson(this);
}
