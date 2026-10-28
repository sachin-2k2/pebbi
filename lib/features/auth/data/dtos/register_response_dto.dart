/// Response payload DTO for `POST /api/auth/register`.
///
/// Follows API-V2.md §6 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class RegisterResponseDto {
  const RegisterResponseDto({
    required this.message,
    required this.expiresIn,
  });

  final String message;
  final String expiresIn;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      message: json['message']?.toString() ?? '',
      expiresIn: json['expires_in']?.toString() ?? '',
    );
  }
}
