import 'user_profile_dto.dart';

/// Response payload DTO for `POST /api/auth/verify-otp`.
///
/// Follows API-V2.md §7 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class VerifyOtpResponseDto {
  const VerifyOtpResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final UserProfileDto user;

  factory VerifyOtpResponseDto.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseDto(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      user: UserProfileDto.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
