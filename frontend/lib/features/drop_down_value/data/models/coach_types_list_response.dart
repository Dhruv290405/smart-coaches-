import 'package:json_annotation/json_annotation.dart';

part 'coach_types_list_response.g.dart';

@JsonSerializable()
class CoachTypeListResponse {
  final bool success;
  final String message;
  final List<CoachTypeItem>? data;

  CoachTypeListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CoachTypeListResponse.fromJson(Map<String, dynamic> json) =>
      _$CoachTypeListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoachTypeListResponseToJson(this);
}

@JsonSerializable()
class CoachTypeItem {
  @JsonKey(name: 'id')
  final int? id;

  final String? code;
  final String? name;

  CoachTypeItem({this.id, this.code, this.name});

  factory CoachTypeItem.fromJson(Map<String, dynamic> json) =>
      _$CoachTypeItemFromJson(json);

  Map<String, dynamic> toJson() => _$CoachTypeItemToJson(this);
}
