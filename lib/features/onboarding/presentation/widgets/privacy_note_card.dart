import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/age_band.dart';

/// Soft lavender-grey note card clarifying that only the age band is stored.
///
/// Follows AGENTS.md §3 and §6: data-driven text and icon based on [AgeBand],
/// responsive and theme-aware.
class PrivacyNoteCard extends StatelessWidget {
  const PrivacyNoteCard({super.key, required this.ageBand});

  final AgeBand ageBand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFF8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ageBand.hasShieldIcon
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColors.brandPurple,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    ageBand.privacyNote,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              ageBand.privacyNote,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
    );
  }
}
