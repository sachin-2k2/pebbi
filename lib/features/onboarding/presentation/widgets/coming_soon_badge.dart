import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Small badge displaying a sparkle icon and "More coming soon" for unavailable languages.
///
/// Follows AGENTS.md §3: under 100 lines, theme tokens, accessible layout.
class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key, this.color = AppColors.textMuted});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 13.0, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            AppStrings.moreComingSoon,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
