abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginWithFormState extends LoginState {
  final bool isLoginWithEmail;

  LoginWithFormState({required this.isLoginWithEmail});
}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;
  LoginSuccess(this.message);
}

class LoginFailure extends LoginState {
  final String? message;
  final List<String> errorList;

  LoginFailure({this.message, this.errorList = const []});
}
