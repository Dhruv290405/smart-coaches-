import 'package:json_annotation/json_annotation.dart';

part 'delete_train_configuration_response.g.dart';

@JsonSerializable()
class DeleteTrainConfigurationResponse {
  final bool success;
  final String message;
  final dynamic data;

  DeleteTrainConfigurationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeleteTrainConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteTrainConfigurationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteTrainConfigurationResponseToJson(this);
}
