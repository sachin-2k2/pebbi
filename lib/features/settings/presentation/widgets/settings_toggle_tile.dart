import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable settings toggle row with title, description, and accessible Switch.
///
/// Follows AGENTS.md §3 & §4: minimum 48dp touch target, full WCAG AA contrast.
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    this.leading,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  });

  final Widget? leading;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final descColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final semanticsDesc = description != null ? ', $description' : '';
    final stateDesc = value ? 'on' : 'off';

    return Semantics(
      toggled: value,
      enabled: isEnabled,
      label: '$title$semanticsDesc, $stateDesc',
      child: InkWell(
        onTap: isEnabled && onChanged != null ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          description!,
                          style: AppTypography.captionSmall.copyWith(
                            color: descColor,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(
                  child: Switch.adaptive(
                    value: value,
                    onChanged: isEnabled ? onChanged : null,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.settingsSwitchMintTrack,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.settingsSwitchOffTrack,
                    trackOutlineColor: WidgetStateProperty.resolveWith((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return AppColors.settingsSwitchOffBorder;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
