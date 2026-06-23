import 'package:json_annotation/json_annotation.dart';

part 'sub_condition.g.dart';

@JsonSerializable()
class SubCondition {
  @JsonKey(name: 'operator')
  final String? operator;

  @JsonKey(name: 'threshold')
  final String? threshold;

  SubCondition({
    this.operator,
    this.threshold,
  });

  factory SubCondition.fromJson(Map<String, dynamic> json) =>
      _$SubConditionFromJson(json);

  Map<String, dynamic> toJson() => _$SubConditionToJson(this);
}
