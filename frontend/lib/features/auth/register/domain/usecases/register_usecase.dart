import 'package:injectable/injectable.dart';import 'package:smart_coach_new/features/auth/register/data/models/register_response.dart';import 'package:smart_coach_new/features/auth/register/domain/repositories/register_repository.dart';@injectable
class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase(this.repository);

  Future<RegisterResponse> register(Map<String, dynamic> payload) =>
      repository.doRegister(payload);

  Future<dynamic> sendOtp(String mobileNumber) =>
      repository.sendOtp(mobileNumber);

  Future<dynamic> verifyOtp(String mobileNumber, String otp) =>
      repository.verifyOtp(mobileNumber, otp);
}