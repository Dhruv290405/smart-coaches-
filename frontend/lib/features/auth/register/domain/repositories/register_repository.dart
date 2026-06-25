
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';

abstract class RegisterRepository {
  Future<RegisterResponse> doRegister(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> sendOtp(String mobileNumber);
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp);
}
