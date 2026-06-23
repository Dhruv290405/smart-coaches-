abstract class LoginEvent {}

class LoginWithEmailOrNumberToggled extends LoginEvent {
  final bool isLoginWithEmail;

  LoginWithEmailOrNumberToggled(this.isLoginWithEmail);
}

class LoginRequested extends LoginEvent {
  final String emailOrPhoneNumber, password;

  LoginRequested(this.emailOrPhoneNumber, this.password);
}
