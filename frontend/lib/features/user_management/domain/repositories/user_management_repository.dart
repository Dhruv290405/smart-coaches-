import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';

abstract class UserManagementRepository {
  Future<List<UserEntity>> fetchUsers(
      {PendingUsersRequest? request});

  Future<String> approveOrRejectUsers(List<ApproveUserRequest> usersIdList);

  Future<String> changeRole(int? roleId, int? targetUserId);
  Future<String> changeTrain(int? targetUserId, List<int>? trainIds);
}
