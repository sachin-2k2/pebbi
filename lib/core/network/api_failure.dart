/// Sealed hierarchy of network and API failure outcomes.
///
/// Follows AGENTS.md §2 & §6:
/// - Security Rule: Never carries raw server error text or echoed user inputs
///   (passwords, tokens, emails, etc.) to prevent security leakage.
/// - Validation failure holds ONLY sanitized field names and a categorization kind.
sealed class ApiFailure {
  const ApiFailure();

  /// User-friendly localized message key or fallback descriptor.
  String get userMessage;
}

class NetworkFailure extends ApiFailure {
  const NetworkFailure();

  @override
  String get userMessage =>
      'No internet connection. Please check your network and try again.';

  @override
  String toString() => 'NetworkFailure()';
}

class TimeoutFailure extends ApiFailure {
  const TimeoutFailure();

  @override
  String get userMessage =>
      'The request took too long to complete. Please try again.';

  @override
  String toString() => 'TimeoutFailure()';
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure();

  @override
  String get userMessage => 'Your session has expired. Please sign in again.';

  @override
  String toString() => 'UnauthorizedFailure()';
}

class ValidationFailure extends ApiFailure {
  const ValidationFailure({
    this.fieldNames = const [],
    this.kind = 'validation_error',
  });

  /// The list of input field names that failed validation (e.g. `['email', 'password']`).
  final List<String> fieldNames;

  /// Alias for fieldNames
  List<String> get invalidFields => fieldNames;

  /// High-level failure kind (e.g. `missing`, `invalid_format`, `out_of_range`).
  final String kind;

  @override
  String get userMessage =>
      'Please check the provided information and try again.';

  @override
  String toString() => 'ValidationFailure(fields: $fieldNames, kind: $kind)';
}

class ConflictFailure extends ApiFailure {
  const ConflictFailure();

  @override
  String get userMessage =>
      'A conflict occurred with this request. Please try again.';

  @override
  String toString() => 'ConflictFailure()';
}

class NotFoundFailure extends ApiFailure {
  const NotFoundFailure();

  @override
  String get userMessage => 'The requested resource was not found.';

  @override
  String toString() => 'NotFoundFailure()';
}

class RateLimitedFailure extends ApiFailure {
  const RateLimitedFailure({this.retryAfter});

  final Duration? retryAfter;

  @override
  String get userMessage =>
      'Too many requests. Please wait a moment before trying again.';

  @override
  String toString() => 'RateLimitedFailure(retryAfter: $retryAfter)';
}

class ServerFailure extends ApiFailure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  String get userMessage => 'A server error occurred. Please try again later.';

  @override
  String toString() => 'ServerFailure(statusCode: $statusCode)';
}

class UnknownFailure extends ApiFailure {
  const UnknownFailure();

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';

  @override
  String toString() => 'UnknownFailure()';
}
