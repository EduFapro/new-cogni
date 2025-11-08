class ValidationHelper {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}
