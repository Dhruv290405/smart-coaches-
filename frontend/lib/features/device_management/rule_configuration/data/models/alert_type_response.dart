import 'package:json_annotation/json_annotation.dart';

part 'alert_type_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AlertTypeResponse {
  final bool success;
  final String message;
  final List<AlertTypeItem>? data;

  AlertTypeResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AlertTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AlertTypeResponseToJson(this);
}

@JsonSerializable()
class AlertTypeItem {
  @JsonKey(name: 'alert_type_id')
  final int? alertTypeId;

  @JsonKey(name: 'alert_type_name')
  final String? alertTypeName;

  AlertTypeItem({
    this.alertTypeId,
    this.alertTypeName,
  });

  factory AlertTypeItem.fromJson(Map<String, dynamic> json) =>
      _$AlertTypeItemFromJson(json);

  Map<String, dynamic> toJson() => _$AlertTypeItemToJson(this);
}
