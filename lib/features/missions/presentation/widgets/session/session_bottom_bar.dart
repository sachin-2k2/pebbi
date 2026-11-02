import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/conversation_state.dart';
import '../../../domain/mission_mode.dart';
import '../../../domain/session_config.dart';
import 'reply_input_bar.dart';
import 'session_footer_links.dart';
import 'voice_input_bar.dart';

/// Bottom bar for session screens housing Finish/Debrief, Voice, or Typing input controls.
///
/// Follows AGENTS.md §3 (< 150 lines, build < 50 lines) & §4.
class SessionBottomBar extends StatelessWidget {
  const SessionBottomBar({
    super.key,
    required this.state,
    required this.config,
    required this.targetLanguageName,
    required this.textController,
    required this.captionsOn,
    required this.onFinishTap,
    required this.onMicTap,
    required this.onTypeInsteadTap,
    required this.onVoiceInsteadTap,
    required this.onTextChanged,
    required this.onSend,
    required this.onSayInMyLanguageTap,
    required this.onCaptionsToggle,
  });

  final ConversationState state;
  final SessionConfig config;
  final String targetLanguageName;
  final TextEditingController textController;
  final bool captionsOn;
  final VoidCallback onFinishTap;
  final VoidCallback onMicTap;
  final VoidCallback onTypeInsteadTap;
  final VoidCallback onVoiceInsteadTap;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSend;
  final VoidCallback onSayInMyLanguageTap;
  final VoidCallback onCaptionsToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isVoice = state.isVoice(config);
    final canInteract =
        state.status == ConversationStatus.userTurn ||
        state.status == ConversationStatus.failed;

    return Container(
      color: palette.surface,
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isFinished)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Button3D(
                label: AppStrings.sessionSeeDebrief,
                backgroundColor: palette.mint,
                depthColor: palette.mintDepth,
                textColor: palette.textOnBrand,
                onPressed: onFinishTap,
              ),
            )
          else if (isVoice)
            VoiceInputBar(
              isListening: state.isListening,
              isEnabled: canInteract,
              onMicTap: onMicTap,
              onTypeInsteadTap: onTypeInsteadTap,
            )
          else ...[
            ReplyInputBar(
              controller: textController,
              targetLanguageCode: config.targetLanguageCode,
              targetLanguageName: targetLanguageName,
              isEnabled: canInteract,
              canSend: state.canSend || textController.text.trim().isNotEmpty,
              onChanged: onTextChanged,
              onSend: onSend,
            ),
            if (config.mode == MissionMode.voice)
              TextButton(
                onPressed: onVoiceInsteadTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48.0, 48.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: Text(
                  AppStrings.sessionVoiceInstead,
                  style: AppTypography.caption.copyWith(
                    color: palette.brand,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xs),
          SessionFooterLinks(
            captionsOn: captionsOn,
            onSayInMyLanguageTap: onSayInMyLanguageTap,
            onCaptionsToggle: onCaptionsToggle,
            onFinishTap: onFinishTap,
          ),
        ],
      ),
    );
  }
}

