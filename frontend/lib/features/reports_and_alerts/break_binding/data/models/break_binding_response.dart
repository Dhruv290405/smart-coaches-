import 'package:json_annotation/json_annotation.dart';

part 'break_binding_response.g.dart';

/// ---------------- Train List Response ----------------
@JsonSerializable()
class TrainListResponseForBreakBinding {
  final bool success;
  final String message;
  final List<TrainItem> data;

  TrainListResponseForBreakBinding({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TrainListResponseForBreakBinding.fromJson(Map<String, dynamic> json) =>
      _$TrainListResponseForBreakBindingFromJson(json);

  Map<String, dynamic> toJson() => _$TrainListResponseForBreakBindingToJson(this);
}

/// ---------------- Coach List Response ----------------
@JsonSerializable()
class CoachListResponseForBreakBinding {
  final bool success;
  final String message;
  final List<CoachItem> data;

  CoachListResponseForBreakBinding({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CoachListResponseForBreakBinding.fromJson(Map<String, dynamic> json) =>
      _$CoachListResponseForBreakBindingFromJson(json);

  Map<String, dynamic> toJson() => _$CoachListResponseForBreakBindingToJson(this);
}

/// ---------------- Train Item ----------------
@JsonSerializable()
class TrainItem {
  @JsonKey(name: "train_number")
  final String trainNumber;

  @JsonKey(name: "train_name")
  final String trainName;

  @JsonKey(name: "train_id")
  final int trainId;

  TrainItem({
    required this.trainNumber,
    required this.trainName,
    required this.trainId,
  });

  factory TrainItem.fromJson(Map<String, dynamic> json) =>
      _$TrainItemFromJson(json);

  Map<String, dynamic> toJson() => _$TrainItemToJson(this);
}

/// ---------------- Coach Item ----------------
@JsonSerializable()
class CoachItem {
  @JsonKey(name: "coach_unique_id")
  final String coachUniqueId;

  @JsonKey(name: "coach_id")
  final int coachId;

  CoachItem({
    required this.coachUniqueId,
    required this.coachId,
  });

  factory CoachItem.fromJson(Map<String, dynamic> json) =>
      _$CoachItemFromJson(json);

  Map<String, dynamic> toJson() => _$CoachItemToJson(this);
}