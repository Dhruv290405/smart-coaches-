import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<(ProfileEntity, String)> getProfile();
}