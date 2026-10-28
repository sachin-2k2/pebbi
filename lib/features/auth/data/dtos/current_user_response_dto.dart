import 'user_profile_dto.dart';

/// Response payload DTO for `GET /api/me`.
///
/// Follows API-V2.md §9 & AGENTS.md §2: Pure Dart, zero Flutter imports.
class CurrentUserResponseDto {
  const CurrentUserResponseDto({
    required this.user,
  });

  final UserProfileDto user;

  factory CurrentUserResponseDto.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponseDto(
      user: UserProfileDto.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
