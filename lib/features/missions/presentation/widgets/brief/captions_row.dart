import 'package:flutter/material.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import 'captions_sheet.dart';

/// Centred tap row displaying the active captions status ("Captions: on  ›").
///
/// Follows AGENTS.md §3, §4.6 & §8:
/// - Minimum 48dp tap target
/// - Bold muted text passing WCAG AA contrast
/// - Tapping opens [CaptionsSheet] via [AdaptiveSheet]
class CaptionsRow extends StatelessWidget {
  const CaptionsRow({super.key, required this.captionsOn});

  final bool captionsOn;

  void _handleTap(BuildContext context) {
    AdaptiveSheet.show<void>(
      context: context,
      builder: (dialogCtx) => const CaptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = AppStrings.missionCaptionsRow(captionsOn);

    return Semantics(
      button: true,
      label: 'Captions setting: ${captionsOn ? 'on' : 'off'}. Tap to change.',
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48.0),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
