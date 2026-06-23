import 'package:json_annotation/json_annotation.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/role_list_response.dart';

part 'all_roles_response.g.dart';

@JsonSerializable()
class AllRolesResponse {
  final bool success;
  final String message;
  final List<RoleItem>? data;

  AllRolesResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AllRolesResponse.fromJson(Map<String, dynamic> json) =>
      _$AllRolesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AllRolesResponseToJson(this);
}
