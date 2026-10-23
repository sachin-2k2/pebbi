import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/design_system/notice_banner.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/chat_message.dart';
import '../../../domain/conversation_state.dart';
import '../../../domain/session_config.dart';
import 'chat_message_list.dart';
import 'goals_strip.dart';
import 'reply_input_bar.dart';
import 'session_footer_links.dart';
import 'session_header.dart';
import 'suggestion_list.dart';
import 'voice_input_bar.dart';

/// Single-column layout for Compact and Medium screen sizes.
///
/// Follows AGENTS.md §3 (< 150 lines, build < 50 lines) & §4.
class SessionBody extends StatelessWidget {
  const SessionBody({
    super.key,
    required this.state,
    required this.config,
    required this.targetLanguageName,
    required this.scrollController,
    required this.textController,
    required this.isOffline,
    required this.captionsOn,
    required this.onHelpTap,
    required this.onCharacterTap,
    required this.onPlayAudio,
    required this.onReport,
    required this.onRetry,
    required this.onDelete,
    required this.onSelectSuggestion,
    required this.onTextChanged,
    required this.onSend,
    required this.onMicTap,
    required this.onTypeInsteadTap,
    required this.onSayInMyLanguageTap,
    required this.onCaptionsToggle,
    required this.onFinishTap,
  });

  final ConversationState state;
  final SessionConfig config;
  final String targetLanguageName;
  final ScrollController scrollController;
  final TextEditingController textController;
  final bool isOffline;
  final bool captionsOn;
  final VoidCallback onHelpTap;
  final VoidCallback onCharacterTap;
  final ValueChanged<ChatMessage> onPlayAudio;
  final ValueChanged<String> onReport;
  final ValueChanged<ChatMessage> onRetry;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onSelectSuggestion;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSend;
  final VoidCallback onMicTap;
  final VoidCallback onTypeInsteadTap;
  final VoidCallback onSayInMyLanguageTap;
  final VoidCallback onCaptionsToggle;
  final VoidCallback onFinishTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isWaiting = state.status == ConversationStatus.starting ||
        state.status == ConversationStatus.waitingForCharacter ||
        state.status == ConversationStatus.sending;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final shouldCollapseSuggestions = isKeyboardOpen || textScale > 1.35;

    return Column(
      children: [
        SessionHeader(
          characterName: state.characterName,
          characterRole: state.characterRole,
          emoji: state.emoji,
          onHelpTap: onHelpTap,
          onCharacterTap: onCharacterTap,
        ),
        GoalsStrip(goals: state.goals),
        if (isOffline)
          const NoticeBanner(
            message: AppStrings.offlineBannerNotice,
            icon: Icon(Icons.wifi_off_rounded, size: 20.0),
          ),
        if (state.errorMessage != null)
          NoticeBanner(
            message: state.errorMessage!,
            tone: NoticeBannerTone.warning,
          ),
        Expanded(
          child: ChatMessageList(
            messages: state.messages,
            characterName: state.characterName,
            scrollController: scrollController,
            isWaitingForCharacter: isWaiting,
            areAllGoalsDone: state.areAllGoalsDone,
            onPlayAudio: onPlayAudio,
            onReport: onReport,
            onRetry: onRetry,
            onDelete: onDelete,
          ),
        ),
        if (config.support.id == 'guided' && state.suggestions.isNotEmpty)
          SuggestionList(
            suggestions: state.suggestions,
            onSelect: onSelectSuggestion,
            isKeyboardOpen: shouldCollapseSuggestions,
          ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          color: palette.surface,
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
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
              else if (config.mode.id == 'voice')
                VoiceInputBar(
                  isListening: false,
                  onMicTap: onMicTap,
                  onTypeInsteadTap: onTypeInsteadTap,
                )
              else
                ReplyInputBar(
                  controller: textController,
                  targetLanguageCode: config.targetLanguageCode,
                  targetLanguageName: targetLanguageName,
                  isEnabled: state.status == ConversationStatus.userTurn ||
                      state.status == ConversationStatus.failed,
                  canSend: state.canSend,
                  onChanged: onTextChanged,
                  onSend: onSend,
                ),
              const SizedBox(height: AppSpacing.xs),
              SessionFooterLinks(
                captionsOn: captionsOn,
                onSayInMyLanguageTap: onSayInMyLanguageTap,
                onCaptionsToggle: onCaptionsToggle,
                onFinishTap: onFinishTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
