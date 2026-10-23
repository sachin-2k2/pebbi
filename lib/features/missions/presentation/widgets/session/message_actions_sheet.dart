import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Moderation reporting sheet for character messages.
///
/// Follows AGENTS.md §7.3 & §14:
/// - Allows reporting offensive or hallucinated messages
/// - Reports to backend repository interface
class MessageActionsSheet extends StatefulWidget {
  const MessageActionsSheet({
    super.key,
    required this.messageId,
    required this.onReport,
  });

  final String messageId;
  final ValueChanged<String> onReport;

  @override
  State<MessageActionsSheet> createState() => _MessageActionsSheetState();
}

class _MessageActionsSheetState extends State<MessageActionsSheet> {
  String _selectedReason = AppStrings.reportReasonInappropriate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final reasons = [
      AppStrings.reportReasonInappropriate,
      AppStrings.reportReasonInaccurate,
      AppStrings.reportReasonOffTopic,
      AppStrings.reportReasonOther,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.reportMessageTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
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
              AppStrings.reportMessageSubtitle,
              style: AppTypography.bodyMedium.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final r in reasons)
              InkWell(
                onTap: () => setState(() => _selectedReason = r),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        _selectedReason == r
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _selectedReason == r ? palette.brand : palette.textMuted,
                        size: 22.0,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          r,
                          style: AppTypography.bodyMedium.copyWith(color: palette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Button3D(
              label: AppStrings.reportSubmit,
              backgroundColor: palette.brand,
              depthColor: palette.brandDepth,
              textColor: palette.textOnBrand,
              onPressed: () {
                widget.onReport(_selectedReason);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
