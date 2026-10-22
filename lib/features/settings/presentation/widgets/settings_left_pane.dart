import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/settings_section_provider.dart';
import 'settings_back_link.dart';
import 'settings_header.dart';

/// Left navigation pane for Settings in expanded tablet viewports.
///
/// Follows AGENTS.md §3 & §4.3: under 120 lines, build under 50 lines.
class SettingsLeftPane extends StatelessWidget {
  const SettingsLeftPane({
    super.key,
    required this.header,
    required this.selectedSection,
    required this.onSelectSection,
  });

  final SettingsHeader header;
  final SettingsSectionId selectedSection;
  final ValueChanged<SettingsSectionId> onSelectSection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsBackLink(),
          const SizedBox(height: AppSpacing.sm),
          header,
          const SizedBox(height: AppSpacing.lg),
          for (final section in SettingsSectionId.values) ...[
            _SectionNavTile(
              section: section,
              isSelected: section == selectedSection,
              onTap: () => onSelectSection(section),
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _SectionNavTile extends StatelessWidget {
  const _SectionNavTile({
    required this.section,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final SettingsSectionId section;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? (isDark
              ? AppColors.darkPracticeLavenderBackground
              : AppColors.tintLavender)
        : Colors.transparent;
    final textColor = isSelected
        ? AppColors.brandPurple
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return Semantics(
      button: true,
      selected: isSelected,
      label: section.title,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(section.emoji, style: const TextStyle(fontSize: 18.0)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    section.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.brandPurple,
                    size: 20.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
