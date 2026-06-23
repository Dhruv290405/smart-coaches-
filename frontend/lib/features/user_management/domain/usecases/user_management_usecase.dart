import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/user_management/data/models/approve_user_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/pending_users_request.dart';
import 'package:smart_coach_new/features/user_management/domain/entities/user_entity.dart';
import 'package:smart_coach_new/features/user_management/domain/repositories/user_management_repository.dart';

@injectable
class UserManagementUseCase {
  final UserManagementRepository repository;

  UserManagementUseCase(this.repository);

  Future<List<UserEntity>> fetchUsers({PendingUsersRequest? request}) =>
      repository.fetchUsers(request: request);

  Future<String> approveOrRejectUsers(List<ApproveUserRequest> usersIdList) => repository.approveOrRejectUsers(usersIdList);

  Future<String> changeRole(int? roleId, int? targetUserId) => repository.changeRole(roleId, targetUserId);

  Future<String> changeTrain(int? targetUserId, List<int>? trainIds) => repository.changeTrain(targetUserId, trainIds);
}
