import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../premium/presentation/widgets/floating_emoji_decoration.dart';
import 'welcome_back_block.dart';

/// Top header banner for authentication screens with purple gradient, logo,
/// wordmark, floating emojis, and welcome back message block.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// reuses FloatingEmojiDecoration and premium gradient tokens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.title = AppStrings.welcomeBackTitle,
    this.subtitle = AppStrings.welcomeBackSubtitle,
    this.badgeIcon = Icons.login_rounded,
  });

  final String title;
  final String subtitle;
  final IconData badgeIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.premiumGradientStart,
            AppColors.premiumGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: FloatingEmojiDecoration()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl * 2.0, // Extra spacing for overlapping AuthCard
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LogoAndWordmark(),
                  const SizedBox(height: AppSpacing.lg),
                  WelcomeBackBlock(
                    title: title,
                    subtitle: subtitle,
                    badgeIcon: badgeIcon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoAndWordmark extends StatelessWidget {
  const _LogoAndWordmark();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x331E1647),
                        blurRadius: 16.0,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: PebbiMascot(
                      size: 40.0,
                      expression: PebbiExpression.happy,
                    ),
                  ),
                ),
                const Positioned(
                  top: -6.0,
                  right: -6.0,
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: 16.0, height: 1.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2.0),
          Text(
            AppStrings.pebbiWordmark,
            style: AppTypography.screenTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20.0,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
