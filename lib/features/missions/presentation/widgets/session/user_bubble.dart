import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/chat_message.dart';
import 'correction_note.dart';
import 'translation_line.dart';

/// Right-aligned user message bubble.
///
/// Follows AGENTS.md §3 & §8:
/// - Max width ~85%
/// - TODO(question: user bubble style is estimated with brandTint surface and brand border)
/// - Delivery states: sending, sent, failed (with Retry/Delete actions)
class UserBubble extends StatelessWidget {
  const UserBubble({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDelete,
  });

  final ChatMessage message;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isFailed = message.deliveryState == MessageDeliveryState.failed;
    final isSending = message.deliveryState == MessageDeliveryState.sending;

    final semanticsLabel = AppStrings.sessionUserMessageSemantics(
      message.targetText,
      message.translationText,
      isFailed,
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isFailed ? palette.errorSurface : palette.brandTint,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusCard),
                    topRight: Radius.circular(AppSpacing.radiusCard),
                    bottomLeft: Radius.circular(AppSpacing.radiusCard),
                    bottomRight: Radius.circular(AppSpacing.radiusSm),
                  ),
                  border: Border.all(
                    color: isFailed ? palette.errorBorder : palette.brand,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.targetText,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFailed ? palette.errorText : palette.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    if (message.translationText != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TranslationLine(
                        translation: message.translationText,
                        color: isFailed ? palette.errorText : palette.textMuted,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSending)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(
                    AppStrings.sessionMessageSending,
                    style: AppTypography.caption.copyWith(color: palette.textMuted),
                  ),
                ),
              if (isFailed)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: AppSpacing.xs),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: 2.0,
                    children: [
                      Text(
                        AppStrings.sessionMessageFailed,
                        style: AppTypography.caption.copyWith(
                          color: palette.errorText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          minimumSize: const Size(48.0, 32.0),
                        ),
                        child: Text(
                          AppStrings.sessionRetrySend,
                          style: TextStyle(color: palette.brand, fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: onDelete,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          minimumSize: const Size(48.0, 32.0),
                        ),
                        child: Text(
                          AppStrings.sessionDeleteFailedMessage,
                          style: TextStyle(color: palette.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              if (message.correction != null)
                CorrectionNote(correction: message.correction!),
            ],
          ),
        ),
      ),
    );
  }
}
