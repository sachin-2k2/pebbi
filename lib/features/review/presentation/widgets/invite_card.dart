import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/icon_tile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/invite_link.dart';
import 'invite_link_field.dart';

/// Card component prompting the user to share their personal invite link.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class InviteCard extends StatelessWidget {
  const InviteCard({
    super.key,
    required this.invite,
    required this.onSharePressed,
    this.onCopied,
  });

  final InviteLink invite;
  final VoidCallback onSharePressed;
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const IconTile(
                size: 40.0,
                minSize: 36.0,
                maxSize: 44.0,
                backgroundColor: AppColors.tintLavender,
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.brandPurple,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppStrings.inviteCardTitle,
                  style: AppTypography.cardTitle.copyWith(
                    color: titleColor,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InviteLinkField(url: invite.url, onCopied: onCopied),
          const SizedBox(height: AppSpacing.md),
          Button3D.secondary(
            label: AppStrings.inviteShareButton,
            onPressed: onSharePressed,
          ),
        ],
      ),
    );
  }
}
