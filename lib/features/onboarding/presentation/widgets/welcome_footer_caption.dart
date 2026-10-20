import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Small muted centered footer caption rendered below the action button.
///
/// Follows AGENTS.md §3 and §4: standalone class, supports text scaling,
/// theme token colors.
class WelcomeFooterCaption extends StatelessWidget {
  const WelcomeFooterCaption({super.key, required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Text(
      caption,
      style: AppTypography.caption.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}
