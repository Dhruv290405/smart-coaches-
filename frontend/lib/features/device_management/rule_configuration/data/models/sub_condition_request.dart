import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_condition_request.freezed.dart';
part 'sub_condition_request.g.dart';

@freezed
abstract class SubConditionRequest with _$SubConditionRequest {
  const factory SubConditionRequest({
    String? operator,
    @JsonKey(name: 'threshold_value') num? thresholdValue,
    String? connector,
    @JsonKey(name: 'sort_order') int? sortOrder,
  }) = _SubConditionRequest;

  factory SubConditionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubConditionRequestFromJson(json);
}
