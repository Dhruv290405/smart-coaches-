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
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);

    if (!regex.hasMatch(value.trim())) {
      return false;
    }

    return true;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter first name';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (RegExp(r'[0-9]').hasMatch(value.trim())) {
      return 'First name cannot contain numbers';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter last name';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (RegExp(r'[0-9]').hasMatch(value.trim())) {
      return 'Last name cannot contain numbers';
    }
    return null;
  }
}