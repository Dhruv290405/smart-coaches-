class Validators {
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter password';
    }

    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static bool isEmailValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    const emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    final regex = RegExp(emailPattern);

    if (!regex.hasMatch(value.trim())) {
      return false;
    }

    return true;
  }
}