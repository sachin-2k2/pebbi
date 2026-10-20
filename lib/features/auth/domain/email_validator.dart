/// Validation errors for email fields.
enum EmailValidationError {
  /// The email field was left blank or contains only whitespace.
  empty,

  /// The email address does not follow standard RFC email formatting.
  invalidFormat,
}

/// Pure Dart utility for validating email addresses.
///
/// Follows AGENTS.md §2.2: Pure rules with zero Flutter imports.
abstract final class EmailValidator {
  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Validates an email input string. Whitespace is automatically trimmed.
  static EmailValidationError? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return EmailValidationError.empty;
    }
    final trimmed = value.trim();
    if (trimmed.contains('..') || trimmed.contains(' ')) {
      return EmailValidationError.invalidFormat;
    }
    if (!_emailRegExp.hasMatch(trimmed)) {
      return EmailValidationError.invalidFormat;
    }
    return null;
  }
}
