/// Request payload DTO for `POST /api/auth/login`.
///
/// Follows API-V2.md §8 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password,
  };
}
