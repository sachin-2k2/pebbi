/// Validation errors for password fields.
enum PasswordValidationError {
  /// The password field was left blank.
  empty,

  /// The password is shorter than the minimum required length (8 characters).
  tooShort,

  /// The password is longer than the maximum allowed length (72 characters).
  tooLong,

  /// The confirm password does not match the first password.
  mismatch,
}

/// Pure Dart utility for checking password rules.
///
/// Follows AGENTS.md §2.2: Pure rules with zero Flutter imports.
/// - Minimum 8 characters, maximum 72 characters.
/// - Complexity: Length-focused per modern NIST recommendations; avoids blocking pasting
///   or password manager generated passwords.
/// - TODO(question: the backend team owns the real policy).
abstract final class PasswordRules {
  /// Minimum allowed password length.
  /// TODO(question: backend team owns the real password policy).
  static const int minLength = 8;

  /// Maximum allowed password length (standard hashing limit).
  /// TODO(question: confirm maximum character limit with backend team).
  static const int maxLength = 72;

  /// Validates password presence for login. Does not enforce complexity.
  static PasswordValidationError? validateForLogin(String? value) {
    if (value == null || value.isEmpty) {
      return PasswordValidationError.empty;
    }
    return null;
  }

  /// Validates password length and presence for registration.
  static PasswordValidationError? validateForRegistration(String? value) {
    if (value == null || value.isEmpty) {
      return PasswordValidationError.empty;
    }
    if (value.length < minLength) {
      return PasswordValidationError.tooShort;
    }
    if (value.length > maxLength) {
      return PasswordValidationError.tooLong;
    }
    return null;
  }

  /// Compares confirm password against primary password.
  static PasswordValidationError? validateConfirmPassword({
    required String? password,
    required String? confirmPassword,
  }) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return PasswordValidationError.empty;
    }
    if (confirmPassword != password) {
      return PasswordValidationError.mismatch;
    }
    return null;
  }
}
