import 'package:json_annotation/json_annotation.dart';

part 'edit_train_configuration_response.g.dart';

@JsonSerializable()
class EditTrainConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditTrainConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditTrainConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$EditTrainConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EditTrainConfigurationResponseToJson(this);
}
