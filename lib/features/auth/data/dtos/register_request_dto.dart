/// Request payload DTO for `POST /api/auth/register`.
///
/// Follows API-V2.md §6 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.displayName,
    this.onboardingPayload = const {},
  });

  final String email;
  final String password;
  final String displayName;
  final Map<String, dynamic> onboardingPayload;

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password,
      'display_name': displayName.trim(),
      ...onboardingPayload,
    };
  }
}
