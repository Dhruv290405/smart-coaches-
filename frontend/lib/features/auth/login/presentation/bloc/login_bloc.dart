import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_event.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/features/auth/login/domain/usecases/login_usecase.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_event.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/network/api_constants.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LoginUseCase loginUseCase;
  final Prefs prefs;
  final PermissionBloc permissionBloc;
  bool isLoginWithEmail = true;

  LoginBloc({
    required this.loginUseCase,
    required this.prefs,
    required this.permissionBloc,
  }) : super(LoginInitial()) {
    on<LoginRequested>(_onLogin);
    on<LoginWithEmailOrNumberToggled>(_onLoginWithEmailOrNumberToggled);
  }

  void _onLogin(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final (loginData, message) =
      await loginUseCase(event.emailOrPhoneNumber, event.password);

      await prefs.saveToken(loginData.token);
      await prefs.saveUser(loginData.user);

      // Initialize permissions based on user role
      permissionBloc.add(InitializePermissions(
        roleId: loginData.user.roleId ?? 0,
        roleName: null, // You can add roleName from user data if available
      ));

      final userId = loginData.user.userId;

      try {
        final fcmToken = await _messaging.getToken();
        await http.post(
          Uri.parse("${ApiConstants.devUrl}/fcm/fcm-token"),
          body: {
            'user_id': userId.toString(),
            'fcm_token': fcmToken ?? '',
          },
        );
      } catch (_) {}

      emit(LoginSuccess(message));
    } catch (e, stackTrace) {
      print('❌ LOGIN ERROR: $e');
      print('❌ STACK TRACE: $stackTrace');
      emit(LoginFailure(message: e.toString()));
    }
  }

  void _onLoginWithEmailOrNumberToggled(
      LoginWithEmailOrNumberToggled event, Emitter<LoginState> emit) {
    isLoginWithEmail = event.isLoginWithEmail;
    emit(LoginWithFormState(isLoginWithEmail: isLoginWithEmail));
  }
}
