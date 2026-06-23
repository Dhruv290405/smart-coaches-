import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';
import 'package:smart_coach_new/features/profile/domain/repositories/profile_repository.dart';

@injectable
class ProfileUseCase {
  final ProfileRepository repository;

  ProfileUseCase(this.repository);

  Future<(ProfileEntity, String)> call() async {
    return await repository.getProfile();
  }
}