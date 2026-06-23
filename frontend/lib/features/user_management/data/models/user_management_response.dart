import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'user_management_response.g.dart';

@JsonSerializable()
class UserManagementResponse {
  final bool success;
  final String message;
  final List<UserModel>? data;

  UserManagementResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserManagementResponse.fromJson(Map<String, dynamic> json) => _$UserManagementResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserManagementResponseToJson(this);
}
