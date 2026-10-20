import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum NoticeBannerTone { warning, info }

/// Reusable notice banner for warnings, hints, and informational alerts.
///
/// Follows AGENTS.md §4.6 and §8:
/// - Semantic color tokens
/// - Accessible screen-reader live region
/// - Passes WCAG AAA text contrast
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.icon,
    this.tone = NoticeBannerTone.warning,
  });

  final String message;
  final Widget? icon;
  final NoticeBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (tone) {
      NoticeBannerTone.warning => AppColors.noticeWarningBackground,
      NoticeBannerTone.info => AppColors.tintSky,
    };

    final borderColor = switch (tone) {
      NoticeBannerTone.warning => AppColors.noticeWarningBorder,
      NoticeBannerTone.info => AppColors.borderLight,
    };

    final textColor = switch (tone) {
      NoticeBannerTone.warning => AppColors.noticeWarningText,
      NoticeBannerTone.info => AppColors.textPrimary,
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: icon != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon!,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildText(textColor)),
                ],
              )
            : _buildText(textColor),
      ),
    );
  }

  Widget _buildText(Color textColor) {
    return Text(
      message,
      style: AppTypography.bodyMedium.copyWith(
        color: textColor,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
