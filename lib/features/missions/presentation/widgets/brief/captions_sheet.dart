import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';

/// Bottom sheet / dialog for managing the role-play captions toggle.
///
/// Follows AGENTS.md §3 & §4.5:
/// - Bound to shared [appSettingsProvider.captionsAlwaysOn]
/// - Presented adaptively via [AdaptiveSheet]
class CaptionsSheet extends ConsumerWidget {
  const CaptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final captionsOn = ref.watch(
      appSettingsProvider.select((s) => s.captionsAlwaysOn),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.captionsSheetTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.captionsSheetSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.isDark
                    ? palette.surfaceVariant
                    : palette.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: palette.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.captionsSwitchLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: captionsOn,
                    activeThumbColor: Colors.white,
                    activeTrackColor: palette.mint,
                    onChanged: (val) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setCaptionsAlwaysOn(val);
                    },
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
