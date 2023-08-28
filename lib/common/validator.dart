class Validator {
  static String? validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(pattern as String);
    if (!regex.hasMatch(value)) {
      return ' Please enter a valid email address.';
    } else {
      return null;
    }
  }

  static String? validatePassword(String value) {
    if (value.length != 6) {
      return ' Password must be 6 digits';
    } else {
      return null;
    }
  }
}
