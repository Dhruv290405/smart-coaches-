import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/auth/login/data/datasources/login_remote_data_source.dart';
import 'package:smart_coach_new/features/auth/login/data/models/login_response.dart';
import 'package:smart_coach_new/features/auth/login/domain/repositories/login_repository.dart';

@Injectable(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSourceImpl remoteDataSource;

  LoginRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(LoginData, String)> login(String emailOrPhoneNumber, String password) =>
      remoteDataSource.login(emailOrPhoneNumber, password);
}
