import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import 'floating_emoji_decoration.dart';

/// Top header banner for the premium screen with purple gradient, logo tile,
/// translucent close button, and promotional trial pill matching the exact design.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// ExcludeSemantics for decorative elements, semantic header for title.
class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key, this.onClose, this.trialDays = 7});

  /// Callback when user taps the close (X) button.
  final VoidCallback? onClose;

  /// Introductory free trial days for the top-right badge pill.
  final int? trialDays;

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
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xl + 4.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: AppSpacing.sm),
                  _buildLogoTile(),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    header: true,
                    child: Text(
                      AppStrings.unlockAllTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.display.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.unlockAllSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.94),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          button: true,
          label: AppStrings.closeSemantics,
          child: Material(
            color: Colors.white.withValues(alpha: 0.22),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onClose ?? () => Navigator.of(context).maybePop(),
              child: const SizedBox(
                width: 38.0,
                height: 38.0,
                child: Icon(Icons.close, color: Colors.white, size: 20.0),
              ),
            ),
          ),
        ),
        if (trialDays != null && trialDays! > 0)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FDF5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppStrings.trialDaysPill(trialDays!),
                  style: AppTypography.labelMedium.copyWith(
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoTile() {
    return ExcludeSemantics(
      child: Container(
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
              child: Text('✨', style: TextStyle(fontSize: 16.0, height: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}
