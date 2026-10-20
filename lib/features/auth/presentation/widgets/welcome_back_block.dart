import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Title and orange mascot row for the Welcome Back / Register header block.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, semantic header, scalable typography.
class WelcomeBackBlock extends StatelessWidget {
  const WelcomeBackBlock({
    super.key,
    this.title = AppStrings.welcomeBackTitle,
    this.subtitle = AppStrings.welcomeBackSubtitle,
    this.badgeIcon = Icons.login_rounded,
    this.mascotColor = AppColors.accentOrange,
  });

  final String title;
  final String subtitle;
  final IconData badgeIcon;
  final Color mascotColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildOrangeMascotWithBadge(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrangeMascotWithBadge() {
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PebbiMascot(
            size: 54.0,
            accentColor: mascotColor,
            expression: PebbiExpression.happy,
          ),
          Positioned(
            top: -2.0,
            right: -2.0,
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x331E1647),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  badgeIcon,
                  size: 13.0,
                  color: AppColors.brandPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
