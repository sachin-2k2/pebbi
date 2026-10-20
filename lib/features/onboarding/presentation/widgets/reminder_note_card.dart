import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Informational card displaying quiet-hours and notification reassurance.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// dynamically switches message when reminders are disabled (0 days selected).
class ReminderNoteCard extends StatelessWidget {
  const ReminderNoteCard({super.key, required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurfaceVariant : AppColors.tintLavender;
    final textColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final message = isEnabled
        ? AppStrings.reminderNoteActive
        : AppStrings.reminderNoteDisabled;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20.0,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                height: 1.4,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
