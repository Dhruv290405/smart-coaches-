import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/features/profile/data/models/profile_response.dart';

abstract class ProfileRemoteDataSource {
  Future<(ProfileData, String)> getProfile();
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final RestClient restClient;

  ProfileRemoteDataSourceImpl(this.restClient);

  @override
  Future<(ProfileData, String)> getProfile() async {
    try {
      final response = await restClient.getProfile();
      if (response.success) {
        return (response.data, response.message);
      } else {
        throw ApiException(response.message);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}