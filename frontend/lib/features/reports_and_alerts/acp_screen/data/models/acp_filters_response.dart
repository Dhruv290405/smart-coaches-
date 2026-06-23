import 'package:json_annotation/json_annotation.dart';

part 'acp_filters_response.g.dart';

@JsonSerializable()
class AcpFiltersResponse {
  final bool? success;
  final List<AcpFilterData>? data;

  AcpFiltersResponse({this.success, this.data});

  factory AcpFiltersResponse.fromJson(Map<String, dynamic> json) =>
      _$AcpFiltersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcpFiltersResponseToJson(this);
}

@JsonSerializable()
class AcpFilterData {
  @JsonKey(name: 'train_no')
  final String? trainNo;
  @JsonKey(name: 'comm_coach_no')
  final String? commCoachNo;
  @JsonKey(name: 'tech_coach_no')
  final String? techCoachNo;

  AcpFilterData({this.trainNo, this.commCoachNo, this.techCoachNo});

  factory AcpFilterData.fromJson(Map<String, dynamic> json) =>
      _$AcpFilterDataFromJson(json);

  Map<String, dynamic> toJson() => _$AcpFilterDataToJson(this);
}
