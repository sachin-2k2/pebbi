import 'package:flutter/material.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/chat_message.dart';
import 'message_actions_sheet.dart';
import 'replay_button.dart';
import 'translation_line.dart';

/// Left-aligned white message bubble for character speech.
///
/// Follows AGENTS.md §3 & §8:
/// - Max width ~85% of screen
/// - Target language line with natural wrapping
/// - Optional translation line when captions are active
/// - Replay audio button and long-press report action
class CharacterBubble extends StatelessWidget {
  const CharacterBubble({
    super.key,
    required this.message,
    required this.characterName,
    required this.onPlayAudio,
    required this.onReport,
  });

  final ChatMessage message;
  final String characterName;
  final VoidCallback onPlayAudio;
  final ValueChanged<String> onReport;

  void _showReportSheet(BuildContext context) {
    AdaptiveSheet.show<void>(
      context: context,
      builder: (dialogCtx) => MessageActionsSheet(
        messageId: message.id,
        onReport: onReport,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final semanticsLabel = AppStrings.sessionCharacterMessageSemantics(
      characterName,
      message.targetText,
      message.translationText,
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
          ),
          child: GestureDetector(
            onLongPress: () => _showReportSheet(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2.0),
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: palette.outline, width: 1.0),
                boxShadow: palette.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.targetText,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  if (message.translationText != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TranslationLine(translation: message.translationText),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReplayButton(onPressed: onPlayAudio),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
