import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// General reusable text link row for authentication navigation.
///
/// Follows AGENTS.md §3 & §4: under 90 lines, wrap for 200% text scale,
/// 48dp minimum touch target, RTL mirroring for leading icons.
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    this.promptText,
    required this.actionText,
    this.leadingIcon,
    this.actionStyle,
    this.onCreateAccount,
    this.onTap,
  });

  final String? promptText;
  final String actionText;
  final IconData? leadingIcon;
  final TextStyle? actionStyle;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onTap;

  VoidCallback get _effectiveAction => onTap ?? onCreateAccount ?? () {};

  @override
  Widget build(BuildContext context) {
    final effectiveActionStyle =
        actionStyle ??
        AppTypography.bodyMedium.copyWith(
          color: AppColors.linkPurple,
          fontWeight: FontWeight.w700,
        );

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Center(
      child: Semantics(
        button: true,
        label: actionText,
        child: InkWell(
          onTap: _effectiveAction,
          borderRadius: BorderRadius.circular(8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: 4.0,
                children: [
                  if (leadingIcon != null) ...[
                    Transform.flip(
                      flipX: isRtl,
                      child: Icon(
                        leadingIcon,
                        size: 16.0,
                        color:
                            effectiveActionStyle.color ?? AppColors.linkPurple,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  if (promptText != null && promptText!.isNotEmpty) ...[
                    Text(
                      promptText!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.dividerText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  Text(actionText, style: effectiveActionStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialized prompt link for switching between Login and Registration.
class AuthSwitchLink extends AuthTextLink {
  const AuthSwitchLink({
    super.key,
    super.promptText = AppStrings.newToPebbi,
    super.actionText = AppStrings.createAnAccount,
    super.onCreateAccount,
    super.onTap,
  });
}
