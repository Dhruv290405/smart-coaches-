import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/auth/login/data/models/login_response.dart';

@injectable
class LoginRemoteDataSourceImpl {
  final RestClient restClient;

  LoginRemoteDataSourceImpl(this.restClient);

  Future<(LoginData, String)> login(
      String emailOrPhoneNumber, String password) async {
    return safeRequest(() async {
      final loginResponse = await restClient.login({
        ApiConstants.email: emailOrPhoneNumber,
        ApiConstants.password: password,
      });
      return (loginResponse.data!, loginResponse.message);
    });
  }
}