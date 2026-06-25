import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/auth/register/data/datasources/register_remote_data_source.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';
import 'package:smart_coach_new/features/auth/register/domain/repositories/register_repository.dart';

@Injectable(as: RegisterRepository)
class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSourceImpl remoteDataSource;

  RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RegisterResponse> doRegister(Map<String, dynamic> payload) =>
      remoteDataSource.doRegister(payload);

  @override
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) =>
      remoteDataSource.sendOtp(mobileNumber);

  @override
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) =>
      remoteDataSource.verifyOtp(mobileNumber, otp);
}
