import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:smart_coach_new/features/profile/domain/entities/profile_entity.dart';
import 'package:smart_coach_new/features/profile/domain/repositories/profile_repository.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<(ProfileEntity, String)> getProfile() async {
    final (profileData, message) = await remoteDataSource.getProfile();
    return (profileData.toEntity(), message);
  }
}