import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';

@injectable
class RegisterRemoteDataSourceImpl {
  final RestClient restClient;

  RegisterRemoteDataSourceImpl(this.restClient);

  Future<RegisterResponse> doRegister(Map<String, dynamic> payload) async {
    return safeRequest(() async {
      final RegisterResponse registerResponse =
          await restClient.register(payload);
      return registerResponse;
    });
  }
}
