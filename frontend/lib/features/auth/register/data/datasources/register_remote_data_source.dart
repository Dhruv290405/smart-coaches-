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

  Future<dynamic> sendOtp(String mobileNumber) async {
    return safeRequest(() async {
      return await restClient.sendOtp({'mobile_number': mobileNumber});
    });
  }

  Future<dynamic> verifyOtp(String mobileNumber, String otp) async {
    return safeRequest(() async {
      return await restClient.verifyOtp({'mobile_number': mobileNumber, 'otp': otp});
    });
  }
}
