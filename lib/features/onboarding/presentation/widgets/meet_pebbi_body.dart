import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/accent_swatch_row.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/accent_option.dart';
import '../providers/onboarding_flow_provider.dart';
import 'pebbi_hero.dart';
import 'section_label.dart';
import 'sticker_row.dart';

/// Body layout of Step 9: Meet Pebbi (Accent Colour & First Sticker).
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines,
/// single-responsibility presentation component with accessible live region announcements.
class MeetPebbiBody extends ConsumerWidget {
  const MeetPebbiBody({super.key});

  void _handleSelectAccent(
    BuildContext context,
    WidgetRef ref,
    String accentId,
  ) {
    ref.read(onboardingFlowProvider.notifier).setAccent(accentId);
    ref.read(appSettingsProvider.notifier).setAccentId(accentId);

    // Announce accent change as a live region for screen readers
    final option = AccentOption.findById(accentId);
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppStrings.accentChangedAnnouncement(option.name),
      Directionality.of(context),
    );
  }

  void _handleSelectSticker(WidgetRef ref, String stickerId) {
    ref.read(onboardingFlowProvider.notifier).toggleFirstSticker(stickerId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentId = ref.watch(
      onboardingFlowProvider.select((s) => s.accentId),
    );
    final selectedStickerId = ref.watch(
      onboardingFlowProvider.select((s) => s.firstStickerId),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          AppStrings.meetPebbiTitle,
          textAlign: TextAlign.center,
          style: AppTypography.screenTitle.copyWith(
            fontSize: 24.0,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.meetPebbiSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: subtitleColor,
              fontSize: 14.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PebbiHero(accentId: accentId),
        const SizedBox(height: AppSpacing.md),
        const SectionLabel(text: AppStrings.accentColourLabel),
        const SizedBox(height: AppSpacing.sm),
        AccentSwatchRow(
          selectedAccentId: accentId,
          onSelectAccent: (id) => _handleSelectAccent(context, ref, id),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel(text: AppStrings.yourFirstStickerLabel),
        const SizedBox(height: AppSpacing.sm),
        StickerRow(
          selectedStickerId: selectedStickerId,
          onSelectSticker: (id) => _handleSelectSticker(ref, id),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
