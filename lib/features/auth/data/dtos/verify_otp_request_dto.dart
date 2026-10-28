/// Request payload DTO for `POST /api/auth/verify-otp`.
///
/// Follows API-V2.md §7 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class VerifyOtpRequestDto {
  const VerifyOtpRequestDto({
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'otp': otp.trim(),
  };
}
