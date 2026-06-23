
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';

abstract class RegisterRepository {
  Future<RegisterResponse> doRegister(Map<String, dynamic> payload);
}
