import 'package:json_annotation/json_annotation.dart';

part 'coach_by_location_response.g.dart';

@JsonSerializable()
class CoachByLocationResponse {
  final bool success;
  final String? message;
  final int? count;
  final List<CoachByLocationItem>? data;

  CoachByLocationResponse({
    required this.success,
    this.message,
    this.count,
    this.data,
  });

  factory CoachByLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$CoachByLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoachByLocationResponseToJson(this);
}

@JsonSerializable()
class CoachByLocationItem {
  final int? id;
  @JsonKey(name: 'technical_id')
  final dynamic technicalId;
  @JsonKey(name: 'coach_no')
  final dynamic coachNo;
  @JsonKey(name: 'device_id')
  final dynamic deviceId;
  @JsonKey(name: 'Train_no')
  final dynamic trainNo;
  @JsonKey(name: 'Location')
  final dynamic location;
  @JsonKey(name: 'Actual_id')
  final dynamic actualId;

  CoachByLocationItem({
    this.id,
    this.technicalId,
    this.coachNo,
    this.deviceId,
    this.trainNo,
    this.location,
    this.actualId,
  });

  factory CoachByLocationItem.fromJson(Map<String, dynamic> json) =>
      _$CoachByLocationItemFromJson(json);

  Map<String, dynamic> toJson() => _$CoachByLocationItemToJson(this);
}
