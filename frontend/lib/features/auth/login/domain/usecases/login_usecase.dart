import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/auth/login/data/models/login_response.dart';
import 'package:smart_coach_new/features/auth/login/domain/repositories/login_repository.dart';

@injectable
class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<(LoginData, String)> call(String emailOrPhoneNumber, String password) =>
      repository.login(emailOrPhoneNumber, password);
}
