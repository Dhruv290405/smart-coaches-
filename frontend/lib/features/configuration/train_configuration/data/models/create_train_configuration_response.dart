import 'package:json_annotation/json_annotation.dart';

part 'create_train_configuration_response.g.dart';

@JsonSerializable()
class CreateTrainConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  CreateTrainConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateTrainConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTrainConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTrainConfigurationResponseToJson(this);
}
