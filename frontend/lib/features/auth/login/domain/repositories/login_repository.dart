import 'package:smart_coach_new/features/auth/login/data/models/login_response.dart';

abstract class LoginRepository {
  Future<(LoginData, String)> login(String emailOrPhoneNumber, String password);
}
