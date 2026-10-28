import 'user_profile_dto.dart';

/// Response payload DTO for `POST /api/auth/login`.
///
/// Follows API-V2.md §8 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final UserProfileDto user;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      user: UserProfileDto.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
