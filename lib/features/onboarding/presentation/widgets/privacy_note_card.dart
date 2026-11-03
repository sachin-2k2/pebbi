import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/age_band.dart';

/// Soft note card displaying privacy clarification or under-13 blocked explanation.
///
/// Follows AGENTS.md §3 and §6: data-driven text and icon based on [AgeBand],
/// responsive and theme-aware.
class PrivacyNoteCard extends StatelessWidget {
  const PrivacyNoteCard({super.key, required this.ageBand});

  final AgeBand? ageBand;

  static const String under13BlockedCopy =
      'Tutotoco is designed for learners ages 13 and up. Please ask a parent or check back with us when you turn 13!';

  @override
  Widget build(BuildContext context) {
    final isBlocked = ageBand == null;
    final noteText = isBlocked ? under13BlockedCopy : ageBand!.privacyNote;
    final showShield = isBlocked || (ageBand?.hasShieldIcon ?? false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isBlocked ? const Color(0xFFFFF1F2) : const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: isBlocked ? Border.all(color: const Color(0xFFFDA4AF)) : null,
      ),
      child: showShield
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.shield_outlined,
                    color: isBlocked
                        ? const Color(0xFFE11D48)
                        : AppColors.brandPurple,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    noteText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isBlocked
                          ? const Color(0xFF9F1239)
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              noteText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
    );
  }
}
